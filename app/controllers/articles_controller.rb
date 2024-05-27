class ArticlesController < ApplicationController
  def index
    @articles = Article.all.order("publish_at DESC")
  end

  def show
    @article = Article.find_by(slug: params[:id])
  end
end
