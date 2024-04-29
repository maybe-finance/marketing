module SignupsHelper
  def render_signup_form(centered: false)
    turbo_frame_tag "signup_form" do
      render "signups/form", centered: centered
    end
  end
end
