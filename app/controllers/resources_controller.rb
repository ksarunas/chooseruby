# frozen_string_literal: true

# Individual resource pages and the resource listing they are reached from.
class ResourcesController < ApplicationController
  PER_PAGE = 12
  FEATURED_LIMIT = 6
  SUGGESTION_LIMIT = 5

  def index
    @categories = Category.order(:display_order, :name)
    @featured_entries = Entry.visible.featured.with_directory_includes.limit(FEATURED_LIMIT)

    assign_directory(EntryDirectoryQuery.new(params.permit(:q, :level, :type, :sort).to_h))
  end

  def show
    # Only published and approved entries are reachable
    entry = Entry.visible.with_card_includes.find_by!(slug: params[:slug] || params[:id])

    @entry = entry
    assign_suggestions(entry)
  rescue ActiveRecord::RecordNotFound
    render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
  end

  private

  def assign_directory(directory_query)
    @query = directory_query.query
    @active_level = directory_query.level
    @active_type = directory_query.type
    @entries = directory_query.call.page(params[:page]).per(PER_PAGE)
  end

  def assign_suggestions(entry)
    suggestions = Entry::Suggestions.new(entry, limit: SUGGESTION_LIMIT)

    @author_resources = suggestions.by_same_authors
    @related_resources = suggestions.related
  end
end
