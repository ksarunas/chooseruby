# frozen_string_literal: true

require "test_helper"

class FtsTablesTest < ActiveSupport::TestCase
  class FakeConnection
    attr_reader :executed

    def initialize
      @executed = []
    end

    def execute(sql)
      @executed << sql
    end
  end

  test "creates every FTS5 table and reports each one" do
    connection = FakeConnection.new
    output = StringIO.new

    FtsTables.new(connection: connection, output: output).create

    assert_equal 2, connection.executed.size
    assert_match(/CREATE VIRTUAL TABLE IF NOT EXISTS entries_fts USING fts5/, connection.executed.first)
    assert_match(/CREATE VIRTUAL TABLE IF NOT EXISTS authors_fts USING fts5/, connection.executed.last)
    assert_equal <<~TEXT, output.string
      Creating FTS5 virtual tables...
        ✓ entries_fts table ready
        ✓ authors_fts table ready
      FTS5 tables ready!
    TEXT
  end

  test "is idempotent against the real database connection" do
    output = StringIO.new

    2.times { FtsTables.new(output: output).create }

    table_names = ActiveRecord::Base.connection.select_values(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name LIKE '%_fts'"
    )
    assert_includes table_names, "entries_fts"
    assert_includes table_names, "authors_fts"
    assert_equal 2, output.string.scan("FTS5 tables ready!").size
  end
end
