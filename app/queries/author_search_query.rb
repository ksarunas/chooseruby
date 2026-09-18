# frozen_string_literal: true

# Finds approved authors for the public author directory.
#
# Applies the optional full text search term taken from the request params and
# annotates every row with the number of entries the author contributed to.
class AuthorSearchQuery
  def initialize(params = {}, scope: Author.approved)
    @params = params.to_h.symbolize_keys
    @scope = scope
  end

  def call
    filtered_scope
  end

  def query
    @query ||= @params[:q].to_s.strip
  end

  private

  attr_reader :scope

  def filtered_scope
    filter_by_query(scope).with_entry_counts
  end

  def filter_by_query(current_scope)
    return current_scope if query.blank?

    # Join to FTS5 virtual table and filter by MATCH query
    # Order by FTS5 BM25 relevance (rank), then alphabetically by name for ties
    current_scope
      .joins("JOIN authors_fts ON authors_fts.author_id = authors.id")
      .where("authors_fts MATCH ?", FtsQuery.new(query).to_s)
      .order("authors_fts.rank, authors.name ASC")
  end
end
