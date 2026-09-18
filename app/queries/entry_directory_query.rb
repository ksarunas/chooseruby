# frozen_string_literal: true

# Finds visible entries for the public directory.
#
# Reads the search, type, level, category and sort parameters of a directory
# request and turns them into a single Entry relation.
class EntryDirectoryQuery
  POPULARITY_ORDER = <<~SQL.squish
    COALESCE(
      CASE entries.entryable_type
        WHEN 'RubyGem' THEN (SELECT downloads_count FROM ruby_gems WHERE ruby_gems.id = entries.entryable_id)
        WHEN 'Community' THEN (SELECT member_count FROM communities WHERE communities.id = entries.entryable_id)
        WHEN 'Podcast' THEN (SELECT episode_count FROM podcasts WHERE podcasts.id = entries.entryable_id)
        ELSE NULL
      END,
      0
    ) DESC,
    entries.updated_at DESC
  SQL

  BEGINNER_FIRST_ORDER = <<~SQL.squish
    experience_level = 'beginner' DESC,
    experience_level = 'intermediate' DESC,
    experience_level = 'advanced' DESC,
    entries.updated_at DESC
  SQL

  # Sort names that replace the default ordering outright.
  REORDERINGS = {
    "popular" => Arel.sql(POPULARITY_ORDER),
    "oldest" => { updated_at: :asc },
    "beginner_first" => Arel.sql(BEGINNER_FIRST_ORDER)
  }.freeze

  attr_reader :category

  def initialize(params = {}, scope: Entry.visible.with_directory_includes)
    @params = params.to_h.symbolize_keys
    @scope = scope
    @category = locate_category
  end

  def call
    filtered_scope
  end

  def query
    @params[:q].to_s.strip
  end

  def level
    @params[:level].presence
  end

  def type
    @params[:type].to_s.strip.presence
  end

  def sort
    @params[:sort].to_s.strip.presence || "recent"
  end

  private

  attr_reader :scope

  def locate_category
    slug = @params[:category]
    return if slug.blank?

    Category.find_by(slug:)
  end

  def filtered_scope
    apply_sort(filtered_entries).distinct
  end

  def filtered_entries
    scope
      .then { |current| filter_by_query(current) }
      .then { |current| filter_by_type(current) }
      .then { |current| filter_by_level(current) }
      .then { |current| filter_by_category(current) }
  end

  def filter_by_query(current_scope)
    return current_scope if query.blank?

    # Join to FTS5 virtual table and filter by MATCH query
    # Order by FTS5 BM25 relevance (rank), then by updated_at for ties
    current_scope
      .joins("JOIN entries_fts ON entries_fts.entry_id = entries.id")
      .where("entries_fts MATCH ?", FtsQuery.new(query, operators: FtsQuery::OPERATORS_WITH_APOSTROPHE).to_s)
      .order("entries_fts.rank, entries.updated_at DESC")
  end

  def filter_by_type(current_scope)
    mapped_type = Entry::VALID_TYPES[type]
    return current_scope if mapped_type.blank?

    current_scope.where(entryable_type: mapped_type)
  end

  def filter_by_level(current_scope)
    current_scope.at_experience_level(level)
  end

  def filter_by_category(current_scope)
    return current_scope if category.blank?

    current_scope.joins(:categories).where(categories: { id: category.id })
  end

  def apply_sort(current_scope)
    reordering = REORDERINGS[sort]
    return current_scope.reorder(reordering) if reordering

    # An FTS5 search already orders by relevance, so leave that ordering alone.
    return current_scope if query.present?

    current_scope.order(updated_at: :desc)
  end
end
