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
        
        # Add custom fields from field definitions
        if @taxonomy_type_config && @taxonomy_type_config[:fields].present?
          @taxonomy_type_config[:fields].each do |field|
            permitted_fields << field[:name].to_sym
          end
        end

        # Permit the params and extract custom fields into the fields hash
        base_params = params.require(:taxonomy).permit(*permitted_fields)
        
        # Separate base attributes from custom field attributes
        base_attrs = base_params.slice(:name, :slug, :description)
        field_attrs = base_params.except(:name, :slug, :description)
        
        # Build the fields hash from custom field attributes
        base_attrs[:fields] = field_attrs.to_h if field_attrs.present?
        
        base_attrs
      end
    end
  end
end

