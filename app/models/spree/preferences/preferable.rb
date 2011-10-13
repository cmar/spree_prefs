# class_attributes are inheritied unless you reassign them in
# the subclass, so when you inherit a Preferable class, the
# inherited hook will assign a new hash for the subclass definitions
# and copy all the definitions allowing the subclass to add
# additional defintions without affecting the base
module Spree::Preferences::Preferable

  def self.included(base)
    base.class_eval do
      class_attribute :preference_definitions
      self.preference_definitions = {}

      def self.inherited(subclass)
        subclass.preference_definitions = {}
        self.preference_definitions.each do |name, definition|
          subclass.add_preference_definition definition
        end
      end

      extend Spree::Preferences::Preferable::ClassMethods
    end
  end

  def preferences
    prefs = {}
    preference_definitions.each do |name, definition|
      prefs[name] = get_preference(name)
    end
    prefs
  end

  def set_preference(name, value)
    prefers! name
    preference_store.set(preference_cache_key(name), value)
  end

  def get_preference(name)
    prefers! name
    preference_store.get preference_cache_key(name),
                         preference_default_cache_key(name)
  end

  def prefers?(name)
    self.class.prefers? name.to_sym
  end

  def prefers!(name)
    raise NoMethodError.new "#{name} preference not defined" unless prefers? name
  end

  def preference_cache_key(name, scope_id=nil)
    scope_id = scope_id || try(:id) || :new
    [self.class.name, scope_id, name].join('::').underscore
  end

  delegate :preference_default_cache_key, :preference_store, :to => 'self.class'

  private

  def name_from_method(name)
    name.to_s.split('_', 2).second.gsub(/\?|=/, '')
  end

  def method_missing(method, *args)
    case method.to_s
    when /^prefer(red|s)_\w+=$/
      set_preference name_from_method(method), args.first
    when /^preferred_\w+$/
      get_preference name_from_method(method)
    when /^prefers_\w+\?$/
      prefers? name_from_method(method)
    else
      super
    end
  end

  module ClassMethods

    def preference(name, *args)
      options = args.extract_options!
      options.assert_valid_keys(:default)

      definition = Spree::Preferences::Definition.new do |d|
        d.name = name
        d.type = args.first if args.first
        d.default = options[:default]
      end
      add_preference_definition definition
    end

    def add_preference_definition(definition)
      preference_definitions[definition.name] = definition

      key = preference_default_cache_key(definition.name)
      value = definition.default
      unless preference_store.exist? key
        preference_store.set(key, value)
      end
    end

    def preference_default_cache_key(name)
      [self.name.to_s, :default, name].join('::').underscore
    end

    def prefers?(name)
      self.preference_definitions.has_key? name
    end

    def preference_store
      Spree::Preferences::Store.instance
    end

  end

end

