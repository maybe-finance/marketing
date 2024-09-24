require "test_helper"

class Provider::FredTest < ActiveSupport::TestCase
  include MortgageRateProviderInterfaceTest

  setup do
    @subject = Provider::Fred.new
  end
end
