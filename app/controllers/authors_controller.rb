class AuthorsController < ApplicationController
  before_action :set_author, only: [ :show ]

  def index
    @authors = Author.includes(:authorships).order(:name)
  end

  def show
    @articles = @author.articles.published.latest.includes(authorship: :author)
    @terms = @author.terms.includes(authorship: :author)
    @faqs = @author.faqs.includes(authorship: :author)

    @content_count = @articles.count + @terms.count + @faqs.count
  end

  private

  def set_author
    @author = Author.find_by!(slug: params[:slug])
  end
end
