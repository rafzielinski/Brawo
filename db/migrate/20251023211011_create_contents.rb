class CreateContents < ActiveRecord::Migration[8.0]
  def change
    create_table :contents do |t|
      t.references :content_type, null: false, foreign_key: true
      t.text :data

      t.timestamps
    end
  end
end
