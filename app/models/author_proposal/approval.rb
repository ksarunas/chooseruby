# frozen_string_literal: true

# Applies an approved proposal to the author it concerns.
#
# The proposed bio and links are written onto the author, creating that author
# first when the proposal asked for a new one. The author is then linked to the
# entry the proposal matched, and the submitter is told the outcome.
class AuthorProposal::Approval
  def initialize(proposal)
    @proposal = proposal
  end

  def call
    ActiveRecord::Base.transaction { apply }

    true
  end

  private

  attr_reader :proposal

  def apply
    author = updated_author

    proposal.author_id = author.id if proposal.author_id.blank?
    link_to_matched_entry(author)
    proposal.update!(status: :approved, reviewed_at: Time.current, reviewer_id: nil)
    AuthorProposalMailer.approval_notification(proposal).deliver_later
  end

  # The author the proposal concerns, with the proposed changes saved onto it.
  def updated_author
    author = existing_author || Author.new(name: proposal.author_name)

    apply_changes_to(author)
    author.save!

    author
  end

  def apply_changes_to(author)
    bio = proposal.bio_text

    author.bio = bio if bio.present?
    proposed_links.each { |field_name, url| author.public_send("#{field_name}=", url) }
  end

  # Loaded by id because the association is strict loading.
  def existing_author
    author_id = proposal.author_id

    Author.find(author_id) if author_id.present?
  end

  def proposed_links
    AuthorProposal::ProposedLinks.new(proposal.link_updates)
  end

  def link_to_matched_entry(author)
    entry_id = proposal.matched_entry_id
    return if entry_id.blank?
    return if EntriesAuthor.exists?(author: author, entry_id: entry_id)

    EntriesAuthor.create!(author: author, entry_id: entry_id)
  end
end
