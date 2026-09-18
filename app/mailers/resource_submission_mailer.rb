# frozen_string_literal: true

# Mailer for resource submissions: notifies the team of new submissions and
# tells submitters when their entry is received, approved or rejected.
class ResourceSubmissionMailer < ApplicationMailer
  default to: -> { ENV.fetch("RESOURCE_SUBMISSION_RECIPIENT", "hello@chooseruby.com") }
  default from: -> { ENV.fetch("RESOURCE_SUBMISSION_SENDER", "hello@chooseruby.com") }

  def notify_team(submission)
    @submission = submission
    @categories = submission.categories

    mail(subject: "New resource submission: #{submission.title}")
  end

  def confirm_submitter(submission)
    @submission = submission

    mail(
      to: submission.submitter_email,
      subject: "We received your resource submission for ChooseRuby"
    )
  end

  def approval_notification(entry)
    @entry = entry

    mail(
      to: entry.submitter_email,
      subject: "Your ChooseRuby submission has been approved: #{entry.title}"
    )
  end

  def rejection_notification(entry)
    @entry = entry
    @comment = entry.entry_reviews.where(status: :rejected).last&.comment

    mail(
      to: entry.submitter_email,
      subject: "Update on your ChooseRuby submission: #{entry.title}"
    )
  end
end
