# frozen_string_literal: true

# The directory itself: browsing, searching and submitting entries.
class EntriesController < ApplicationController
  PER_PAGE = 25
  POPULAR_QUERY_LIMIT = 5
  SUGGESTION_LIMIT = 5
  SUGGESTION_TYPE_LIMIT = 4
  ENTRY_FIELDS = %i[title url description image_url experience_level submitter_name submitter_email category_ids].freeze

  before_action :load_form_data, only: %i[new create]

  def index
    categories = Category.order(:display_order, :name)

    @categories = categories
    @popular_queries = categories.limit(POPULAR_QUERY_LIMIT).pluck(:name)
    assign_directory(EntryDirectoryQuery.new(params.permit(:q, :level, :category, :sort).to_h))
  end

  def start
    level = params[:level].presence || "beginner"
    categories = Category.order(:display_order, :name)

    @categories = categories
    @popular_queries = categories.limit(POPULAR_QUERY_LIMIT).pluck(:name)
    assign_directory(EntryDirectoryQuery.new(params.permit(:q, :category, :sort, :level).to_h.merge(level: level)))
  end

  def suggestions
    query = params[:q].to_s.strip
    return head :ok if query.length < 2

    @query = query
    assign_suggestions(query)

    render partial: "entries/suggestions"
  end

  def new
    @entry = Entry.new
  end

  def create
    entry = Entry.new(all_permitted_params.slice(*ENTRY_FIELDS))

    return render_invalid_entry(entry, "You can select a maximum of 3 categories") if too_many_categories?
    return render_invalid_entry(entry) unless save_entry(entry)

    notify_and_redirect(entry)
  end

  def success
    # Success confirmation page
  end

  private

  def assign_directory(directory_query)
    @query = directory_query.query
    @active_level = directory_query.level
    @active_category = directory_query.category
    @active_sort = directory_query.sort
    @entries = directory_query.call.page(params[:page]).per(PER_PAGE)
  end

  def assign_suggestions(query)
    # Sanitize LIKE wildcards to prevent LIKE injection
    pattern = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"

    @popular_queries = Category.order(:display_order, :name).limit(POPULAR_QUERY_LIMIT).pluck(:name)
    @categories = Category.where("name LIKE ?", pattern).order(:name).limit(SUGGESTION_LIMIT)
    @types = Entry.type_slugs_matching(query).first(SUGGESTION_TYPE_LIMIT)
    @entries = Entry.visible.where("title LIKE ?", pattern).order(updated_at: :desc).limit(SUGGESTION_LIMIT)
  end

  def too_many_categories?
    all_permitted_params[:category_ids].to_a.reject(&:blank?).length > Entry::MAX_CATEGORIES
  end

  # Redisplays the submission form with the entry's errors shown.
  def render_invalid_entry(entry, message = nil)
    entry.errors.add(:categories, message) if message

    @entry = entry
    flash.now[:alert] = "Please review the highlighted fields."
    render :new, status: :unprocessable_entity
  end

  # Saves the entry together with the type specific record behind it.
  def save_entry(entry)
    entryable = Entry::EntryableBuilder.new(params.dig(:entry, :resource_type), all_permitted_params).build
    entry.assign_attributes(status: :pending, published: false, entryable: entryable)

    ActiveRecord::Base.transaction { entry.save && attach_author(entry) }
  end

  def attach_author(entry)
    author = Author.find_by(id: all_permitted_params[:author_id])
    entry.authors << author if author

    true
  end

  def notify_and_redirect(entry)
    ResourceSubmissionMailer.notify_team(entry).deliver_later
    ResourceSubmissionMailer.confirm_submitter(entry).deliver_later

    redirect_to entry_success_path
  end

  def load_form_data
    @categories = Category.order(:name)
    @authors = Author.approved.order(:name)
  end

  def all_permitted_params
    @all_permitted_params ||= params.require(:entry).permit(
      # Common Entry fields
      :title,
      :url,
      :description,
      :image_url,
      :experience_level,
      :submitter_name,
      :submitter_email,
      :resource_type,
      :author_id,
      # RubyGem fields
      :gem_name,
      :github_url,
      :documentation_url,
      :rubygems_url,
      :current_version,
      :downloads_count,
      # Book fields
      :isbn,
      :publisher,
      :publication_year,
      :page_count,
      :format,
      :purchase_url,
      # Course fields
      :platform,
      :instructor,
      :duration_hours,
      :price,
      :currency,
      :is_free,
      :enrollment_url,
      # Tutorial fields
      :reading_time_minutes,
      :publication_date,
      :author_name,
      # Article fields (same as Tutorial, already covered)
      # Tool fields
      :tool_type,
      :license,
      :is_open_source,
      # Podcast fields
      :host,
      :episode_count,
      :frequency,
      :rss_feed_url,
      :spotify_url,
      :apple_podcasts_url,
      # Community fields
      :join_url,
      :member_count,
      :is_official,
      category_ids: []
    )
  end
end
