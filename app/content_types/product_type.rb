class ProductType < Brawo::ContentType
  configure do |c|
    c.name = "Product"
    c.slug = "products"
    c.icon = "shopping-cart"
  end

  routes do
    archive "/shop"
    single "/shop/:slug"
  end

  fields do
    field :name, :string, required: true
    field :description, :text
    field :price, :decimal, precision: 10, scale: 2, required: true
    field :compare_at_price, :decimal, precision: 10, scale: 2
    field :sku, :string, unique: true, required: true
    field :stock_quantity, :integer, default: 0
    field :weight, :decimal
    field :dimensions, :json
    field :product_images, :images, multiple: true
    field :vendor, :belongs_to, class_name: 'Vendor'
    field :categories, :has_many, through: :product_categories
  end

  # Virtual attributes
  def on_sale?
    compare_at_price.present? && compare_at_price > price
  end

  def discount_percentage
    return 0 unless on_sale?
    ((compare_at_price - price) / compare_at_price * 100).round
  end

  def in_stock?
    stock_quantity > 0
  end

  def formatted_price
    "$#{price}"
  end

  # Class methods
  def self.bestsellers(limit = 10)
    # Assuming you have sales tracking
    joins(:orders).group(:id).order('COUNT(orders.id) DESC').limit(limit)
  end

  def self.on_sale
    where.not(compare_at_price: nil).where('compare_at_price > price')
  end
end