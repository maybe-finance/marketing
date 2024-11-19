class ToolsController < ApplicationController
  def index
    @tools = Tool.all
  end

  def show
    @tool = Tool.presenter_from tool_params.compact_blank
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
        :symbol
    end
end
