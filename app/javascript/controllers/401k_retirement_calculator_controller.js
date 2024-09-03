/**
 * 401k Retirement Calculator Controller
 * 
 * This Stimulus controller handles the functionality for a 401(k) retirement calculator.
 * It calculates compound interest based on user inputs and renders the results.
 */

import { Controller } from "@hotwired/stimulus";
import TemplateRenderer from "helpers/template_renderer";

const COMPOUNDS_PER_YEAR = 12;

// Connects to data-controller="401k-retirement-calculator"
export default class extends Controller {
	static targets = ["resultsTemplate", "resultsContainer"];

	/**
	 * Calculates the 401(k) retirement savings based on user inputs
	 * @param {Event} event - The form submission event
	 */
	calculate(event) {
		event.preventDefault();
		const formData = new FormData(event.target);
		const parseFormData = (key) =>
			parseFloat(formData.get(key).replace(/[^0-9.-]+/g, ""));

		// Parse form data
		const annualSalary = parseFormData("annual_salary");
		const monthlyContribution = parseFormData("monthly_contribution") / 100;
		const annualSalaryIncrease = parseFormData("annual_salary_increase") / 100;
		const currentAge = parseFormData("current_age");
		const retirementAge = parseFormData("retirement_age");
		const annualRateOfReturn = parseFormData("annual_rate_of_return") / 100;
		const current401kBalance = parseFormData("current_401k_balance");
		const employerMatch = parseFormData("employer_match") / 100;
		const salaryLimitMatch = parseFormData("salary_limit_match") / 100;

		// Calculate compound interest
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

		// Format results for display
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
				results[results.length - 1].totalEmployeeContributions.toFixed(2)
			),
			totalEmployerContributions: formatter.format(
				results[results.length - 1].totalEmployerContributions.toFixed(2)
			),
		});
	}

	/**
	 * Calculates compound interest for 401(k) savings
	 * @param {number} annualSalary - Annual salary
	 * @param {number} monthlyContribution - Monthly contribution as a decimal
	 * @param {number} annualSalaryIncrease - Annual salary increase as a decimal
	 * @param {number} currentAge - Current age
	 * @param {number} retirementAge - Retirement age
	 * @param {number} annualRateOfReturn - Annual rate of return as a decimal
	 * @param {number} current401kBalance - Current 401(k) balance
	 * @param {number} employerMatch - Employer match as a decimal
	 * @param {number} salaryLimitMatch - Salary limit for employer match as a decimal
	 * @returns {Array} Array of yearly results
	 */
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

			// Compound interest calculation
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

	/**
	 * Renders the calculation results using a template
	 * @param {Object} data - The data to be rendered in the template
	 */
	#renderResults(data) {
		const resultsElement = this.resultsRenderer.render(data);
		this.resultsContainerTarget.innerHTML = "";
		this.resultsContainerTarget.appendChild(resultsElement);
	}

	/**
	 * Gets the TemplateRenderer instance for rendering results
	 * @returns {TemplateRenderer} The TemplateRenderer instance
	 */
	get resultsRenderer() {
		return new TemplateRenderer(this.resultsTemplateTarget);
	}
}
