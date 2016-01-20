class CreateMutes < ActiveRecord::Migration
  def change
    create_table :mutes do |t|
      t.references :target, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
