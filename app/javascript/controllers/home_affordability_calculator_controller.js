import { Controller } from "@hotwired/stimulus";
import TemplateRenderer from "helpers/template_renderer";

// Connects to data-controller="home-affordability-calculator"
export default class extends Controller {
	static targets = ["resultsTemplate", "resultsContainer", "loanInterestRate"];

	connect() {
		console.log(this.loanInterestRateTarget.dataset);
		this.rate30 = this.loanInterestRateTarget.dataset['homeAffordabilityCalculatorRate-30'];
		this.rate15 = this.loanInterestRateTarget.dataset['homeAffordabilityCalculatorRate-15'];

		const loanDuration = document.querySelector('[data-home-affordability-calculator-target="loanDuration"]');
		if (loanDuration) {
			loanDuration.addEventListener('input', this.updateInterestRate.bind(this));
		}
	}

	updateInterestRate(event) {
		const duration = parseInt(event.target.value);
		const newRate = duration <= 15 ? this.rate15 : this.rate30;
		this.loanInterestRateTarget.value = newRate;
	}

	#calculatePresentValue(payment, interestRate, periods) {
		if (interestRate === 0) {
			return payment * periods;
		} else {
			return payment * (1 - Math.pow(1 + interestRate, -periods)) / interestRate;
		}
	}

	// Modify the calculate function
	calculate(event) {
		event.preventDefault();
		const formData = new FormData(event.target);
		const parseFormData = (key) => parseFloat(formData.get(key).replace(/[^0-9.-]+/g, ""));

		const targetHomePrice = parseFormData("desired_home_price");
		const annualIncome = parseFormData("annual_pre_tax_income");
		const otherMonthlyDebtPayments = parseFormData("monthly_debt_payments");
		const downPayment = parseFormData("down_payment");
		const loanTermYears = parseFormData("loan_duration");
		const loanInterestRate = parseFormData("loan_interest_rate") / 100;
		const annualPropertyInsurance = targetHomePrice * 0.0065;
		const annualPropertyTaxes = targetHomePrice * 0.009;
		const otherMonthlyCosts = parseFormData("hoa_plus_pmi");
		// Base DTI values
		const baseDTI = [0.2, 0.28, 0.36, 0.44];

		// Step 2 - Calculations 
		const annualizedOtherMonthlyDebtPayments = (otherMonthlyDebtPayments * 12) / annualIncome;

		// Step 3 - Determine Multiplier
		let multiplier = 1;
		if (annualizedOtherMonthlyDebtPayments > 0.08) {
			multiplier = (0.36 - annualizedOtherMonthlyDebtPayments) / 0.28;
		}

		// Step 4 - Multiply Base DTI by Multiplier
		const adjustedDTI = baseDTI.map(dti => dti * multiplier);

		// Step 5 - Calculate Monthly Payment using Adjusted DTI
		const monthlyIncome = annualIncome / 12;
		const monthlyPayment = adjustedDTI.map(dti => (dti * annualIncome) / 12);

		// Step 6 - Calculate Base PV
		const periods = loanTermYears * 12;
		const basePV = monthlyPayment.map(payment => this.#calculatePresentValue(payment, loanInterestRate / 12, periods));

		// Step 7 - Add Down Payment to Base PV
		const basePVWithDownPayment = basePV.map(pv => pv + downPayment);

		// Step 8 - Calculate Monthly Insurance and Tax Costs
		const monthlyInsuranceTaxCosts = basePVWithDownPayment.map(pv => pv * (annualPropertyInsurance + annualPropertyTaxes) / targetHomePrice / 12);

		// Step 9 - Subtract Monthly Insurance, Taxes, and Other from Payment  
		const adjustedMonthlyPayment = monthlyPayment.map((payment, index) => payment - monthlyInsuranceTaxCosts[index] - otherMonthlyCosts);

		// Step 10 - Calculate PV based on Adjusted Payment
		const adjustedPV = adjustedMonthlyPayment.map(payment => this.#calculatePresentValue(payment, loanInterestRate / 12, periods));

		// Step 11 - Add Down Payment to Calculated PV
		const adjustedPVWithDownPayment = adjustedPV.map(pv => pv + downPayment);

		const segments = [
			{ category: "Affordable", value: adjustedPVWithDownPayment[0] },
			{ category: "Good", value: adjustedPVWithDownPayment[1] - adjustedPVWithDownPayment[0] },
			{ category: "Caution", value: adjustedPVWithDownPayment[2] - adjustedPVWithDownPayment[1] },
			{ category: "Risky", value: adjustedPVWithDownPayment[3] - adjustedPVWithDownPayment[2] }
		];

		const chartData = {
			segments: segments,
			desiredHomePrice: targetHomePrice,
		};

		const formatter = new Intl.NumberFormat("en-US", {
			style: "currency",
			currency: "USD",
		});

		const resultData = {
			affordableAmount: formatter.format(adjustedPVWithDownPayment[0]),
			chartData: JSON.stringify(chartData)
		}
		console.log(chartData);
		this.#renderResults(resultData);
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