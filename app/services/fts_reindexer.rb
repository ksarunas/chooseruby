# frozen_string_literal: true

# Rebuilds the SQLite FTS5 index for entries and authors.
#
# Reindexing is a maintenance operation driven by the fts:* rake tasks.
class FtsReindexer
  DEFAULT_BATCH_SIZE = 1000

  def initialize(batch_size: DEFAULT_BATCH_SIZE)
    @batch_size = batch_size
  end

  def reindex_all
    reindex_entries
    reindex_authors
  end

  def reindex_entries
    Entry.find_each(batch_size: @batch_size) do |entry|
      entry.send(:sync_to_fts)
    end
  end

  def reindex_authors
    Author.find_each(batch_size: @batch_size) do |author|
      author.send(:sync_to_fts)
    end
  end
end
