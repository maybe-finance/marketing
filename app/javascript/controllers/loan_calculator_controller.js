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
        const loanPeriod = formData.get("loan_period") || "years"; // Default loanPeriod to "years"
        const date = formData.get("date");

        let numberOfPayments;
        if (loanPeriod === "years") {
            numberOfPayments = loanTerm * 12;
        } else if (loanPeriod === "months") {
            numberOfPayments = loanTerm;
        } else {
            throw new Error("Invalid loan period");
        }

        const monthlyInterestRate = interestRate / 100 / 12;
        const monthlyPayments = (loanAmount * monthlyInterestRate) / (1 - Math.pow(1 + monthlyInterestRate, -numberOfPayments));
        const totalPaid = monthlyPayments * numberOfPayments;
        const totalInterestPaid = totalPaid - loanAmount;
        const totalPrincipalPaid = loanAmount;

        const startDate = new Date(date);
        const payoffDate = new Date(startDate.setMonth(startDate.getMonth() + numberOfPayments));
        const payoffDateString = payoffDate.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });

        const formatter = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
        });

        this.#renderResults({
            monthlyPayments: formatter.format(monthlyPayments),
            totalPrincipalPaid: formatter.format(totalPrincipalPaid),
            totalInterestPaid: formatter.format(totalInterestPaid),
            totalPaid: formatter.format(totalPaid),
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
