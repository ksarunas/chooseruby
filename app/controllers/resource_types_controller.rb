# frozen_string_literal: true

# Browsing the directory one resource type at a time, such as gems or books.
class ResourceTypesController < ApplicationController
  PER_PAGE = 25
  FEATURED_LIMIT = 5

  before_action :validate_type_parameter

  def show
    @type = params[:type]
    @categories = Category.order(:display_order, :name)

    assign_filters
    assign_listings
  end

  private

  def validate_type_parameter
    type = params[:type]
    raise ActiveRecord::RecordNotFound, "Invalid resource type: #{type}" unless Entry::VALID_TYPES.key?(type)
  end

  def directory_query
    @directory_query ||= EntryDirectoryQuery.new(params.permit(:q, :level, :category, :type).to_h)
  end

  def assign_filters
    @query = directory_query.query
    @active_level = directory_query.level
    @active_category = directory_query.category
  end

  def assign_listings
    type = params[:type]

    @featured_entries = Entry.featured_of_type(type).limit(FEATURED_LIMIT)
    @category_stats = Category.with_entry_counts_for_type(type)
    @entries = directory_query.call.page(params[:page]).per(PER_PAGE)
  end
end
