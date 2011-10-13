class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :spree_preferences do |t|
      t.string :key
      t.text :value
      t.string :value_type

      t.timestamps
    end

    add_index :spree_preferences, :key, :unique => true
  end
end
