module BrawoCms
  module Api
    module V1
      class MediaController < BaseController
        def index
          result = ::BrawoCms::MediaService.list(accept: params[:accept], q: params[:q])
          return render_result(result) if result.failure?

          payload = result.records.map do |media|
            ::BrawoCms::MediaSerializer.new(media).as_json
          end

          render body: ActiveSupport::JSON.encode(payload), content_type: "application/json"
        end

        def show
          result = ::BrawoCms::MediaService.find(id: params[:id])
          render_result(
            result,
            serializer: ->(record) { ::BrawoCms::MediaSerializer.new(record) }
          )
        end

        def create
          result = ::BrawoCms::MediaService.create(attributes: media_attributes)
          render_result(
            result,
            serializer: ->(record) { ::BrawoCms::MediaSerializer.new(record) },
            status: :created
          )
        end

        def update
          result = ::BrawoCms::MediaService.update(id: params[:id], attributes: media_attributes)
          render_result(
            result,
            serializer: ->(record) { ::BrawoCms::MediaSerializer.new(record) }
          )
        end

        def destroy
          result = ::BrawoCms::MediaService.destroy(id: params[:id])
          render_result(result, status: :no_content)
        end

        private

        def media_attributes
          if params[:media].present?
            ::BrawoCms::MediaService.build_attributes(params: params, wrap_key: :media)
          else
            hash = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
            ::BrawoCms::MediaService.build_attributes_from_hash(raw_hash: hash)
          end
        end
      end
    end
  end
end
