class CreateClickHistories < ActiveRecord::Migration
  def change
    create_table :click_histories do |t|
      t.references :media_user, index: true
      t.references :offer, index: true
      t.text :request_info
      t.string :ip_address

      t.timestamps
    end
  end
end
