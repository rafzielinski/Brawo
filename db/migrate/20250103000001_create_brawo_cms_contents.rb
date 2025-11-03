class CreateBrawoCmsContents < ActiveRecord::Migration[7.1]
  def change
    create_table :brawo_cms_contents do |t|
      t.string :type, null: false
      t.string :title
      t.string :slug
      t.text :description
      t.jsonb :fields, default: {}, null: false
      t.string :status, default: 'draft'
      t.datetime :published_at

      t.timestamps
    end

    add_index :brawo_cms_contents, :type
    add_index :brawo_cms_contents, :slug, unique: true
    add_index :brawo_cms_contents, :status
    add_index :brawo_cms_contents, :fields, using: :gin
  end
end

