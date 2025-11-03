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
        
        # Add custom fields from field definitions
        if @content_type_config && @content_type_config[:fields].present?
          @content_type_config[:fields].each do |field|
            permitted_fields << field[:name].to_sym
          end
        end

        # Permit the params and extract custom fields into the fields hash
        base_params = params.require(:content).permit(*permitted_fields)
        
        # Separate base attributes from custom field attributes
        base_attrs = base_params.slice(:title, :slug, :description, :status, :published_at)
        field_attrs = base_params.except(:title, :slug, :description, :status, :published_at)
        
        # Build the fields hash from custom field attributes
        base_attrs[:fields] = field_attrs.to_h if field_attrs.present?
        
        base_attrs
      end
    end
  end
end

