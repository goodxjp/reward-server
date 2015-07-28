class CreateHidings < ActiveRecord::Migration
  def change
    create_table :hidings do |t|
      t.references :media_user, index: true
      t.references :target, polymorphic: true, index: true

      t.timestamps
    end
  end
end
