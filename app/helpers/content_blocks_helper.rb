# frozen_string_literal: true

# Helper methods for rendering ContentBlocks
module ContentBlocksHelper
  # Renders all active ContentBlocks that match the given request path.
  # Each block's content is formatted using simple_format and wrapped in a div.
  #
  # @param path [String] The request path to match against.
  # @return [ActiveSupport::SafeBuffer, nil] The combined HTML for the blocks, or nil if none match.
  def render_content_blocks(path)
    blocks = ContentBlock.for_path(path)
    return if blocks.empty?

    # Use safe_join to concatenate HTML strings safely
    safe_join(blocks.map do |block|
      # Wrap each block's content in a div for potential styling/identification
      # Use the markdown helper for rendering markdown content.
      content_tag(:div, markdown(block.content), class: "content-block mb-6 prose max-w-none", data: { content_block_id: block.id })
    end)
  end
end
