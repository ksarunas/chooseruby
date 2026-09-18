# frozen_string_literal: true

# Appends a counter until a slug is free, so two records never collide.
module UniqueSlug
  private

  def unique_slug(base_slug)
    candidate_slug = base_slug
    counter = 0

    candidate_slug = "#{base_slug}-#{counter += 1}" while slug_taken?(candidate_slug)

    candidate_slug
  end

  def slug_taken?(candidate_slug)
    self.class.where(slug: candidate_slug).where.not(id:).exists?
  end
end
