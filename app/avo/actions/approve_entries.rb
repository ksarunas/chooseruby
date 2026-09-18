# frozen_string_literal: true

# Accepts submitted resources: publishes them, records the review and lets
# the submitter know.
class Avo::Actions::ApproveEntries < Avo::BaseAction
  self.name = "Approve Resources"
  self.message = "Are you sure you want to approve the selected resources?"
  self.confirm_button_label = "Approve"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false

  def handle(records:, **_args)
    records.each { |entry| approve_entry(entry) }
    count = records.count

    succeed "#{count} #{noun.pluralize(count)} approved successfully!"
  end

  private

  def noun
    "resource"
  end

  # The outcome this action records on every entry it reviews.
  def review_status
    :approved
  end

  def approve_entry(entry)
    status = review_status

    ActiveRecord::Base.transaction do
      entry.update!(status: status, published: true)
      EntryReview.create!(entry: entry, status: status)
      ResourceSubmissionMailer.approval_notification(entry).deliver_later
    end
  end
end
