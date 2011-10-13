class Car < ActiveRecord::Base
  include Spree::Preferences::Preferable

  preference :color, :string, :default => 'red'
  preference :seats, :integer, :default => 4
  preference :engine_size, :float

end
