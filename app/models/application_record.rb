# frozen_string_literal: true

# Base class for every model in the application.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Runs a sanitized statement against an FTS5 virtual table. Those tables are
  # not backed by models, so they are maintained with SQL.
  def self.execute_fts_sql(*statement)
    connection.execute(sanitize_sql_array(statement))
  end
end
