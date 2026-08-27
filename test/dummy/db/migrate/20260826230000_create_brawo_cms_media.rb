class CreateBrawoCmsMedia < ActiveRecord::Migration[7.1]
  def change
    create_table :brawo_cms_media do |t|
      t.string :title
      t.string :alt_text

      t.timestamps
    end
  end
end
