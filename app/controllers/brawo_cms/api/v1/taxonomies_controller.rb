module BrawoCms
  module Api
    module V1
      class TaxonomiesController < BaseController
        before_action :set_taxonomy_type

        def index
          result = ::BrawoCms::TaxonomyService.list(type: @taxonomy_type)
          return render_result(result) if result.failure?

          payload = result.records.map do |taxonomy|
            ::BrawoCms::TaxonomySerializer.new(taxonomy, taxonomy_type: @taxonomy_type).as_json
          end

          render body: ActiveSupport::JSON.encode(payload), content_type: "application/json"
        end

        def show
          result = ::BrawoCms::TaxonomyService.find(type: @taxonomy_type, id: params[:id])
          render_result(
            result,
            serializer: ->(record) { ::BrawoCms::TaxonomySerializer.new(record, taxonomy_type: @taxonomy_type) }
          )
        end

        def create
          result = ::BrawoCms::TaxonomyService.create(type: @taxonomy_type, attributes: taxonomy_attributes)
          render_result(
            result,
            serializer: ->(record) { ::BrawoCms::TaxonomySerializer.new(record, taxonomy_type: @taxonomy_type) },
            status: :created
          )
        end

        def update
          result = ::BrawoCms::TaxonomyService.update(
            type: @taxonomy_type,
            id: params[:id],
            attributes: taxonomy_attributes
          )
          render_result(
            result,
            serializer: ->(record) { ::BrawoCms::TaxonomySerializer.new(record, taxonomy_type: @taxonomy_type) }
          )
        end

        def destroy
          result = ::BrawoCms::TaxonomyService.destroy(type: @taxonomy_type, id: params[:id])
          render_result(result, status: :no_content)
        end

        private

        def set_taxonomy_type
          @taxonomy_type = params[:taxonomy_type]&.to_sym
          @taxonomy_type_config = ::BrawoCms::TaxonomyService.type_config(@taxonomy_type)

          head :not_found unless @taxonomy_type_config
        end

        def taxonomy_attributes
          raw = params[:taxonomy].presence || params
          hash = raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw.to_h

          ::BrawoCms::TaxonomyService.build_attributes_from_hash(
            type_config: @taxonomy_type_config,
            raw_hash: hash
          )
        end
      end
    end
  end
end
