# frozen_string_literal: true

# Admin screens for the people credited on directory entries.
class Avo::Resources::Author < Avo::BaseResource
  self.title = :name
  self.includes = []

  # Enable fuzzy search on name field
  self.search = {
    query: -> {
      sanitized_query = ActiveRecord::Base.sanitize_sql_like(params[:q])
      query.where("name LIKE ?", "%#{sanitized_query}%")
    }
  }

  # Authorization is explicitly disabled for now (set to nil in initializer)
  # This can be configured later with Pundit or other authorization systems

  def fields
    profile_fields
    avatar_fields
    link_fields
    association_fields
  end

  def filters
    filter Avo::Filters::AuthorStatusFilter
  end

  def actions
    action Avo::Actions::ApproveAuthors
  end

  private

  def profile_fields
    field :id, as: :id, link_to_record: true
    field :name, as: :text, required: true, sortable: true
    field :bio, as: :textarea, rows: 5
    field :status, as: :select, enum: ::Author.statuses, required: true, sortable: true
    field :slug, as: :text, readonly: true, help: "Auto-generated from name"
  end

  def avatar_fields
    field :avatar, as: :file, help: "Manual upload (fallback if no GitHub URL)"
    field :avatar_url, as: :text, readonly: true, help: "Auto-fetched from GitHub URL", hide_on: [ :index ]
  end

  def link_fields
    code_hosting_link_fields
    social_link_fields
    publishing_link_fields
  end

  def code_hosting_link_fields
    field :github_url, as: :text, hide_on: [ :index ]
    field :gitlab_url, as: :text, hide_on: [ :index ]
    field :website_url, as: :text, hide_on: [ :index ]
  end

  def social_link_fields
    field :bluesky_url, as: :text, hide_on: [ :index ]
    field :ruby_social_url, as: :text, hide_on: [ :index ]
    field :twitter_url, as: :text, hide_on: [ :index ]
    field :linkedin_url, as: :text, hide_on: [ :index ]
  end

  def publishing_link_fields
    field :youtube_url, as: :text, hide_on: [ :index ]
    field :twitch_url, as: :text, hide_on: [ :index ]
    field :blog_url, as: :text, hide_on: [ :index ]
  end

  def association_fields
    field :entries, as: :has_many, through: :entries_authors, hide_on: [ :index ]

    timestamp_fields
  end

  def timestamp_fields
    field :created_at, as: :date_time, readonly: true, hide_on: [ :index ]
    field :updated_at, as: :date_time, readonly: true, hide_on: [ :index ]
  end
end
