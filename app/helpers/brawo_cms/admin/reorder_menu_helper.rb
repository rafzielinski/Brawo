module BrawoCms
  module Admin
    module ReorderMenuHelper
      def render_item_actions_dropdown(move_action:, remove_action:, disabled: false, extra_before_remove: [])
        content_tag(:div, class: 'dropdown item-actions-menu') do
          button_tag('⋯', type: 'button', class: 'btn btn-sm btn-light',
            disabled: disabled,
            data: { bs_toggle: 'dropdown' }, aria: { expanded: 'false' }) +
            content_tag(:ul, class: 'dropdown-menu dropdown-menu-end') do
              items = reorder_menu_items(move_action, disabled)

              if extra_before_remove.any?
                items << tag.hr(class: 'dropdown-divider')
                items.concat(extra_menu_items(extra_before_remove, disabled))
              end

              items << tag.hr(class: 'dropdown-divider')
              items << remove_menu_item(remove_action, disabled)

              safe_join(items)
            end
        end
      end

      private

      def reorder_menu_items(action, disabled)
        [
          ['up', 'Move up'],
          ['down', 'Move down'],
          ['top', 'Move to top'],
          ['bottom', 'Move to bottom']
        ].map do |direction, label|
          content_tag(:li) do
            button_tag(label, type: 'button', class: 'dropdown-item', disabled: disabled,
              data: { action: action, move_direction: direction })
          end
        end
      end

      def extra_menu_items(items, disabled)
        items.map do |item|
          content_tag(:li) do
            button_tag(item[:label], type: 'button', class: 'dropdown-item', disabled: disabled,
              data: { action: item[:action] }.merge(item.fetch(:data, {})))
          end
        end
      end

      def remove_menu_item(action, disabled)
        content_tag(:li) do
          button_tag('Remove', type: 'button', class: 'dropdown-item text-danger', disabled: disabled,
            data: { action: action })
        end
      end
    end
  end
end
