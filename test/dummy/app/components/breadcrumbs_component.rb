# frozen_string_literal: true

class BreadcrumbsComponent < ViewComponent::Base
  # crumbs: [[label, url_or_nil], ...] — nil url marks current page (no link)
  def initialize(crumbs:)
    @crumbs = crumbs
  end

  private

  attr_reader :crumbs
end
