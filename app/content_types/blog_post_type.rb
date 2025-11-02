class BlogPostType < Brawo::ContentType
  # Metadata
  configure do |c|
    c.name = "Blog Post"
    c.slug = "blog"
    c.icon = "newspaper"
    c.description = "Articles and blog content"
  end

  # Routing (gem auto-generates actual routes)
  routes do
    archive "/blog"
    single "/blog/:slug"
  end

  # Field definitions (gem auto-generates table columns)
  fields do
    field :title, :string, required: true
    field :subtitle, :string
    field :content, :rich_text, required: true
    field :excerpt, :text
    field :reading_time, :integer
    field :featured, :boolean, default: false
    field :category, :select, choices: ['Technology', 'Design', 'Business']
    field :tags, :array, of: :string
    field :published_at, :datetime
    field :author, :belongs_to, class_name: 'User'
    field :featured_image, :image
  end

  # Validations
  validates :reading_time, numericality: { greater_than: 0 }, allow_nil: true
  validates :category, presence: true

  # Scopes
  scope :featured, -> { where(featured: true) }
  scope :by_category, ->(cat) { where(category: cat) }
  scope :recent, -> { order(published_at: :desc).limit(10) }

  # Custom methods (available on all blog post instances)
  def reading_time_text
    "#{reading_time} min read"
  end

  def has_tags?
    tags.present? && tags.any?
  end

  def related_posts(limit = 3)
    self.class.where(category: category)
              .where.not(id: id)
              .published
              .limit(limit)
  end

  # Callbacks
  before_save :calculate_reading_time
  after_publish :notify_subscribers

  private

  def calculate_reading_time
    return unless content.present?
    word_count = content.to_plain_text.split.size
    self.reading_time = (word_count / 200.0).ceil
  end

  def notify_subscribers
    # Custom logic here
  end
end