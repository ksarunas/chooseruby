# frozen_string_literal: true

module Authentication
  # Finding the signed in session from the cookie the browser sent.
  module SessionLookup
    extend ActiveSupport::Concern

    private

    def find_session_by_cookie
      token = cookies.signed[:session_token]
      return nil unless token

      # Eager load user to prevent N+1 queries
      Session.includes(:user).find_by(token: token)&.refresh
    end
  end
end
