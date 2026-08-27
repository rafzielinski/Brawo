module BrawoCms
  module Api
    module V1
      class BaseController < ActionController::API
        before_action :authenticate_api_token!

        private

        def authenticate_api_token!
          token = BrawoCms.api_token
          return if token.blank?

          provided = request.authorization&.sub(/\ABearer /i, "")
          head :unauthorized unless ActiveSupport::SecurityUtils.secure_compare(provided.to_s, token.to_s)
        end

        def render_result(result, serializer: nil, status: :ok)
          if result.success?
            if serializer && result.record
              payload = serializer.is_a?(Proc) ? serializer.call(result.record) : serializer.new(result.record)
              render json: payload.as_json, status: status
            else
              head status
            end
          else
            render json: { errors: result.errors }, status: error_status(result)
          end
        end

        def error_status(result)
          case result.error_code
          when :not_found then :not_found
          else :unprocessable_content
          end
        end
      end
    end
  end
end
