# The ArticlesController handles CRUD operations for articles in the application.
# It currently provides actions for listing and displaying individual articles.
class ArticlesController < ApplicationController
  # GET /articles
  # Retrieves and displays a list of all published articles, ordered by publish date descending.
  #
  # @return [Array<Article>] A collection of published Article objects
  # @example
  #   GET /articles
  def index
    expires_in 12.hours, public: true
    @articles = Article.all.order("publish_at DESC").where("publish_at <= ?", Time.now)
  end

  # GET /articles/:id
  # Displays a specific article based on its slug.
  #
  # @param id [String] The slug of the article to display
  # @return [Article] The requested Article object
  # @example
  #   GET /articles/my-first-article
  def show
    expires_in 3.days, public: true
    @article = Article.find_by(slug: params[:id])
    redirect_to articles_path unless @article
  end
end
