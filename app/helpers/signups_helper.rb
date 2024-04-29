module SignupsHelper
  def render_signup_form
    turbo_frame_tag "signup_form" do
      render "signups/form"
    end
  end
end
