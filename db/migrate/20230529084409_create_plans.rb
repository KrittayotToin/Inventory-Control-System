class CreatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.string :name
      t.decimal :fee
      t.datetime :created_at
      t.datetime :updated_at
      t.text :package
      t.decimal :cod_minimum_fee
      t.decimal :cod_percentage_fee
      t.decimal :ccod_percentage_fee
      t.string :price_type
      t.float :cod_percent

      t.timestamps
    end
  end
end
