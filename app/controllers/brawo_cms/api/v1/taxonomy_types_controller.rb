module BrawoCms
  module Api
    module V1
      class TaxonomyTypesController < BaseController
        def index
          types = BrawoCms.taxonomy_types.map do |name, config|
            ::BrawoCms::TypeSerializer.new(name, config).as_json
          end

          render json: types
        end

        def show
          config = BrawoCms.taxonomy_types[params[:type].to_sym]
          return head :not_found unless config

          render json: ::BrawoCms::TypeSerializer.new(params[:type], config).as_json
        end
      end
    end
  end
end
