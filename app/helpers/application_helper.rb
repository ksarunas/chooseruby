# frozen_string_literal: true

# View helpers available to every template.
module ApplicationHelper
  LIST_CLASSES = "flex flex-wrap items-center gap-2 text-sm text-slate-600"
  ITEM_CLASSES = "inline-flex items-center"
  LINK_CLASSES = "hover:text-rose-500 transition-colors truncate max-w-[200px] sm:max-w-none"
  CURRENT_CLASSES = "font-semibold text-slate-900 truncate max-w-[200px] sm:max-w-none"

  # Renders a breadcrumb trail from an array of { text:, url: } hashes.
  # The final entry is the current page, so it is never a link.
  def breadcrumbs(items)
    return "" if items.blank?

    content_tag :nav, aria: { label: "Breadcrumb" }, class: "mb-6" do
      content_tag(:ol, breadcrumb_items(items), class: LIST_CLASSES)
    end
  end

  private

  def breadcrumb_items(items)
    *trail, current = items

    (trail.map { |item| breadcrumb_link(item) } << breadcrumb_current(current)).join.html_safe
  end

  # An earlier step in the trail, always a link back, followed by a separator.
  def breadcrumb_link(item)
    link = link_to(item[:text], item[:url], class: LINK_CLASSES)

    content_tag(:li, link + breadcrumb_separator, class: ITEM_CLASSES)
  end

  def breadcrumb_current(item)
    content_tag(:li, breadcrumb_label(item[:text]), class: ITEM_CLASSES)
  end

  def breadcrumb_label(text)
    content_tag(:span, text, class: CURRENT_CLASSES)
  end

  def breadcrumb_separator
    content_tag(:span, "›", class: "mx-1 text-slate-400", aria: { hidden: true })
  end
end
