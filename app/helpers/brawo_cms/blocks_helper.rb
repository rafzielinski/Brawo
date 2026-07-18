module BrawoCms
  module BlocksHelper
    def render_blocks(blocks)
      return '' if blocks.blank?

      safe_join(Array(blocks).filter_map { |block| render_block(block) })
    end

    def render_block(block)
      block = block.with_indifferent_access
      block_type = block[:type]
      data = (block[:data] || {}).with_indifferent_access
      type_config = BrawoCms.block_type(block_type)
      return nil unless type_config

      if type_config[:render_template].present?
        render(file: type_config[:render_template], locals: { data: data }, layout: false)
      else
        render_legacy_partial(block_type, data)
      end
    end

    private

    def render_legacy_partial(block_type, data)
      partial = BrawoCms.block_type(block_type)&.dig(:partial) || block_type
      render partial: "brawo_cms/blocks/#{partial}", locals: { data: data }
    rescue ActionView::MissingTemplate
      nil
    end
  end
end
