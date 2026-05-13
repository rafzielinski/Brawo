# frozen_string_literal: true

class ArticleCardComponent < ViewComponent::Base
  with_collection_parameter :article

  def initialize(article:)
    @article = article
  end

  private

  attr_reader :article
end
