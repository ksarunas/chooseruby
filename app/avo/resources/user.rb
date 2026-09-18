# frozen_string_literal: true

# Admin screens for the accounts that can sign in to the admin area.
class Avo::Resources::User < Avo::BaseResource
  self.includes = []

  def fields
    field :id, as: :id

    credential_fields
    access_fields
    timestamp_fields
  end

  private

  def credential_fields
    field :email_address, as: :text, required: true
    field :name, as: :text, required: true
    field :password, as: :password, only_on: [ :new, :edit ], required: true, help: "Leave blank to keep current password"
  end

  def access_fields
    field :role, as: :select, enum: ::User.roles, required: true
    field :status, as: :select, enum: ::User.statuses, required: true
  end

  def timestamp_fields
    field :created_at, as: :date_time
    field :updated_at, as: :date_time
  end
end
