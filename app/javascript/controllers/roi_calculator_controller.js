import { Controller } from "@hotwired/stimulus";
import TemplateRenderer from "helpers/template_renderer";

// Connects to data-controller="roi-calculator-controller"
export default class extends Controller {
	static targets = ["resultsTemplate", "resultsContainer"];

	calculate(event) {
		event.preventDefault();
		const formData = new FormData(event.target);
		let amountInvested = parseFloat(formData.get("amount_invested"));
		const amountReturned = parseFloat(formData.get("amount_returned"));
		let investmentLength = parseFloat(formData.get("investment_length"));
		const investmentPeriod = formData.get("time_period");

		// Convert investmentLength to years if needed
		if (investmentPeriod === "weeks") {
			investmentLength = investmentLength / 52.1775; // Convert weeks to years
		} else if (investmentPeriod === "days") {
			investmentLength = investmentLength / 365.25; // Convert days to years
		}

		const investmentGain = amountReturned - amountInvested;
		const roi = (investmentGain / amountInvested) * 100;
		const annualRoi = roi / investmentLength;

		this.#renderResults({
			InvestmentGain: new Intl.NumberFormat('en-US').format(investmentGain.toFixed(2)),
			Roi: this.#formatNumber(roi.toFixed(2)),
			AnnualizedRoi: this.#formatNumber(annualRoi.toFixed(2)),
			RoiClass:
				roi >= 0
					? "text-green-500 text-4xl font-medium"
					: "text-red-500 text-4xl font-medium",
			AnnualizedRoiClass:
				annualRoi >= 0
					? "text-green-500 text-4xl font-medium"
					: "text-red-500 text-4xl font-medium",
		});
	}

	#formatNumber(value) {
		const number = parseFloat(value);
		const formattedValue = new Intl.NumberFormat('en-US').format(number);
		return number >= 0 ? `+${formattedValue}` : formattedValue;
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
