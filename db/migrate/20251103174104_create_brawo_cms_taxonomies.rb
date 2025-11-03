class CreateBrawoCmsTaxonomies < ActiveRecord::Migration[7.1]
  def change
    create_table :brawo_cms_taxonomies do |t|
      t.string :type, null: false
      t.string :name
      t.string :slug
      t.text :description
      t.jsonb :fields, default: {}, null: false

      t.timestamps
    end

    add_index :brawo_cms_taxonomies, :type
    add_index :brawo_cms_taxonomies, :slug, unique: true
    add_index :brawo_cms_taxonomies, :fields, using: :gin
  end
end

