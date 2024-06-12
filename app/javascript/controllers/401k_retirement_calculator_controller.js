import { Controller } from '@hotwired/stimulus';
import TemplateRenderer from 'helpers/template_renderer';

// Connects to data-controller="401k-retirement-calculator"
export default class extends Controller {
	static targets = ['resultsTemplate', 'resultsContainer'];

	calculate(event) {
		event.preventDefault();
		const formData = new FormData(event.target);
		const parseFormData = (key) =>
			parseFloat(formData.get(key).replace(/[^0-9.-]+/g, ''));

		const annualSalary = parseFormData('annual_salary');
		const monthlyContribution = parseFormData('monthly_contribution') / 100;
		const annualSalaryIncrease = parseFormData('annual_salary_increase') / 100;
		const currentAge = parseFormData('current_age');
		const retirementAge = parseFormData('retirement_age');
		const annualRateOfReturn = parseFormData('annual_rate_of_return') / 100;
		const current401kBalance = parseFormData('current_401k_balance');
		const employerMatch = parseFormData('employer_match') / 100;
		const salaryLimitMatch = parseFormData('salary_limit_match') / 100;

		const results = this.#calculate401kRetirement(
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

		const formatter = new Intl.NumberFormat('en-US', {
			style: 'currency',
			currency: 'USD',
		});

		this.#renderResults({
			years: results,
			estimatedRetirement: formatter.format(
				results[results.length - 1].currentTotalValue.toFixed(2)
			),
			employeeContribution: formatter.format(
				results[results.length - 1].employeeContribution.toFixed(2)
			),
			employerContribution: formatter.format(
				results[results.length - 1].employerContribution.toFixed(2)
			),
		});
	}

	#calculate401kRetirement(
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
		let results = [];
		let employeeContributions = 0;
		let employerContributions = 0;
		let currentTotalValue = current401kBalance || 0;

		const date = new Date();
		date.setFullYear(date.getFullYear());

		// Year 0
		results.push({
			year: 0,
			date: new Date(),
			employeeContribution: employeeContributions,
			employerContribution: employerContributions,
			totalContribution: employeeContributions + employerContributions,
			interest: 0,
			currentTotalValue: currentTotalValue,
		});

		for (let year = 1; year <= retirementAge - currentAge; year++) {
			const annualSalaryIncreaseAmount = annualSalary * annualSalaryIncrease;
			annualSalary += annualSalaryIncreaseAmount;

			const annualEmployeeContribution =
				(annualSalary / 12) * monthlyContribution * 12;
			employeeContributions += annualEmployeeContribution;

			const annualEmployerMatch = Math.min(
				(annualSalary / 12) * employerMatch,
				annualSalary * salaryLimitMatch
			);
			employerContributions += annualEmployerMatch;

			const annualTotalContribution =
				annualEmployeeContribution + annualEmployerMatch;

			const annualInterest = currentTotalValue * annualRateOfReturn;
			currentTotalValue += annualTotalContribution + annualInterest;

			results.push({
				year: year,
				date: new Date(date.setFullYear(date.getFullYear() + 1)),
				employeeContribution: employeeContributions,
				employerContribution: employerContributions,
				totalContribution: employeeContributions + employerContributions,
				interest: annualInterest,
				currentTotalValue: currentTotalValue,
			});
		}
		return results;
	}

	#renderResults(data) {
		const resultsElement = this.resultsRenderer.render(data);
		this.resultsContainerTarget.innerHTML = '';
		this.resultsContainerTarget.appendChild(resultsElement);
	}

	get resultsRenderer() {
		return new TemplateRenderer(this.resultsTemplateTarget);
	}
}
