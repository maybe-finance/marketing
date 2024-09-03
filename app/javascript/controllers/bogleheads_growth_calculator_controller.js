import { Controller } from "@hotwired/stimulus";
import { formatMoney, getTickerName } from "helpers/utilities"

import InvestmentManager from "helpers/investment_manager"
import TemplateRenderer from "helpers/template_renderer";


// Connects to data-controller="bogleheads-growth-calculator"
export default class extends Controller {
  static targets = ["resultsTemplate", "resultsContainer"];

  async calculate(event) {
    event.preventDefault();
    const formData = new FormData(event.target);
    const parseFormData = key => parseFloat(formData.get(key).replace(/[^0-9.-]+/g, ''));

    const getInputValue = (key) => {
      const target = document.querySelector(`input[name='${key}']`);
      return target ? target.value : "";
    }

    const rawStockData = getInputValue("stock_data")
    const parsedStockData = JSON.parse(rawStockData)

    const getInvestmentPercentage = (key) => {
      const target = document.getElementById(key)
      return parseFloat(target.value.replace(/[^0-9.-]+/g, ''));
    }

    const invested = parseFormData("invested_amount");

    if (!invested) {
      alert("Please specify an investment amount")
      return
    }

    const stockMarketTicker = getInputValue("stock_market_ticker")
    const bondMarketTicker = getInputValue("bond_market_ticker")
    const internationalStockMarketTicker = getInputValue("international_stock_market_ticker")

    const totalStockMarketAllocation = getInvestmentPercentage("stock_market_percentage");
    const totalInternationalStockAllocation = getInvestmentPercentage("international_stock_market_percentage");
    const totalBondMarketAllocation = getInvestmentPercentage("bond_market_percentage");

    const totalInvestmentAllocation = totalStockMarketAllocation + totalInternationalStockAllocation + totalBondMarketAllocation

    if (Math.floor(totalInvestmentAllocation) !== 100) {
      alert(`Your investment allocations of (${totalInvestmentAllocation}%) should equal 100%`)
      return
    }

    const fundAllocations = {
      [bondMarketTicker]: totalBondMarketAllocation,
      [stockMarketTicker]: totalStockMarketAllocation,
      [internationalStockMarketTicker]: totalInternationalStockAllocation,
    }

    // a mapping of tickers to their respective fund "types/categories"
    const tickerFundCategories = {
      [bondMarketTicker]: "bondMarketFunds",
      [stockMarketTicker]: "stockMarketFunds",
      [internationalStockMarketTicker]: "internationalStockFunds",
    }

    const processedStockData = {
      [bondMarketTicker]: parsedStockData[bondMarketTicker],
      [stockMarketTicker]: parsedStockData[stockMarketTicker],
      [internationalStockMarketTicker]: parsedStockData[internationalStockMarketTicker],
    }

    const investmentManager = new InvestmentManager(invested, fundAllocations, processedStockData, tickerFundCategories)
    const chartData = investmentManager.makeChartData()
    const finalValue = investmentManager.getCurrentMarketValue(chartData)
    const profitOrLoss = investmentManager.getProfitOrLoss(chartData)

    const returnsOnInvestment = Math.floor((profitOrLoss / invested) * 100)

    const legendData = JSON.stringify({
      value: {
        name: "Portfolio value",
        fillClass: "fill-pink-500",
        strokeClass: "stroke-pink-500"
      },
      bondMarketFunds: {
        name: getTickerName(bondMarketTicker),
        fillClass: "fill-violet-500",
        strokeClass: "stroke-violet-500"
      },
      internationalStockFunds: {
        name: getTickerName(internationalStockMarketTicker),
        fillClass: "fill-cyan-400",
        strokeClass: "stroke-cyan-400"
      },
      stockMarketFunds: {
        name: getTickerName(stockMarketTicker),
        fillClass: "fill-blue-500",
        strokeClass: "stroke-blue-500"
      }
    })

    const { downsideDeviation, riskLevel } = investmentManager.calculateDownSideDeviationAndRiskLevelFromChartData(chartData)
    const { maximumDrawdownValue, maximumDrawdownPercentage } = investmentManager.calculateDrawDown(chartData)

    this.#renderResults({
      riskLevel,
      chartData,
      legendData,
      invested: `$${formatMoney(invested)}`,
      finalValue: `$${formatMoney(finalValue)}`,
      returns: `${returnsOnInvestment.toFixed(0)}%`,
      downsideDeviation: downsideDeviation.toFixed(2),
      drawDownText: `$${formatMoney(maximumDrawdownValue)} (${maximumDrawdownPercentage.toFixed(2)}%)`
    });
  }

  #renderResults(data) {
    const resultsElement = this.resultsRenderer.render(data);
    this.resultsContainerTarget.innerHTML = "";
    this.resultsContainerTarget.appendChild(resultsElement);
  }

  get resultsRenderer() {
    return new TemplateRenderer(this.resultsTemplateTarget);
  }
}
