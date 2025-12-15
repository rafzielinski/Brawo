module BrawoCms
  module Admin
    class TaxonomiesController < BaseController
      before_action :set_taxonomy_type
      before_action :set_taxonomy, only: [:show, :edit, :update, :destroy]

      def index
        @taxonomies = taxonomy_class.all.order(created_at: :desc)
      end

      def show
      end

      def new
        @taxonomy = taxonomy_class.new
      end

      def edit
      end

      def create
        @taxonomy = taxonomy_class.new(taxonomy_params)

        if @taxonomy.save
          redirect_to admin_taxonomy_path(@taxonomy, taxonomy_type: params[:taxonomy_type]), 
                      notice: "#{@taxonomy_type_config[:label]} was successfully created."
        else
          render :new, status: :unprocessable_entity
        end
      end

      def update
        if @taxonomy.update(taxonomy_params)
          redirect_to admin_taxonomy_path(@taxonomy, taxonomy_type: params[:taxonomy_type]), 
                      notice: "#{@taxonomy_type_config[:label]} was successfully updated."
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @taxonomy.destroy
        redirect_to admin_taxonomies_path(taxonomy_type: params[:taxonomy_type]), 
                    notice: "#{@taxonomy_type_config[:label]} was successfully deleted."
      end

      private

      def set_taxonomy_type
        @taxonomy_type = params[:taxonomy_type]&.to_sym
        @taxonomy_type_config = BrawoCms.taxonomy_types[@taxonomy_type]
        
        unless @taxonomy_type_config
          redirect_to admin_root_path, alert: "Taxonomy type not found" and return
        end
      end

      def set_taxonomy
        @taxonomy = taxonomy_class.find(params[:id])
      end

      def taxonomy_class
        @taxonomy_type_config[:class]
      end

      def taxonomy_params
        permitted_fields = [:name, :slug, :description]
        array_fields = {}
        repeater_field_names = []
        
        # Add custom fields from field definitions
        if @taxonomy_type_config && @taxonomy_type_config[:fields].present?
          @taxonomy_type_config[:fields].each do |field|
            if field[:type] == :reference
              # For reference fields, permit as array
              array_fields[field[:name]] = []
            elsif field[:type] == :repeater
              # Track repeater field names for special processing
              repeater_field_names << field[:name].to_sym
            else
              permitted_fields << field[:name].to_sym
            end
          end
        end

        # Extract repeater fields BEFORE permitting (to get raw nested params)
        taxonomy_params_raw = params[:taxonomy]
        repeater_data = {}
        
        if taxonomy_params_raw.present?
          # Convert to unsafe hash to access all nested parameters
          raw_hash = taxonomy_params_raw.respond_to?(:to_unsafe_h) ? taxonomy_params_raw.to_unsafe_h : taxonomy_params_raw.to_h
          
          repeater_field_names.each do |repeater_name|
            # Try both string and symbol keys
            repeater_param = raw_hash[repeater_name.to_s] || raw_hash[repeater_name.to_sym] || raw_hash[repeater_name]
            
            if repeater_param.present? && repeater_param.is_a?(Hash)
              # Process repeater recursively (handles nested repeaters)
              repeater_data[repeater_name.to_s] = process_repeater_field(repeater_param, repeater_name)
            else
              # Save empty array if repeater field is not present or empty
              repeater_data[repeater_name.to_s] = []
            end
          end
        else
          # If no taxonomy params at all, initialize empty arrays for all repeaters
          repeater_field_names.each do |repeater_name|
            repeater_data[repeater_name.to_s] = []
          end
        end
        
        # Permit the base params (excluding repeater fields)
        base_params = params.require(:taxonomy).permit(*permitted_fields, array_fields)
        
        # Separate base attributes from custom field attributes
        base_attrs = base_params.slice(:name, :slug, :description).to_h
        field_attrs = base_params.except(:name, :slug, :description).to_h
        
        # Merge repeater data into field_attrs
        # Always merge repeater_data, even if field_attrs is empty
        all_field_attrs = field_attrs.merge(repeater_data)
        
        # Always set fields hash (convert to plain hash to ensure proper JSONB storage)
        # Use deep_stringify_keys to ensure all nested keys are strings
        base_attrs[:fields] = all_field_attrs.deep_stringify_keys
        
        base_attrs
      end

      # Recursively process repeater field data, handling nested repeaters
      def process_repeater_field(repeater_param, repeater_name, parent_field_def = nil)
        return [] unless repeater_param.is_a?(Hash)
        
        # Get field definition - either from parent's sub_fields or top-level fields
        field_def = if parent_field_def
          # Nested repeater - find in parent's sub_fields
          parent_field_def[:sub_fields]&.find { |f| f[:name].to_s == repeater_name.to_s }
        else
          # Top-level repeater - find in top-level fields
          @taxonomy_type_config[:fields].find { |f| f[:name].to_s == repeater_name.to_s }
        end
        
        return [] unless field_def
        
        sub_fields = field_def[:sub_fields] || []
        
        # Process each repeater row - sort keys to maintain order
        repeater_param.keys.sort_by { |k| k.to_i }.map do |index|
          row_data = repeater_param[index]
          next nil unless row_data.is_a?(Hash)
          
          # Convert to hash if it's ActionController::Parameters
          row_data = row_data.respond_to?(:to_unsafe_h) ? row_data.to_unsafe_h : row_data.to_h
          
          # Process each sub-field
          processed_row = {}
          sub_fields.each do |sub_field_def|
            sub_field_name = sub_field_def[:name].to_s
            sub_field_type = sub_field_def[:type]
            
            # Try both string and symbol keys
            value = row_data[sub_field_name] || row_data[sub_field_name.to_sym]
            
            if sub_field_type == :repeater && value.is_a?(Hash)
              # Recursively process nested repeater, passing current field_def as parent
              processed_row[sub_field_name] = process_repeater_field(value, sub_field_name, field_def)
            else
              # Regular field - include value (including empty strings, false, 0, nil)
              # Include nil values too so required fields that are empty are still saved
              # HTML5 validation will prevent submission if required fields are empty
              processed_row[sub_field_name] = value
            end
          end
          
          # Only filter out rows that are completely empty (no fields at all)
          # Don't filter based on required fields - let HTML5 validation handle that
          processed_row.present? ? processed_row.stringify_keys : nil
        end.compact
      end
    end
  end
end

