class CreatePointHistories < ActiveRecord::Migration
  def change
    create_table :point_histories do |t|
      t.references :media_user, index: true
      t.integer :point_change
      t.string :detail
      t.references :source, polymorphic: true, index: true

      t.timestamps
    end
  end
end
