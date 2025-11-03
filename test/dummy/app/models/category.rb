class Category < BrawoCms::Taxonomy
  include BrawoCms::TaxonomyTypeable

  taxonomy_type :category,
    label: 'Category',
    fields: [
      { name: :color, type: :string, label: 'Color', help_text: 'Hex color code for this category' },
      { name: :icon, type: :string, label: 'Icon Class', help_text: 'CSS class for the category icon' },
      { name: :order, type: :number, label: 'Sort Order', help_text: 'Order in which categories should be displayed' }
    ]
end

