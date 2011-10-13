# This takes the preferrable methods and adds some
# syntatic sugar to access the preferences
#
# class App < Configuration
#   preference :color, :string
# end
#
# a = App.new
#
# setters:
# a.color = :blue
# a[:color] = :blue
# a.set :color = :blue
# a.preferred_color = :blue
#
# getters:
# a.color
# a[:color]
# a.get :color
# a.preferred_color
#
#
module Spree::Preferences
  class Configuration
    include Spree::Preferences::Preferable

    class << self

      def add_preference_definition_with_named_methods(definition)
        add_preference_definition_without_named_methods(definition)

        define_method(definition.name) do
          get_preference definition.name
        end

        define_method("#{definition.name}=") do |value|
          set_preference definition.name, value
        end
      end
      alias_method_chain :add_preference_definition, :named_methods

    end

    def configure
      yield(self) if block_given?
    end

    alias :preference_cache_key :preference_default_cache_key

    alias :[] :get_preference
    alias :[]= :set_preference

    alias :set :set_preference
    alias :get :get_preference
  end
end
