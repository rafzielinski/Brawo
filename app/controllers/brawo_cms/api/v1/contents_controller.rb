module BrawoCms
  module Api
    module V1
      class ContentsController < BaseController
        before_action :set_content_type

        def index
          result = ::BrawoCms::ContentService.list(type: @content_type)
          return render_result(result) if result.failure?

          payload = result.records.map do |content|
            ::BrawoCms::ContentSerializer.new(content, content_type: @content_type).as_json
          end

          render body: ActiveSupport::JSON.encode(payload), content_type: "application/json"
        end

        def show
          result = ::BrawoCms::ContentService.find(type: @content_type, id: params[:id])
          render_result(
            result,
            serializer: ->(record) { ::BrawoCms::ContentSerializer.new(record, content_type: @content_type) }
          )
        end

        def create
          result = ::BrawoCms::ContentService.create(type: @content_type, attributes: content_attributes)
          render_result(
            result,
            serializer: ->(record) { ::BrawoCms::ContentSerializer.new(record, content_type: @content_type) },
            status: :created
          )
        end

        def update
          result = ::BrawoCms::ContentService.update(
            type: @content_type,
            id: params[:id],
            attributes: content_attributes
          )
          render_result(
            result,
            serializer: ->(record) { ::BrawoCms::ContentSerializer.new(record, content_type: @content_type) }
          )
        end

        def destroy
          result = ::BrawoCms::ContentService.destroy(type: @content_type, id: params[:id])
          render_result(result, status: :no_content)
        end

        private

        def set_content_type
          @content_type = params[:content_type]&.to_sym
          @content_type_config = ::BrawoCms::ContentService.type_config(@content_type)

          head :not_found unless @content_type_config
        end

        def content_attributes
          raw = params[:content].presence || params
          hash = raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw.to_h

          ::BrawoCms::ContentService.build_attributes_from_hash(
            type_config: @content_type_config,
            raw_hash: hash
          )
        end
      end
    end
  end
end
