# SignupsController handles user sign-ups and integrates with ConvertKit API.
#
# This controller manages the process of subscribing users to a ConvertKit form
# and tagging them appropriately. It uses environment variables for configuration
# and Faraday for making HTTP requests to the ConvertKit API.
class SignupsController < ApplicationController
  # Renders the new signup form.
  #
  # @return [void]
  def new
  end

  # Processes the signup form submission and subscribes the user to ConvertKit.
  #
  # @param email [String] The email address of the user signing up.
  # @return [void]
  #
  # @example
  #   POST /signups
  #   params: { email: "user@example.com" }
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
