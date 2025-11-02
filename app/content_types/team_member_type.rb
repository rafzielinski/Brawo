class TeamMemberType < Brawo::ContentType
  configure do |c|
    c.name = "Team Member"
    c.slug = "team"
  end

  routes do
    archive "/team"
    single "/team/:slug"
  end

  fields do
    field :name, :string, required: true
    field :role, :string, required: true
    field :bio, :text
    field :photo, :image
    field :email, :string
    field :linkedin_url, :string
    field :twitter_handle, :string
    field :display_order, :integer, default: 0
  end

  default_scope { order(display_order: :asc) }

  def social_links
    {
      linkedin: linkedin_url,
      twitter: twitter_url
    }.compact
  end

  def twitter_url
    return nil unless twitter_handle.present?
    "https://twitter.com/#{twitter_handle.delete_prefix('@')}"
  end
end