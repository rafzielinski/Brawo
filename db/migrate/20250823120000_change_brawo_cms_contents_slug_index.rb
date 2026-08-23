class ChangeBrawoCmsContentsSlugIndex < ActiveRecord::Migration[7.1]
  def change
    remove_index :brawo_cms_contents, :slug
    add_index :brawo_cms_contents, %i[type slug], unique: true
  end
end
