class SignupsController < ApplicationController
  def new
  end

  def create
    form_id = ENV["CONVERTKIT_FORM_ID"]
    tag_id = ENV["CONVERTKIT_TAG_ID"]
    api_key = ENV["CONVERTKIT_API_KEY"]
    email = params[:email]

    Faraday.post("https://api.convertkit.com/v3/forms/#{form_id}/subscribe") do |req|
      req.headers["Content-Type"] = "application/json; charset=utf-8"
      req.body = { api_key: api_key, email: email, tags: [ tag_id ] }.to_json
    end
  end
end
