import { Controller } from "@hotwired/stimulus";
import TemplateRenderer from "helpers/template_renderer";

const DURATION_IN_YEARS = 25;

// Connects to data-controller="boggleheads-growth-calculator"
export default class extends Controller {
  static targets = ["resultsTemplate", "resultsContainer"];

  calculate(event) {
    event.preventDefault();
    const formData = new FormData(event.target);
    const parseFormData = key => parseFloat(formData.get(key).replace(/[^0-9.-]+/g, ''));

    const getInvestmentPercentage = (key) => {
      const target = document.getElementById("stock_market_percentage")
      return parseFloat(target.value.replace(/[^0-9.-]+/g, ''));
    }

    const invested = "$" + parseFormData("invested_amount");

    const totalStockMarket = getInvestmentPercentage("stock_market_percentage");
    const totalInternationalStock = getInvestmentPercentage("international_stock_market_percentage");
    const totalBondMarket = getInvestmentPercentage("bond_market_percentage");

    const chartData = this.#calculateBoggleHeadsGrowthData()

    const legendData = {
      value: {
        name: "Portfolio Value",
        fillClass: "fill-violet-600",
        strokeClass: "stroke-violet-600"
      },
      internationalStockFunds: {
        label: "International Stock Market",
        fillClass: "fill-violet-600",
        strokeClass: "stroke-violet-600"
      },
      bondMarketFunds: {
        label: "Bond Market",
        fillClass: "fill-violet-600",
        strokeClass: "stroke-violet-600"
      },
      stockMarketFunds: {
        label: "Stock Market",
        fillClass: "fill-violet-600",
        strokeClass: "stroke-violet-600"
      }
    }

    this.#renderResults({
      invested,
      totalStockMarket,
      riskLevel: "High",
      finalValue: "$50,000.00",
      returns: "40%",
      chartData,
      legendData
    });
  }

  #renderResults(data) {
    const resultsElement = this.resultsRenderer.render(data);
    this.resultsContainerTarget.innerHTML = "";
    this.resultsContainerTarget.appendChild(resultsElement);
  }

  #calculateBoggleHeadsGrowthData() {
    const chartData = []

    const currentYear = new Date().getFullYear();
    let year = currentYear - DURATION_IN_YEARS;

    while(year <= currentYear) {
      chartData.push({
        year: year,
        date: new Date(year, 0, 1),
        value: Math.floor(Math.random() * 1000000000),
        bondMarketFunds: Math.floor(Math.random() * 1000000000),
        internationalStockFunds: Math.floor(Math.random() * 1000000000),
        stockMarketFunds: Math.floor(Math.random() * 1000000000),
      })
      year += 1;
    }

    return chartData;
  }

  get resultsRenderer() {
    return new TemplateRenderer(this.resultsTemplateTarget);
  }
}
