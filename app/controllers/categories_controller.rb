# frozen_string_literal: true

# Browsing the directory one category at a time.
class CategoriesController < ApplicationController
  PER_PAGE = 12

  def index
    @categories = Category.order(:display_order, :name)
  end

  def show
    @category = Category.find_by!(slug: params[:slug])
    @categories = Category.order(:display_order, :name)

    assign_entries
  end

  private

  def assign_entries
    directory_query = EntryDirectoryQuery.new(params.permit(:q, :level).to_h.merge(category: params[:slug]))

    @query = directory_query.query
    @active_level = directory_query.level
    @entries = directory_query.call.page(params[:page]).per(PER_PAGE)
  end
end
