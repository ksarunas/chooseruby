# frozen_string_literal: true

# Base class for every mailer, setting the shared sender and layout.
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"
end
