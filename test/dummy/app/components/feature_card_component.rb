# frozen_string_literal: true

class FeatureCardComponent < ViewComponent::Base
  def initialize(title:, body:, link_text:, url:, button_class: "btn-primary")
    @title = title
    @body = body
    @link_text = link_text
    @url = url
    @button_class = button_class
  end

  private

  attr_reader :title, :body, :link_text, :url, :button_class
end
