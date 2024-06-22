import { Controller } from "@hotwired/stimulus";
import TemplateRenderer from "helpers/template_renderer";

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

    this.#renderResults({
      invested,
      totalStockMarket,
      riskLevel: "High",
      finalValue: "$50,000.00",
      returns: "40%",
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
