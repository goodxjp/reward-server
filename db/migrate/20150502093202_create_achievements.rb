class CreateAchievements < ActiveRecord::Migration
  def change
    create_table :achievements do |t|
      t.references :media_user, index: true
      t.integer :payment, null: false
      t.boolean :payment_include_tax
      t.references :campaign, index: true
      t.references :point, index: true
      t.string :accrual_date, null: false, limit: 8

      t.timestamps
    end
    add_index :achievements, :accrual_date
  end
end
