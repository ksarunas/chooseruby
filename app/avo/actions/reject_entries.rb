# frozen_string_literal: true

# Turns down submitted resources, storing the reviewer feedback and notifying
# the submitter.
class Avo::Actions::RejectEntries < Avo::BaseAction
  self.name = "Reject Resources"
  self.message = "Are you sure you want to reject the selected resources?"
  self.confirm_button_label = "Reject"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false

  def fields
    field :comment, as: :textarea,
          help: "Optional feedback for the submitter",
          placeholder: "Explain why this submission was rejected..."
  end

  def handle(records:, fields:, **_args)
    comment = fields[:comment]
    records.each { |entry| reject_entry(entry, comment) }
    count = records.count

    succeed "#{count} #{noun.pluralize(count)} rejected successfully!"
  end

  private

  def noun
    "resource"
  end

  # The outcome this action records on every entry it reviews.
  def review_status
    :rejected
  end

  def reject_entry(entry, comment)
    status = review_status

    ActiveRecord::Base.transaction do
      entry.update!(status: status)
      EntryReview.create!(entry: entry, status: status, comment: comment)
      ResourceSubmissionMailer.rejection_notification(entry).deliver_later
    end
  end
end
