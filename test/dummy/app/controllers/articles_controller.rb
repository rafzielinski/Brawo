class ArticlesController < ApplicationController
  def index
    @articles = Article.published.order(created_at: :desc)
  end

  def show
    @article = Article.published.find_by!(slug: params[:slug])
  end
end

