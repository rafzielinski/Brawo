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
        repeater_fields = {}
        
        # Add custom fields from field definitions
        if @content_type_config && @content_type_config[:fields].present?
          @content_type_config[:fields].each do |field|
            if field[:type] == :reference
              # For reference fields, permit as array
              array_fields[field[:name]] = []
            elsif field[:type] == :repeater
              # For repeater fields, build nested structure for sub_fields
              repeater_structure = {}
              sub_fields = field[:sub_fields] || field[:fields] || []
              if sub_fields.present?
                sub_fields.each do |sub_field|
                  if sub_field[:type] == :reference
                    repeater_structure[sub_field[:name]] = []
                  else
                    repeater_structure[sub_field[:name]] = nil
                  end
                end
              end
              repeater_fields[field[:name]] = repeater_structure
            else
              permitted_fields << field[:name].to_sym
            end
          end
        end

        # Permit the params and extract custom fields into the fields hash
        base_params = params.require(:content).permit(*permitted_fields, array_fields, repeater_fields)
        
        # Separate base attributes from custom field attributes
        base_attrs = base_params.slice(:title, :slug, :description, :status, :published_at)
        field_attrs = base_params.except(:title, :slug, :description, :status, :published_at)
        
        # Process repeater fields - convert from hash with numeric keys to array
        processed_field_attrs = {}
        field_attrs.each do |key, value|
          if repeater_fields.key?(key.to_sym)
            # Convert hash like { "0" => {...}, "1" => {...} } to array
            if value.is_a?(Hash)
              processed_rows = []
              value.keys.sort.each do |row_index|
                row_data = value[row_index]
                next if row_data.blank?
                
                # Process each row - handle reference fields (arrays) and other fields
                processed_row = {}
                row_data.each do |sub_field_name, sub_field_value|
                  # Check if this sub_field is a reference type (should be array)
                  field_def = @content_type_config[:fields].find { |f| f[:name].to_s == key.to_s }
                  if field_def && field_def[:type] == :repeater && field_def[:sub_fields]
                    sub_field_def = field_def[:sub_fields].find { |sf| sf[:name].to_s == sub_field_name.to_s }
                    if sub_field_def && sub_field_def[:type] == :reference
                      # Reference fields should be arrays
                      processed_row[sub_field_name] = Array(sub_field_value).compact
                    else
                      processed_row[sub_field_name] = sub_field_value
                    end
                  else
                    processed_row[sub_field_name] = sub_field_value
                  end
                end
                processed_rows << processed_row unless processed_row.values.all?(&:blank?)
              end
              processed_field_attrs[key] = processed_rows
            else
              processed_field_attrs[key] = []
            end
          else
            processed_field_attrs[key] = value
          end
        end
        
        # Build the fields hash from custom field attributes
        base_attrs[:fields] = processed_field_attrs if processed_field_attrs.present?
        
        base_attrs
      end
    end
  end
end

