module BrawoCms
  module Admin
    class ContentsController < BaseController
      before_action :set_content_type
      before_action :set_content, only: [:show, :edit, :update, :destroy]

      def index
        @contents = content_class.all.order(created_at: :desc)
      end

      def show
      end

      def new
        @content = content_class.new
      end

      def edit
      end

      def create
        @content = content_class.new(content_params)

        if @content.save
          redirect_to admin_content_path(@content, content_type: params[:content_type]), 
                      notice: "#{@content_type_config[:label]} was successfully created."
        else
          render :new, status: :unprocessable_entity
        end
      end

      def update
        if @content.update(content_params)
          redirect_to admin_content_path(@content, content_type: params[:content_type]), 
                      notice: "#{@content_type_config[:label]} was successfully updated."
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @content.destroy
        redirect_to admin_contents_path(content_type: params[:content_type]), 
                    notice: "#{@content_type_config[:label]} was successfully deleted."
      end

      private

      def set_content_type
        @content_type = params[:content_type]&.to_sym
        @content_type_config = BrawoCms.content_types[@content_type]
        
        unless @content_type_config
          redirect_to admin_root_path, alert: "Content type not found" and return
        end
      end

      def set_content
        @content = content_class.find(params[:id])
      end

      def content_class
        @content_type_config[:class]
      end

      def content_params
        permitted_fields = [:title, :slug, :description, :status, :published_at]
        array_fields = {}
        repeater_field_names = []
        
        # Add custom fields from field definitions
        if @content_type_config && @content_type_config[:fields].present?
          @content_type_config[:fields].each do |field|
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
        content_params_raw = params[:content]
        repeater_data = {}
        
        if content_params_raw.present?
          # Convert to unsafe hash to access all nested parameters
          raw_hash = content_params_raw.respond_to?(:to_unsafe_h) ? content_params_raw.to_unsafe_h : content_params_raw.to_h
          
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
          # If no content params at all, initialize empty arrays for all repeaters
          repeater_field_names.each do |repeater_name|
            repeater_data[repeater_name.to_s] = []
          end
        end
        
        # Permit the base params (excluding repeater fields)
        base_params = params.require(:content).permit(*permitted_fields, array_fields)
        
        # Separate base attributes from custom field attributes
        base_attrs = base_params.slice(:title, :slug, :description, :status, :published_at).to_h
        field_attrs = base_params.except(:title, :slug, :description, :status, :published_at).to_h
        
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
          @content_type_config[:fields].find { |f| f[:name].to_s == repeater_name.to_s }
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

