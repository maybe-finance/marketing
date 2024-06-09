import { Controller } from "@hotwired/stimulus";
import TemplateRenderer from "helpers/template_renderer";

const DAYS_IN_MONTH = 365.25 / 12;
const SECONDS_IN_A_DAY = 86400;

// Connects to data-controller="compound-interest-calculator"
export default class extends Controller {
  static targets = ["resultsTemplate", "resultsContainer"];

  calculate(event) {
    event.preventDefault();
    const formData = new FormData(event.target);
    const parseFormData = key => parseFloat(formData.get(key).replace(/[^0-9.-]+/g, ''));

    const initialInvestments = parseFormData("initial_investment");
    const regularContributions = parseFormData("monthly_expenses");
    const yearsToGrow = parseFormData("years_to_grow");
    const interestRate = parseFormData("interest_rate") / 100;
    const compoundsPerYear = 12; // Assuming monthly compounding

    let currentTotalValue = initialInvestments;
    let totalContributed = initialInvestments;
    const results = [];

    const date = new Date();
    date.setFullYear(date.getFullYear());

    for (let year = 1; year <= yearsToGrow; year++) {
      let yearlyInterest = 0;
      for (let month = 1; month <= 12; month++) {
        const interest = currentTotalValue * (interestRate / compoundsPerYear);
        yearlyInterest += interest;
        currentTotalValue += interest + regularContributions;
        totalContributed += regularContributions;
      }
      results.push({
        year: year,
        date: new Date(date.setFullYear(date.getFullYear() + 1)),
        contributed: totalContributed,
        interest: currentTotalValue,
        currentTotalValue: currentTotalValue
      });
    }

    results.unshift({
      year: 0,
      date: new Date(),
      contributed: initialInvestments,
      interest: initialInvestments,
      currentTotalValue: initialInvestments
    })

    const formatter = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    });

    this.#renderResults({
      // contributed: 16000
      // currentTotalValue: 16784.559305094954
      // interest: 784.5593050949526
      // year: 1

      years: results,
      yearsToGrow: yearsToGrow,
      totalValue: formatter.format(currentTotalValue.toFixed(2))
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
