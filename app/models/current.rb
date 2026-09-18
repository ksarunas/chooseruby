# frozen_string_literal: true

# Per request state: who is signed in and where the request came from.
class Current < ActiveSupport::CurrentAttributes
  attribute :user, :session, :request_id, :user_agent, :ip_address
end
