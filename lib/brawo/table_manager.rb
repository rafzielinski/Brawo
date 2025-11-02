module Brawo
  class TableManager
    def self.ensure_table_exists(content_type_class)
      table_name = content_type_class.table_name

      return if ActiveRecord::Base.connection.table_exists?(table_name)

      # Generate migration in memory and execute
      ActiveRecord::Migration.create_table table_name do |t|
        # Base CMS fields (always present)
        t.string :slug, null: false, index: { unique: true }
        t.string :status, default: 'draft'
        t.datetime :published_at
        t.references :author, foreign_key: { to_table: :users }

        # Custom fields from content type definition
        content_type_class.field_definitions.each do |field_def|
          add_field_column(t, field_def)
        end

        t.timestamps
      end

      # Create model class dynamically
      create_active_record_model(content_type_class)
    end

    private

    def self.add_field_column(table, field_def)
      case field_def.type
      when :string then table.string field_def.name
      when :text then table.text field_def.name
      when :integer then table.integer field_def.name
      when :decimal then table.decimal field_def.name, precision: field_def.options[:precision], scale: field_def.options[:scale]
      when :boolean then table.boolean field_def.name, default: field_def.options[:default]
      when :datetime then table.datetime field_def.name
      when :date then table.date field_def.name
      when :json then table.json field_def.name
      when :array then table.string field_def.name, array: true, default: []
      when :image then table.string field_def.name # ActiveStorage attachment
      when :rich_text then table.text field_def.name # ActionText
      # Associations handled separately
      when :belongs_to then table.references field_def.name, foreign_key: field_def.options[:foreign_key]
      end
    end

    def self.create_active_record_model(content_type_class)
      # Set the table name
      content_type_class.table_name = content_type_class.config.slug.pluralize

      # Add ActiveStorage/ActionText if needed
      content_type_class.field_definitions.each do |field_def|
        case field_def.type
        when :image
          content_type_class.has_one_attached field_def.name
        when :images
          content_type_class.has_many_attached field_def.name
        when :rich_text
          content_type_class.has_rich_text field_def.name
        end
      end
    end
  end
end