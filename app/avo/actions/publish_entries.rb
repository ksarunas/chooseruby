# frozen_string_literal: true

# Makes every selected resource visible on the public directory.
class Avo::Actions::PublishEntries < Avo::BaseAction
  self.name = "Publish Resources"
  self.message = "Are you sure you want to publish the selected resources?"
  self.confirm_button_label = "Publish"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false

  def handle(records:, **_args)
    records.each { |entry| entry.update(published: true) }
    count = records.count

    succeed "#{count} #{noun.pluralize(count)} published successfully!"
  end

  private

  def noun
    "resource"
  end
end
