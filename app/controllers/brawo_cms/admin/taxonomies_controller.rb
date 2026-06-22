module BrawoCms
  module Admin
    class TaxonomiesController < BaseController
      before_action :set_taxonomy_type
      before_action :set_taxonomy, only: [:show, :edit, :update, :destroy]

      def index
        result = ::BrawoCms::TaxonomyService.list(type: @taxonomy_type)
        @taxonomies = result.records
      end

      def show
      end

      def new
        @taxonomy = taxonomy_class.new
      end

      def edit
      end

      def create
        result = ::BrawoCms::TaxonomyService.create(type: @taxonomy_type, attributes: taxonomy_params)

        if result.success?
          redirect_to admin_taxonomy_path(result.record, taxonomy_type: params[:taxonomy_type]),
                      notice: "#{@taxonomy_type_config[:label]} was successfully created."
        else
          @taxonomy = result.record
          render :new, status: :unprocessable_entity
        end
      end

      def update
        result = ::BrawoCms::TaxonomyService.update(
          type: @taxonomy_type,
          id: params[:id],
          attributes: taxonomy_params
        )

        if result.success?
          redirect_to admin_taxonomy_path(result.record, taxonomy_type: params[:taxonomy_type]),
                      notice: "#{@taxonomy_type_config[:label]} was successfully updated."
        else
          @taxonomy = result.record
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        ::BrawoCms::TaxonomyService.destroy(type: @taxonomy_type, id: params[:id])
        redirect_to admin_taxonomies_path(taxonomy_type: params[:taxonomy_type]),
                    notice: "#{@taxonomy_type_config[:label]} was successfully deleted."
      end

      private

      def set_taxonomy_type
        @taxonomy_type = params[:taxonomy_type]&.to_sym
        @taxonomy_type_config = ::BrawoCms::TaxonomyService.type_config(@taxonomy_type)

        unless @taxonomy_type_config
          redirect_to admin_root_path, alert: "Taxonomy type not found" and return
        end
      end

      def set_taxonomy
        result = ::BrawoCms::TaxonomyService.find(type: @taxonomy_type, id: params[:id])

        if result.success?
          @taxonomy = result.record
        else
          redirect_to admin_taxonomies_path(taxonomy_type: params[:taxonomy_type]), alert: "Taxonomy not found"
        end
      end

      def taxonomy_class
        @taxonomy_type_config[:class]
      end

      def taxonomy_params
        ::BrawoCms::TaxonomyService.build_attributes(
          type_config: @taxonomy_type_config,
          params: params,
          wrap_key: :taxonomy
        )
      end
    end
  end
end
