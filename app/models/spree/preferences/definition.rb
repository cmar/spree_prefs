module Spree::Preferences
  class Definition
    attr_accessor :name, :type, :default

    def initialize
      yield(self) if block_given?
    end

    def to_s
      "name: #{@name}, type: #{@type}, default: #{@default}"
    end

  end
end
