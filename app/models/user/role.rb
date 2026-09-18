# frozen_string_literal: true

# What a user is allowed to do: editing entries, or administering the site.
module User::Role
  extend ActiveSupport::Concern

  included do
    enum :role, %w[editor admin].index_by(&:itself), default: :editor
  end

  def can_administer?
    admin?
  end
end
