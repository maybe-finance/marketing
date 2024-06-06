import { Controller } from "@hotwired/stimulus";
import TemplateRenderer from "helpers/template_renderer";

// Connects to data-controller="roi-calculator-controller"
export default class extends Controller {
    static targets = [
        "resultsTemplate",
        "resultsContainer",
        "monthlyPayments",
        "totalPrincipalPaid",
        "totalInterestPaid",
        "totalPaid",
        "totalNumberOfPayments",
    ];

    calculate(event) {
        event.preventDefault();
        const formData = new FormData(event.target);
        const loanAmount = parseFloat(formData.get("loan_amount"));
        const interestRate = parseFloat(formData.get("interest_rate"));
        const loanTerm = parseFloat(formData.get("loan_term"));
        const loanPeriod = formData.get("loan_period");
        const date = formData.get("date");

        let numberOfPayments;
        if (loanPeriod === "years") {
            numberOfPayments = loanTerm * 12;
        } else if (loanPeriod === "months") {
            numberOfPayments = loanTerm;
        } else {
            throw new Error("Invalid investment period");
        }

        const monthlyInterestRate = interestRate / 100 / 12;
        const monthlyPayments = (loanAmount * monthlyInterestRate) / (1 - Math.pow(1 + monthlyInterestRate, -numberOfPayments));
        const totalPaid = monthlyPayments * numberOfPayments;
        const totalInterestPaid = totalPaid - loanAmount;
        const totalPrincipalPaid = loanAmount;

        const startDate = new Date(date);
        const payoffDate = new Date(startDate.setMonth(startDate.getMonth() + numberOfPayments));
        const payoffDateString = payoffDate.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });

        this.#renderResults({
            monthlyPayments: monthlyPayments.toFixed(2),
            totalPrincipalPaid: totalPrincipalPaid.toFixed(2),
            totalInterestPaid: totalInterestPaid.toFixed(2),
            totalPaid: totalPaid.toFixed(2),
            totalNumberOfPayments: numberOfPayments,
            estimatedPayoffDate: payoffDateString,
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
