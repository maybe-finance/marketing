# Configure Rails to use our custom error pages
Rails.application.config.exceptions_app = ->(env) {
  ErrorsController.action(:show).call(env)
}