# frozen_string_literal: true

# The public author directory and individual author pages.
class AuthorsController < ApplicationController
  PER_PAGE = 25
  ENTRIES_PER_PAGE = 20
  AUTOCOMPLETE_LIMIT = 10

  def index
    search = AuthorSearchQuery.new(params.permit(:q, :page).to_h)

    @query = search.query
    @authors = search.call.page(params[:page]).per(PER_PAGE)
  end

  def show
    # Find author by slug, only show approved authors
    author = Author.approved.find_by!(slug: params[:slug])

    @author = author
    @entries = author.entries.page(params[:page]).per(ENTRIES_PER_PAGE)
  rescue ActiveRecord::RecordNotFound
    render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
  end

  # API endpoint for author autocomplete search
  # Returns JSON array of approved authors matching the query
  def search
    query = params[:q].to_s.strip

    # Return empty results if query is blank
    return render json: [] if query.blank?

    authors = AuthorSearchQuery.new({ q: query }).call.limit(AUTOCOMPLETE_LIMIT)

    render json: authors.as_json(only: %i[id name github_url])
  end
end
