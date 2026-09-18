# frozen_string_literal: true

# Admin screens for the author profile changes the public forms submit for
# review.
class Avo::Resources::AuthorProposal < Avo::BaseResource
  self.title = :id
  self.includes = [ :author, :matched_entry ]

  # Disable create/edit/delete - proposals are created via public forms only
  self.visible_on_sidebar = true

  # Enable search on submitter_email
  self.search = {
    query: -> {
      sanitized_query = ActiveRecord::Base.sanitize_sql_like(params[:q])
      query.where("submitter_email LIKE ?", "%#{sanitized_query}%")
    }
  }

  # Spells out, in the words a reviewer reads, what a proposal would change
  # about an author.
  class ChangesSummary
    def initialize(proposal)
      @proposal = proposal
    end

    def to_s
      sections.flatten.join("\n")
    end

    private

    def sections
      [ author_section, resource_section, link_section, bio_section, description_section ]
    end

    def author_section
      return "Creating new author: #{@proposal.author_name}" if @proposal.new_author_proposal?

      "Editing author: #{@proposal.author.name}"
    end

    def resource_section
      return [] unless @proposal.has_resource_proposal?
      return "\nResource: Unmatched URL - #{@proposal.resource_url}" unless @proposal.matched_entry?

      "\nResource: Matched entry ##{@proposal.matched_entry_id} - #{@proposal.matched_entry.title}"
    end

    def link_section
      return [] unless @proposal.has_link_updates?

      [ "\nLink Updates:" ] + @proposal.link_updates.map { |link_field, url| link_line(link_field, url) }
    end

    def link_line(link_field, url)
      current_value = @proposal.author&.public_send(link_field)

      "  - #{link_field}: #{current_value.presence || '(blank)'} → #{url}"
    end

    def bio_section
      bio = @proposal.bio_text
      return [] if bio.blank?

      [ "\nBio:", "  Current: #{@proposal.author&.bio.presence || '(blank)'}", "  Proposed: #{bio}" ]
    end

    def description_section
      description = @proposal.description_text
      return [] if description.blank?

      [ "\nDescription:", "  Proposed: #{description}" ]
    end
  end

  def fields
    submitter_fields
    author_fields
    resource_fields
    proposed_change_fields
    review_fields
  end

  def filters
    filter Avo::Filters::AuthorProposalStatusFilter
  end

  def actions
    action Avo::Actions::ApproveAuthorProposal
    action Avo::Actions::RejectAuthorProposal
  end

  private

  def submitter_fields
    field :id, as: :id, link_to_record: true

    field :status, as: :select,
          enum: ::AuthorProposal.statuses,
          required: true,
          sortable: true,
          help: "Proposal workflow status"

    field :submitter_email, as: :text,
          required: true,
          sortable: true,
          help: "Email of person who submitted this proposal"

    field :submitter_name, as: :text,
          help: "Name of submitter (optional)",
          hide_on: [ :index ]
  end

  def author_fields
    field :author, as: :belongs_to,
          help: "Existing author being edited (nil for new author proposals)",
          searchable: true

    field :author_name, as: :text,
          help: "Name for new author (only used when creating new author)",
          hide_on: [ :index ],
          visible: -> { resource.record.new_author_proposal? }
  end

  def resource_fields
    field :resource_url, as: :text,
          help: "Normalized URL for resource to associate",
          hide_on: [ :index ]

    field :original_resource_url, as: :text,
          readonly: true,
          help: "Original URL as entered by submitter",
          hide_on: [ :index ]

    field :matched_entry, as: :belongs_to,
          class_name: "Entry",
          help: "Entry matched from resource URL (if found)",
          searchable: true
  end

  def proposed_change_fields
    field :link_updates, as: :code,
          readonly: true,
          language: "json",
          help: "JSON hash of proposed link changes",
          hide_on: [ :index ]

    field :bio_text, as: :textarea,
          readonly: true,
          rows: 5,
          help: "Proposed bio text (max 500 characters)",
          hide_on: [ :index ]

    field :description_text, as: :textarea,
          readonly: true,
          rows: 5,
          help: "Proposed description text",
          hide_on: [ :index ]

    field :submission_notes, as: :textarea,
          readonly: true,
          rows: 3,
          help: "Additional notes from submitter",
          hide_on: [ :index ]
  end

  def review_fields
    field :admin_comment, as: :textarea,
          readonly: true,
          rows: 3,
          help: "Admin feedback on rejection",
          hide_on: [ :index ]

    field :reviewed_at, as: :date_time,
          readonly: true,
          help: "Timestamp when proposal was reviewed",
          hide_on: [ :index ]

    timestamp_fields
    comparison_fields
  end

  def timestamp_fields
    field :created_at, as: :date_time,
          readonly: true,
          sortable: true,
          help: "When proposal was submitted"

    field :updated_at, as: :date_time,
          readonly: true,
          hide_on: [ :index ]
  end

  def comparison_fields
    field :proposal_type, as: :text,
          readonly: true,
          computed: true,
          hide_on: [ :edit, :new ],
          help: "Type of proposal" do
            record.new_author_proposal? ? "New Author" : "Edit Existing Author"
          end

    field :changes_summary, as: :textarea,
          readonly: true,
          computed: true,
          rows: 8,
          hide_on: [ :index, :edit, :new ],
          help: "Summary of proposed changes" do
            ChangesSummary.new(record).to_s
          end
  end
end
