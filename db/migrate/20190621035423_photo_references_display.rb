class PhotoReferencesDisplay < ActiveRecord::Migration[5.2]
  def change
    add_column :photos, :display_id, :integer
    add_column :photos, :display_all, :boolean
  end
end
