# frozen_string_literal: true

# AuthorProposalsController handles public-facing proposal submission forms
#
# This controller allows anonymous visitors to:
# - Propose edits to existing author profiles (links, bio, description)
# - Suggest adding resources to author profiles
# - Propose creating entirely new author profiles
#
# All proposals are created in pending status and require admin approval.
#
# Actions:
# - new: Display form for editing existing author
# - new_author: Display form for proposing new author
# - create: Process proposal submission
# - success: Display confirmation page after successful submission
class AuthorProposalsController < ApplicationController
  # Display proposal form for existing author
  # GET /authors/:author_id/propose_edit
  def new
    author = Author.approved.find(params[:author_id])

    @author = author
    @author_proposal = AuthorProposal.new(author: author)
  rescue ActiveRecord::RecordNotFound
    render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
  end

  # Display proposal form for new author
  # GET /authors/new_proposal
  def new_author
    @author_proposal = AuthorProposal.new
  end

  # Process proposal submission
  # POST /author_proposals
  def create
    proposal = AuthorProposal.new(author_proposal_params)

    @author_proposal = proposal
    return redirect_to author_proposal_success_path(proposal) if proposal.save

    render_proposal_form(proposal)
  end

  # Display success confirmation page
  # GET /author_proposals/:id/success
  def success
    @author_proposal = AuthorProposal.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
  end

  private

  # Strong parameters for author proposal
  # Redisplays the form the proposal came from, reloading the author it concerns
  # so the fields can be shown again.
  def render_proposal_form(proposal)
    proposed_author_id = proposal.author_id
    return render :new_author, status: :unprocessable_entity if proposed_author_id.blank?

    @author = Author.find_by(id: proposed_author_id)
    render :new, status: :unprocessable_entity
  end

  def author_proposal_params
    permitted = params.require(:author_proposal).permit(*permitted_proposal_keys)
    permitted[:link_updates] = AuthorProposal::ProposedLinks.from_form(permitted[:link_updates])

    permitted
  end

  def permitted_proposal_keys
    [
      :author_id,
      :author_name,
      :resource_url,
      :bio_text,
      :description_text,
      :submitter_name,
      :submitter_email,
      :submission_notes,
      { link_updates: [
        :github_url,
        :gitlab_url,
        :website_url,
        :bluesky_url,
        :ruby_social_url,
        :twitter_url,
        :linkedin_url,
        :youtube_url,
        :twitch_url,
        :blog_url
      ] }
    ]
  end
end
