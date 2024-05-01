class ArticlesController < ApplicationController
  def index
    @articles = Article.order('publish_at DESC')
  end

  def show
    @article = Article.where(slug: params[:id]).first
    @next_articles = Article.where("id > ?", @article.id).limit(3)

    if @article.nil?
      redirect_to '/404'
    end
  end
end
