class TermsController < ApplicationController
  def index
    @terms = Term.all
  end

  def search
    #
  end

  def show
  end
end
