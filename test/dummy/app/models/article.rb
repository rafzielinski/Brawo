class Article < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :article,
    label: 'Article',
    tabs: [
      {
        key: :content,
        fields: [
          {
            name: :author,
            type: :string,
            label: 'Author',
            help_text: 'The name of the article author'
          },
          {
            name: :body,
            type: :textarea,
            label: 'Article Body',
            help_text: 'The main content of the article'
          },
          {
            name: :published_date,
            type: :date,
            label: 'Publish Date'
          },
          {
            name: :featured,
            type: :boolean,
            label: 'Featured Article'
          },
          {
            name: :category_id,
            type: :taxonomy,
            taxonomy_type: :category,
            label: 'Category',
            help_text: 'Select a category for this article'
          },
          {
            name: :related_products,
            type: :reference,
            model_class: 'Product',
            label: 'Related Products',
            help_text: 'Select related products for this article'
          },
          {
            name: :faq_items,
            type: :repeater,
            label: 'FAQ Items',
            sub_fields: [
              {
                name: :question,
                type: :string,
                label: 'Question',
                wrapper: {
                  width: '50'
                }
              },
              {
                name: :answer,
                type: :textarea,
                label: 'Answer',
                wrapper: {
                  width: '50'
                }
              },
              { name: :sub_items, type: :repeater, label: 'Sub Items',
                sub_fields: [
                  {
                    name: :sub_item_question,
                    type: :string,
                    required: true,
                    label: 'Sub Item Question',
                    wrapper: {
                      width: '50'
                    }
                  },
                  {
                    name: :sub_item_answer,
                    type: :textarea,
                    label: 'Sub Item Answer'
                  },
                ]
              },
              { name: :published, type: :boolean, label: 'Published' }
            ]
          }
        ]
      },
      { seo: true }
    ]

  # Helper method to get the category taxonomy
  def category
    @category ||= Category.find_by(id: category_id) if category_id.present?
  end

  # Helper method to get category name
  def category_name
    category&.name
  end

  # Helper method to get related products
  def related_products_list
    return [] if related_products.blank?
    Product.where(id: related_products)
  end
end
