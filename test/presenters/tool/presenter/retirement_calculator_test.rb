require "test_helper"

class Tool::Presenter::RetirementCalculatorTest < ActiveSupport::TestCase
  setup do
    @tool = Tool::Presenter::RetirementCalculator.new \
      retirement_age: "65",
      current_age: "35",
      annual_salary: "$120,000.00",
      current_401k_balance: "$100,000.00",
      annual_rate_of_return: "5",
      monthly_contribution: "15",
      annual_salary_increase: "3",
      employer_match: "50",
      salary_limit_match: "6"
  end

  test "blankness" do
    assert Tool::Presenter::RetirementCalculator.new.blank?
    assert_not @tool.blank?
  end

  test "current total value" do
    assert_equal 2_586_777.10, @tool.current_total_value.round(2)
  end

  test "total employee contributions" do
    assert_equal 856_357.48, @tool.total_employee_contributions.round(2)
  end

  test "total employer contributions" do
    assert_equal 171_271.50, @tool.total_employer_contributions.round(2)
  end

  test "plot data" do
    travel_to Date.new(2024, 9, 24) do
      first_plot_point = {
        year: 1,
        date: Date.today + 1.year,
        contributed: 18_000.00,
        interest: 21_600.00,
        currentTotalValue: 127_310.22108926918,
        totalEmployeeContributions: 18_000.0,
        totalEmployerContributions: 3_600.0 }
      last_plot_point = {
        year: 30,
        date: Date.today + 30.years,
        contributed: 856_357.4827137964,
        interest: 1_027_628.9792565557,
        currentTotalValue: 2_586_777.0976018026,
        totalEmployeeContributions: 856_357.4827137964,
        totalEmployerContributions: 171_271.4965427593 }

      assert_equal first_plot_point, @tool.plot_data.first
      assert_equal last_plot_point, @tool.plot_data.last
    end
  end
end
