module ToolsHelper
  def render_tool(tool)
    partial = "tools/#{tool.slug.underscore}"
    render partial, locals: { tool: tool } if partial_exists?(partial)
  end

  private

  def partial_exists?(partial)
    lookup_context.exists?(partial, [], true)
  end
end
