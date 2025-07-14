# The ArticlesController handles CRUD operations for articles in the application.
# It currently provides actions for listing and displaying individual articles.
class ArticlesController < ApplicationController
  include Pagy::Backend

  # GET /articles
  # Retrieves and displays a list of all published articles, ordered by publish date descending.
  #
  # @return [Array<Article>] A collection of published Article objects
  # @example
  #   GET /articles
  def index
    @featured_article = Article.published.latest.includes(authorship: :author).first
    @pagy, @articles = pagy(
      Article.published
            .where.not(id: @featured_article&.id)
            .latest
            .includes(authorship: :author),
      items: 6,
      limit: 6
    )
  end

  # GET /articles/:id
  # Displays a specific article based on its slug.
  #
  # @param id [String] The slug of the article to display
  # @return [Article] The requested Article object
  # @example
  #   GET /articles/my-first-article
  def show
    @article = Article.includes(authorship: :author).find_by(slug: params[:id])
    redirect_to articles_path unless @article
  end
end
