class FeaturesController < ApplicationController
  include Features::AssistantHelper
  def tracking
  end

  def transactions
  end

  def budgeting
  end

  def assistant
    @categories  = tab_categories
    @active_category = params[:category] || "spending"


    # Load data from YAML
    @content = load_assistant_data(@active_category)
  end

  def assistant_content
    @content = load_assistant_data(params[:category])

    render partial: "features/assistant_#{params[:category]}", locals: { content: @content }
  end
end
