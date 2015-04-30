class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.references :media_user, index: true
      t.string :source_type
      t.integer :source_id
      t.integer :point
      t.integer :type

      t.timestamps
    end
  end
end
