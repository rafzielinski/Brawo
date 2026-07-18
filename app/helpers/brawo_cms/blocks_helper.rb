module BrawoCms
  module BlocksHelper
    def render_blocks(blocks)
      return '' if blocks.blank?

      safe_join(Array(blocks).map { |block| render_block(block) })
    end

    def render_block(block)
      block = block.with_indifferent_access
      block_type = block[:type]
      data = block[:data] || {}
      type_config = BrawoCms.block_type(block_type)
      partial = type_config ? type_config[:partial] : block_type

      render partial: "brawo_cms/blocks/#{partial}", locals: { data: data.with_indifferent_access }
    rescue ActionView::MissingTemplate
      content_tag(:div, class: 'alert alert-warning') do
        "Missing block partial for: #{block_type}"
      end
    end
  end
end
