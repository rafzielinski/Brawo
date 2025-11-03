class Article < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :article,
    label: 'Article',
    fields: [
      { name: :author, type: :string, label: 'Author', help_text: 'The name of the article author' },
      { name: :body, type: :textarea, label: 'Article Body', help_text: 'The main content of the article' },
      { name: :published_date, type: :date, label: 'Publish Date' },
      { name: :featured, type: :boolean, label: 'Featured Article' },
      { name: :category_id, type: :taxonomy, taxonomy_type: :category, label: 'Category', help_text: 'Select a category for this article' }
    ]

  # Helper method to get the category taxonomy
  def category
    @category ||= Category.find_by(id: category_id) if category_id.present?
  end

  # Helper method to get category name
  def category_name
    category&.name
  end
end

