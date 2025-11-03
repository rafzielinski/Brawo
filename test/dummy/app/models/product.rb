class Product < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :product,
    label: 'Product',
    fields: [
      { name: :price, type: :number, label: 'Price', help_text: 'Product price in USD' },
      { name: :sku, type: :string, label: 'SKU', help_text: 'Stock keeping unit' },
      { name: :stock_quantity, type: :integer, label: 'Stock Quantity' },
      { name: :product_description, type: :textarea, label: 'Description' },
      { name: :featured_product, type: :boolean, label: 'Featured' },
      { name: :availability, type: :select, label: 'Availability', choices: [['In Stock', 'in_stock'], ['Out of Stock', 'out_of_stock'], ['Pre-order', 'preorder']] }
    ]
end

