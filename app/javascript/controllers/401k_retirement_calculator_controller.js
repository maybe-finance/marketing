import { Controller } from "@hotwired/stimulus";
import TemplateRenderer from "helpers/template_renderer";

const COMPOUNDS_PER_YEAR = 12;

// Connects to data-controller="401k-retirement-calculator"
export default class extends Controller {
	static targets = ["resultsTemplate", "resultsContainer"];

	calculate(event) {
		event.preventDefault();
		const formData = new FormData(event.target);
		const parseFormData = (key) =>
			parseFloat(formData.get(key).replace(/[^0-9.-]+/g, ""));

		const annualSalary = parseFormData("annual_salary");
		const monthlyContribution = parseFormData("monthly_contribution") / 100;
		const annualSalaryIncrease =
			parseFormData("annual_salary_increase") / 100;
		const currentAge = parseFormData("current_age");
		const retirementAge = parseFormData("retirement_age");
		const annualRateOfReturn = parseFormData("annual_rate_of_return") / 100;
		const current401kBalance = parseFormData("current_401k_balance");
		const employerMatch = parseFormData("employer_match") / 100;
		const salaryLimitMatch = parseFormData("salary_limit_match") / 100;

		const results = this.#calculateCompoundInterest(
			annualSalary,
			monthlyContribution,
			annualSalaryIncrease,
			currentAge,
			retirementAge,
			annualRateOfReturn,
			current401kBalance,
			employerMatch,
			salaryLimitMatch
		);

		const formatter = new Intl.NumberFormat("en-US", {
			style: "currency",
			currency: "USD",
		});

		this.#renderResults({
			years: results,
			currentTotalValue: formatter.format(
				results[results.length - 1].currentTotalValue.toFixed(2)
			),
			totalEmployeeContributions: formatter.format(
				results[results.length - 1].totalEmployeeContributions.toFixed(
					2
				)
			),
			totalEmployerContributions: formatter.format(
				results[results.length - 1].totalEmployerContributions.toFixed(
					2
				)
			),
		});
	}

	#calculateCompoundInterest(
		annualSalary,
		monthlyContribution,
		annualSalaryIncrease,
		currentAge,
		retirementAge,
		annualRateOfReturn,
		current401kBalance,
		employerMatch,
		salaryLimitMatch
	) {
		const yearsToRetirement = retirementAge - currentAge;
		const monthlyRateOfReturn = annualRateOfReturn / 12;
		let estimatedRetirement = current401kBalance;
		const results = [];
		let totalEmployeeContributions = 0;
		let totalEmployerContributions = 0;

		const date = new Date();
		date.setFullYear(date.getFullYear());

		// Year 0
		results.push({
			year: 0,
			date: new Date(),
			contributed: current401kBalance,
			interest: current401kBalance,
			currentTotalValue: current401kBalance,
			totalEmployeeContributions: totalEmployeeContributions,
			totalEmployerContributions: totalEmployerContributions,
		});

		for (let year = 0; year < yearsToRetirement; year++) {
			const annualSalaryWithIncrease =
				annualSalary * Math.pow(1 + annualSalaryIncrease, year);
			const annualEmployeeContribution =
				annualSalaryWithIncrease * monthlyContribution;
			const employerContribution =
				Math.min(
					annualEmployeeContribution,
					annualSalaryWithIncrease * salaryLimitMatch
				) * employerMatch;
			const totalAnnualContribution =
				annualEmployeeContribution + employerContribution;

			totalEmployeeContributions += annualEmployeeContribution;
			totalEmployerContributions += employerContribution;

			for (let month = 0; month < 12; month++) {
				estimatedRetirement =
					(estimatedRetirement +
						totalAnnualContribution / COMPOUNDS_PER_YEAR) *
					(1 + monthlyRateOfReturn);
			}
			results.push({
				year: year + 1,
				date: new Date(date.setFullYear(date.getFullYear() + 1)),
				contributed: totalEmployeeContributions,
				interest:
					totalEmployeeContributions + totalEmployerContributions,
				currentTotalValue: estimatedRetirement,
				totalEmployeeContributions: totalEmployeeContributions,
				totalEmployerContributions: totalEmployerContributions,
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
