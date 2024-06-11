import { Controller } from "@hotwired/stimulus";
import TemplateRenderer from "helpers/template_renderer";

const COMPOUNDS_PER_YEAR = 12;

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

    const results = this.#calculateCompoundInterest(initialInvestments, regularContributions, yearsToGrow, interestRate);

    const formatter = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    });

    this.#renderResults({
      years: results,
      yearsToGrow: yearsToGrow,
      totalValue: formatter.format(results[results.length - 1].currentTotalValue.toFixed(2))
    });
  }

  #calculateCompoundInterest(initialInvestments, regularContributions, yearsToGrow, interestRate) {
    let currentTotalValue = initialInvestments;
    let totalContributed = initialInvestments;
    const results = [];

    const date = new Date();
    date.setFullYear(date.getFullYear());

    // Year 0
    results.push({
      year: 0,
      date: new Date(),
      contributed: initialInvestments,
      interest: initialInvestments,
      currentTotalValue: initialInvestments
    });

    for (let year = 1; year <= yearsToGrow; year++) {
      for (let month = 1; month <= 12; month++) {
        const interest = currentTotalValue * (interestRate / COMPOUNDS_PER_YEAR);
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

    return results;
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
