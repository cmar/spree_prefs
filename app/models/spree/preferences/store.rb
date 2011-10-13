# Use singleton class Spree::Preferences::Store.instance to access
module Spree::Preferences

  class StoreInstance

    def initialize
      @cache = ActiveSupport::Cache::MemoryStore.new
      load_preferences
    end

    def set(key, value)
      current_value = get(key)
      if current_value != value
        cache_write(key, value)
        persist(key, value)
      end
    end

    def exist?(key)
      @cache.exist? key
    end

    def get(key, default_key=nil)
      unconvert @cache.fetch(key) do
        @cache.read(default_key) if default_key
      end
    end

    private

    def cache_write(key, value)
      @cache.write(key, convert(value))
    end

    # ActiveSupport::Cache::MemoryStore returns false as nil
    def convert(value)
      if value.instance_of? FalseClass
        'false'
      else
        value
      end
    end

    def unconvert(value)
      case value
      when 'false'
        false
      else
        value
      end
    end

    def persist(cache_key, value)
      preference = Spree::Preference.find_or_initialize_by_key(cache_key)
      if preference.new_record? || preference.value != value
        preference.value = value
        preference.save
      end
    end

    def load_preferences
      Spree::Preference.all.each do |p|
        cache_write(p.key, p.value)
      end
    end

  end

  class Store < StoreInstance
    include Singleton
  end

end
