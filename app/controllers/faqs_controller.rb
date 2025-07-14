# FaqsController handles requests related to FAQ objects.
# It provides functionality for listing and showing individual FAQs with search and filtering capabilities.
class FaqsController < ApplicationController
  include Pagy::Backend

  # GET /faqs
  # Lists all FAQs, optionally filtered by search query and/or category.
  #
  # @param q [String] Optional search query to filter FAQs by question or answer
  # @param category [String] Optional category to filter FAQs
  # @return [Array<Faq>] Collection of FAQ objects
  #
  # @example
  #   GET /faqs
  #   GET /faqs?q=investment
  #   GET /faqs?category=retirement
  #   GET /faqs?q=budget&category=planning
  def index
    @query = params[:q]

    @faqs = Faq.alphabetical

    # Apply search if query parameter is present
    @faqs = @faqs.search(@query) if @query.present?

    # Add pagination
    @pagy, @faqs = pagy(@faqs, items: 12)

    respond_to do |format|
      format.html
      format.json { render json: @faqs }
    end
  end

  # GET /faqs/:id
  # Displays a specific FAQ based on its slug.
  #
  # @param id [String] The slug of the FAQ to display
  # @return [Faq] The requested FAQ object
  #
  # @example
  #   GET /faqs/what-is-compound-interest
  def show
    @faq = Faq.includes(authorship: :author).find_by(slug: params[:id])

    unless @faq
      redirect_to faqs_path, alert: "FAQ not found"
      return
    end

    # Get related FAQs from the same category
    @related_faqs = if @faq.category.present?
                      Faq.by_category(@faq.category)
                         .where.not(id: @faq.id)
                         .alphabetical
                         .limit(5)
    else
                      Faq.where.not(id: @faq.id)
                         .recent
                         .limit(5)
    end

    respond_to do |format|
      format.html
      format.json { render json: @faq }
    end
  end
end
