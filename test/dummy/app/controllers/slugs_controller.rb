class SlugsController < ApplicationController
  def show
    @content = BrawoCms::SlugResolver.find(params[:slug])
    return head :not_found unless @content

    render :show, locals: { content: @content, partial: @content.model_name.element }
  end
end
