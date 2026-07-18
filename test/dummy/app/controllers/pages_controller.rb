class PagesController < ApplicationController
  def home
  end

  def show
    @page = Page.published.find_by!(slug: params[:slug])
  end
end
