import { Controller } from "@hotwired/stimulus";

import BoggleHeads from "helpers/bogle_heads"
import SEED_STOCK_DATA from "helpers/seed_stock_data";
import TemplateRenderer from "helpers/template_renderer";

// Connects to data-controller="boggleheads-growth-calculator"
export default class extends Controller {
  static targets = ["resultsTemplate", "resultsContainer"];

  async calculate(event) {
    event.preventDefault();
    const formData = new FormData(event.target);
    const parseFormData = key => parseFloat(formData.get(key).replace(/[^0-9.-]+/g, ''));

    const getTicker = (key) => {
      const target = document.querySelector(`input[name='${key}']`);
      return target ? target.value : "";
    }

    const getInvestmentPercentage = (key) => {
      const target = document.getElementById(key)
      return parseFloat(target.value.replace(/[^0-9.-]+/g, ''));
    }

    const invested = parseFormData("invested_amount");

    const stockMarketTicker = getTicker("stock_market_ticker")
    const bondMarketTicker = getTicker("bond_market_ticker")
    const internationalStockMarketTicker = getTicker("international_stock_market_ticker")
    const tickers = [stockMarketTicker, bondMarketTicker, internationalStockMarketTicker]

    const stockData = await this.#fetchStockData(tickers);

    const totalStockMarketAllocation = getInvestmentPercentage("stock_market_percentage");
    const totalInternationalStockAllocation = getInvestmentPercentage("international_stock_market_percentage");
    const totalBondMarketAllocation = getInvestmentPercentage("bond_market_percentage");

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

    const processedStockData = stockData.reduce((prev, curr) => ({ ...prev, [curr.ticker]: curr.data }), {})

    const boglehead = new BoggleHeads(invested, fundAllocations, processedStockData, tickerFundCategories)
    const chartData = boglehead.makeChartData()

    const finalValue = chartData[chartData.length - 1].value
    const profitOrLoss = finalValue - invested
    const returnsOnInvestment = Math.floor((profitOrLoss/invested) * 100)

    const legendData = {
      value: {
        name: "Portfolio Value",
        fillClass: "fill-violet-600",
        strokeClass: "stroke-violet-600"
      },
      internationalStockFunds: {
        label: internationalStockMarketTicker,
        fillClass: "fill-violet-600",
        strokeClass: "stroke-violet-600"
      },
      bondMarketFunds: {
        label: bondMarketTicker,
        fillClass: "fill-violet-600",
        strokeClass: "stroke-violet-600"
      },
      stockMarketFunds: {
        label: stockMarketTicker,
        fillClass: "fill-violet-600",
        strokeClass: "stroke-violet-600"
      }
    }

    // TODO: compute risk level from boglehead instance.
    const riskLevels = ["High", "Medium", "Low"];
    const riskLevel = riskLevels[Math.floor(Math.random() * riskLevels.length)];

    this.#renderResults({
      invested: `$${invested}`,
      finalValue: `$${finalValue}`,
      returns: `${returnsOnInvestment}%`,
      totalStockMarket: totalStockMarketAllocation,
      riskLevel,
      chartData,
      legendData
    });
  }

  async #fetchStockData(tickers) {
    // TODO: this is for development purposes only - remove when done
    if (SEED_STOCK_DATA) {
      console.log("returning seed data", SEED_STOCK_DATA)
      return SEED_STOCK_DATA
    }

    const params = new URLSearchParams({})
    tickers.forEach(ticker => params.append("tickers[]", ticker))
    
    const url = `/stocks?${params.toString()}`

    const response = await fetch(url, {
      method: "GET",
      headers: {
        accept: "application/json",
        "content-type": "application/json",
      }
    });
    if (!response.ok) {
      console.log("Error fetching stock data", response);
    }

    return await response.json()
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
