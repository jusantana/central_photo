class Statustodisplay < ActiveRecord::Migration[5.2]
  def change
    add_column :displays, :last_call, :datetime
  end
end
