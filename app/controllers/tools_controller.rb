class ToolsController < ApplicationController
  def index
    @tools = Tool.all

    if params[:category].present?
      # Ensure category_slug is valid by checking against existing values
      valid_categories = Tool.distinct.pluck(:category_slug)
      @tools = @tools.where(category_slug: params[:category]) if valid_categories.include?(params[:category])
    end

    if params[:q].present?
      @query = params[:q].to_s.strip
      # Use sanitize_sql_like to escape special characters in the search query
      @tools = @tools.where("title ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%")
    end
  end

  def show
    @tool = Tool.presenter_from tool_params.compact_blank.merge(action_name: action_name)
    @more_tools = Tool.random_sample(4, exclude: @tool)
  end

  private
    def tool_params
      params.permit :slug,
        # Bogleheads Growth Calculator
        :invested_amount, :stock_market_ticker, :international_stock_market_ticker, :bond_market_ticker, :stock_market_percentage, :international_stock_market_percentage, :bond_market_percentage,
        # Compound Interest Calculator
        :initial_investment, :monthly_contribution, :years_to_grow, :annual_interest_rate,
        # Early Mortgage Payoff Calculator
        :loan_amount, :original_term, :years_left, :interest_rate, :extra_payment, :savings_rate,
        # Financial Freedom Calculator
        :current_savings, :monthly_expenses, :annual_savings_growth_rate,
        # Home Affordability Calculator
        :loan_duration, :loan_interest_rate, :desired_home_price, :down_payment, :annual_pre_tax_income, :monthly_debt_payments, :hoa_plus_pmi,
        # Inflation Calculator
        :initial_amount, :years, :inflation_rate,
        # Loan Calculator,
        :loan_amount, :interest_rate, :loan_term, :loan_period, :date,
        # Retirement Calculator
        :annual_salary, :monthly_contribution, :annual_salary_increase, :current_age, :retirement_age, :annual_rate_of_return, :current_401k_balance, :employer_match, :salary_limit_match,
        # ROI Calculator
        :amount_invested, :amount_returned, :investment_period, :investment_length,
        # Stock Portfolio Backtest
        :benchmark_stock, :investment_amount, :start_date, :end_date, { stocks: [], stock_allocations: [] },
        # Exchange Rate Calculator
        :amount, :from_currency, :to_currency,
        # Insider Trading Tracker
        :symbol, :filter
    end
end
