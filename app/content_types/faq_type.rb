class FaqType < Brawo::ContentType
  configure do |c|
    c.name = "FAQ"
    c.slug = "faqs"
  end

  routes do
    archive "/help/faqs"
    # No single view needed for FAQs
  end

  fields do
    field :question, :string, required: true
    field :answer, :text, required: true
    field :category, :select, choices: ['General', 'Billing', 'Technical']
    field :display_order, :integer, default: 0
  end

  scope :by_category, ->(cat) { where(category: cat) }
  default_scope { order(display_order: :asc) }
end