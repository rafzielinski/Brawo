module BrawoCms
  module Fields
    class BlocksField < BrawoCms::Field
      def render_input_field(form, options, object)
        current_value = get_value(object) || []
        current_value = Array(current_value) unless current_value.is_a?(Array)

        helper = page_builder_view_helper(options)
        available_blocks = BrawoCms.blocks_for(object.content_type_name.to_sym)
        helper.render_page_builder(form, @name, current_value, label: @label, available_blocks: available_blocks)
      end

      private

      def page_builder_view_helper(options)
        helper = options[:helper]
        return helper if helper&.respond_to?(:render_page_builder)

        ActionController::Base.helpers.tap do |view_helper|
          view_helper.extend(BrawoCms::Admin::PageBuilderHelper)
        end
      end

      public

      def format_value(value)
        return empty_display_value unless value.present?

        value = Array(value)
        return empty_display_value if value.empty?

        helper = ActionController::Base.helpers
        helper.content_tag(:div, class: 'blocks-display') do
          helper.safe_join(value.map.with_index do |block, index|
            block = block.with_indifferent_access
            type_config = BrawoCms.block_type(block[:type])
            label = type_config ? type_config[:label] : block[:type].to_s.humanize

            helper.content_tag(:div, class: 'card mb-2') do
              helper.content_tag(:div, class: 'card-body p-2') do
                helper.content_tag(:small, class: 'text-muted') { "#{index + 1}. #{label}" }
              end
            end
          end)
        end
      end
    end
  end
end
