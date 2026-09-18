# frozen_string_literal: true

# Signs the admin fixture into the Avo admin for integration tests.
module AvoAdminSession
  def sign_in_as_admin
    post session_url, params: { email_address: users(:admin).email_address, password: "password" }
  end
end
