class FeaturesController < ApplicationController
  include Features::AssistantHelper
  # Define valid categories as a constant
  VALID_CATEGORIES = %w[tracking transactions budgeting assistant spending].freeze

  # Use a before_action to load data for relevant actions
  before_action :load_assistant_content_for_category, only: [ :assistant, :assistant_content ]

  def tracking
  end

  def transactions
  end

  def budgeting
  end

  def assistant
    # @categories is still needed for the tabs
    @categories = tab_categories # Assuming this helper provides the categories for tabs
    # @active_category and @content are set by the before_action
    # If @content was nil, the before_action redirected already
  end

  def assistant_content
    # @content is set by the before_action. If it was nil, we redirected.
    # Dynamically determine the partial based on the validated category
    render partial: "features/assistant_#{@active_category}", locals: { content: @content }
  end

  private # Ensure helper methods are private

  # Before action to validate category, load content, or redirect
  def load_assistant_content_for_category
    @active_category = determine_active_category(params[:category])
    if @active_category
      @content = load_assistant_data(@active_category)
      # If content is nil after loading (e.g., file not found), redirect
      redirect_to root_path, alert: "Invalid category requested." unless @content
    else
      # If the category itself was invalid or not provided when required
      redirect_to root_path, alert: "Invalid category requested."
    end
  end

  # Helper to determine and validate the category
  def determine_active_category(category_param)
    if category_param.present? && VALID_CATEGORIES.include?(category_param)
      category_param
    elsif action_name == "assistant" # Only default if it's the main assistant action
      "spending" # Default to 'spending' for the main assistant page
    else
      nil # Return nil if category is invalid or not provided for assistant_content
    end
  end

  # Load data from YAML, ensuring it's private
  def load_assistant_data(category)
    # Basic sanitization example (already present, good practice)
    safe_category = category.gsub(/[^a-z_]/, "")
    file_path = Rails.root.join("config", "data", "features", "assistant", "#{safe_category}.yml")
    if File.exist?(file_path)
      YAML.load_file(file_path)
    else
      Rails.logger.warn "Assistant data file not found for category: #{category} at #{file_path}"
      nil # Return nil if file doesn't exist to indicate failure
    end
  end
end
