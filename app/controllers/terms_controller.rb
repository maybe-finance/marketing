class TermsController < ApplicationController
  def index
    @terms = Term.all
  end

  def search
    #
  end

  def show
    @term = Term.find(params[:id])
  end
end
