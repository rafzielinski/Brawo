class CreateContentTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :content_types do |t|
      t.string :name
      t.text :fields

      t.timestamps
    end
  end
end
