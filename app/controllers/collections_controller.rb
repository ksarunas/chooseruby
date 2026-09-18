# frozen_string_literal: true

# Curated collections of entries, each with its own filters.
class CollectionsController < ApplicationController
  PER_PAGE = 12

  def index
    @collections = curated_collections_data
    @experience_tracks = experience_tracks_data
  end

  def show
    collection = find_collection

    @collection = collection
    @categories = Category.order(:display_order, :name)

    assign_entries(collection)
  end

  private

  def find_collection
    slug = params[:id]
    collection = curated_collections_data.find { |candidate| candidate[:slug] == slug }
    raise ActiveRecord::RecordNotFound, "Collection not found" unless collection

    collection
  end

  def assign_entries(collection)
    directory_query = EntryDirectoryQuery.new(collection_filters(collection))

    @directory_query = directory_query
    @entries = directory_query.call.page(params[:page]).per(PER_PAGE)
  end

  # The collection's own filters, with anything the reader chose taking over.
  def collection_filters(collection)
    overrides = params.permit(:q, :level, :category).to_h.symbolize_keys

    collection.fetch(:filters, {}).symbolize_keys.merge(overrides) do |_key, base, override|
      override.presence || base
    end
  end
end
