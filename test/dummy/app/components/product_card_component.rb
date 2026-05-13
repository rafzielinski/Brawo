# frozen_string_literal: true

class ProductCardComponent < ViewComponent::Base
  with_collection_parameter :product

  def initialize(product:)
    @product = product
  end

  private

  attr_reader :product
end
