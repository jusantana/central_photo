class Createtablephoto < ActiveRecord::Migration[5.2]
  def change
    create_table :photos do |t|
      t.string :photo_name
      t.string :public_url
      t.integer :days
      t.boolean :active, default: true
      t.string :todas
      t.integer :display
      t.timestamps
    end
  end
end
