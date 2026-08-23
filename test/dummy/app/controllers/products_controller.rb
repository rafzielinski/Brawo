class ProductsController < ApplicationController
  def index
    @products = Product.published.order(created_at: :desc)
  end

  def show
    @product = Product.published.find_by!(slug: params[:slug])
  end
end

