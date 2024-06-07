import { Controller } from "@hotwired/stimulus";
import TemplateRenderer from "helpers/template_renderer";
// Connects to data-controller="inflation-calculator"
export default class extends Controller {
  static targets = ["resultsTemplate", "resultsContainer"];

  calculate(event) {
    event.preventDefault();
    const formData = new FormData(event.target);
    const parseFormData = (key) => parseFloat(formData.get(key).replace(/[^0-9.-]+/g, ""));
  
    const initialAmount = parseFormData("initial_amount");
    const inflationPercentage = parseFormData("inflation_percentage");
    const years = parseFormData("years");
  
    const futurePrice = initialAmount * Math.pow(1 + inflationPercentage / 100, years);
    const amountIncrease = futurePrice - initialAmount;
    const percentageIncrease = (amountIncrease / initialAmount) * 100;
  
    const futureValue = initialAmount / Math.pow(1 + inflationPercentage / 100, years);
    const amountLoss = initialAmount - futureValue;
    const percentageLoss = (amountLoss / initialAmount) * 100;
  
    const formatter = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    });
  
    const formatWithSign = (number, isPercentage = false) => {
      const formattedNumber = isPercentage ? `${number}%` : formatter.format(number);
      return number > 0 ? `+${formattedNumber}` : `${formattedNumber}`;
    };

    const formatNegative = (number, isPercentage = false) => {
      const formattedNumber = isPercentage ? `${number}%` : formatter.format(number);
      return `-${formattedNumber}`;
    };
  
    this.#renderResults({
      initialAmount: formatter.format(initialAmount),
      futurePrice: formatter.format(futurePrice),
      years: years,
      inflationRate: `${inflationPercentage.toFixed(2)}%`,
      amountIncrease: formatWithSign(amountIncrease),
      percentageIncrease: formatWithSign(percentageIncrease.toFixed(2), true),
      futureValue: formatter.format(futureValue),
      amountLoss: formatNegative(amountLoss),
      percentageLoss: formatWithSign(percentageLoss.toFixed(2), true)
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
