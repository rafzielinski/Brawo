module Brawo
  module Admin
    class ContentEntriesController < Brawo::AdminController
    before_action :set_content_type
    before_action :set_entry, only: [:show, :edit, :update, :destroy]
    
    def index
      @entries = @content_type_class.all.order(created_at: :desc)
    end
    
    def show
    end
    
    def new
      @entry = @content_type_class.new
    end
    
    def create
      @entry = @content_type_class.new(entry_params)
      @entry.slug ||= generate_slug(@entry)
      
      if @entry.save
        redirect_to brawo.content_entries_path(@content_type_slug), 
                    notice: "#{@content_type_config.name} was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end
    
    def edit
    end
    
    def update
      if @entry.update(entry_params)
        redirect_to brawo.content_entries_path(@content_type_slug), 
                    notice: "#{@content_type_config.name} was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @entry.destroy
      redirect_to brawo.content_entries_path(@content_type_slug), 
                  notice: "#{@content_type_config.name} was successfully deleted."
    end
    
    private
    
    def set_content_type
      @content_type_slug = params[:content_type_slug]
      @content_type_class = Brawo::Registry.find(@content_type_slug)
      
      unless @content_type_class
        redirect_to brawo.admin_dashboard_path, alert: "Content type not found"
      end
      
      @content_type_config = @content_type_class.config
      @field_definitions = @content_type_class.field_definitions
    end
    
    def set_entry
      @entry = @content_type_class.find(params[:id])
    end
    
    def entry_params
      # Build permitted params from field definitions
      permitted_fields = @field_definitions.map do |field_def|
        case field_def.type
        when :array
          { field_def.name => [] }
        when :image, :images
          field_def.name
        else
          field_def.name
        end
      end
      
      # Add base fields
      permitted_fields += [:slug, :status, :published_at, :author_id]
      
      params.require(@content_type_slug.singularize.to_sym).permit(*permitted_fields)
    end
    
    def generate_slug(entry)
      # Try to generate slug from title field if it exists
      base_slug = if entry.respond_to?(:title) && entry.title.present?
        entry.title.parameterize
      else
        "entry-#{Time.current.to_i}"
      end
      
      # Ensure uniqueness
      slug = base_slug
      counter = 1
      while @content_type_class.exists?(slug: slug)
        slug = "#{base_slug}-#{counter}"
        counter += 1
      end
      
      slug
    end
    end
  end
end