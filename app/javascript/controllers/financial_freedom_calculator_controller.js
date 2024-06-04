import { Controller } from "@hotwired/stimulus";
import TemplateRenderer from "helpers/template_renderer";

const DAYS_IN_MONTH = 365.25 / 12;
const SECONDS_IN_A_DAY = 86400;

// Connects to data-controller="financial-freedom-calculator"
export default class extends Controller {
  static targets = ["resultsTemplate", "resultsContainer"];

  calculate(event) {
    event.preventDefault();
    console.log("Calculating time until broke...");
    const formData = new FormData(event.target);
    let currentSavings = parseFloat(formData.get("current_savings"));
    const monthlyExpenses = parseFloat(formData.get("monthly_expenses"));
    const monthlySavingsGrowthRate = parseFloat(
      formData.get("monthly_savings_growth_rate"),
    );

    const firstMonthGrowth = currentSavings * (monthlySavingsGrowthRate / 100);
    if (firstMonthGrowth >= monthlyExpenses) {
      console.log("You're financially free!");
      this.#renderResults({ months: [], secondsLeft: Infinity });
      return;
    }

    const months = [currentSavings];
    while (currentSavings > 0) {
      currentSavings += currentSavings * (monthlySavingsGrowthRate / 100);
      currentSavings -= monthlyExpenses;
      months.push(currentSavings);
    }

    let daysLeft = DAYS_IN_MONTH * months.length;

    const finalMonthSavings = months[months.length - 1];
    if (finalMonthSavings < 0) {
      const avgDailyExpenses = monthlyExpenses / DAYS_IN_MONTH;
      const daysOverdrawn = Math.abs(finalMonthSavings / avgDailyExpenses);
      daysLeft -= daysOverdrawn;
    }

    const today = new Date();
    const data = months.map((savingsRemaining) => {
      return {
        date: new Date(today.setMonth(today.getMonth() + 1)),
        savingsRemaining: Math.max(savingsRemaining, 0),
        monthlyExpenditure: monthlyExpenses,
      };
    });

    this.#renderResults({
      months: data,
      secondsLeft: daysLeft * SECONDS_IN_A_DAY,
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
