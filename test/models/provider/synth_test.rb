require "test_helper"

class Provider::SynthTest < ActiveSupport::TestCase
  include StockPriceProviderInterfaceTest

  setup do
    @subject = Provider::Synth.new
  end
end
