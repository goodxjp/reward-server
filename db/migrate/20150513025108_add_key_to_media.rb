class AddKeyToMedia < ActiveRecord::Migration
  def change
    add_column :media, :key, :string, null: false, :default => ""
  end
end
