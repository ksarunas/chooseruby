# frozen_string_literal: true

# Creates the SQLite FTS5 virtual tables that back full-text search.
# Virtual tables are not tracked by db/schema.rb, so they are created explicitly (see fts:create).
# Every statement uses IF NOT EXISTS, so running this repeatedly is safe.
class FtsTables
  DEFINITIONS = {
    "entries_fts" => <<~SQL,
      CREATE VIRTUAL TABLE IF NOT EXISTS entries_fts USING fts5(
        entry_id UNINDEXED,
        title,
        description,
        tags,
        tokenize='porter ascii'
      );
    SQL
    "authors_fts" => <<~SQL
      CREATE VIRTUAL TABLE IF NOT EXISTS authors_fts USING fts5(
        author_id UNINDEXED,
        name,
        tokenize='porter ascii'
      );
    SQL
  }.freeze

  def initialize(connection: ActiveRecord::Base.connection, output: $stdout)
    @connection = connection
    @output = output
  end

  def create
    @output.puts "Creating FTS5 virtual tables..."

    DEFINITIONS.each do |table_name, definition|
      @connection.execute(definition)
      @output.puts "  ✓ #{table_name} table ready"
    end

    @output.puts "FTS5 tables ready!"
  end
end
