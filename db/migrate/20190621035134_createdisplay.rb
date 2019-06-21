class Createdisplay < ActiveRecord::Migration[5.2]
  def change
    create_table :displays do |t|
      t.integer :display_id
      t.boolean :active, default: true
      t.timestamps
  end
end
end
