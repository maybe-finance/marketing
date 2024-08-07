import { Controller } from "@hotwired/stimulus";
import TemplateRenderer from "helpers/template_renderer";

export default class extends Controller {
  static targets = ["resultsTemplate", "resultsContainer", "netDifferenceValue", "netDifferenceComment", "form"];

  connect() {
    this.loadFormData();
  }

  calculate(event) {
    event.preventDefault();
    const formData = new FormData(event.target);
    const parseFormData = key => parseFloat(formData.get(key).replace(/[^0-9.-]+/g, ''));

    const loanAmount = parseFormData("loan_amount");
    const originalTerm = parseFormData("original_term");
    const yearsLeft = parseFormData("years_left");
    const interestRate = parseFormData("interest_rate") / 100;
    const extraPayment = parseFormData("extra_payment");
    const savingsRate = parseFormData("savings_rate") / 100;

    this.saveFormData();

    const results = this.#calculatePayoff(loanAmount, originalTerm, yearsLeft, interestRate, extraPayment, savingsRate);

    this.#renderResults(results);
  }

  loadFormData() {
    const savedData = JSON.parse(localStorage.getItem('earlyMortgagePayoffCalculator')) || {};
    Object.keys(savedData).forEach(key => {
      const input = this.formTarget.elements[key];
      if (input) {
        input.value = savedData[key];
      }
    });
  }

  saveFormData() {
    const formData = new FormData(event.target);
    const dataToSave = {};
    for (let [key, value] of formData.entries()) {
      dataToSave[key] = value;
    }
    localStorage.setItem('earlyMortgagePayoffCalculator', JSON.stringify(dataToSave));
  }

  #calculatePayoff(loanAmount, originalTerm, yearsLeft, interestRate, extraPayment, savingsRate) {
    const monthlyRate = interestRate / 12;
    const totalPayments = yearsLeft * 12;
    const regularPayment = (loanAmount * monthlyRate * Math.pow(1 + monthlyRate, totalPayments)) / (Math.pow(1 + monthlyRate, totalPayments) - 1);

    let balance = loanAmount;
    let months = 0;
    let totalInterest = 0;
    let totalInterestWithExtra = 0;

    // Calculate original payoff date
    const originalPayoffDate = new Date();
    originalPayoffDate.setMonth(originalPayoffDate.getMonth() + totalPayments);

    // Calculate total interest for original schedule
    let originalBalance = loanAmount;
    for (let i = 0; i < totalPayments; i++) {
      const interestPayment = originalBalance * monthlyRate;
      totalInterest += interestPayment;
      originalBalance -= (regularPayment - interestPayment);
    }

    while (balance > 0) {
      months++;
      const interestPayment = balance * monthlyRate;
      const principalPayment = regularPayment - interestPayment;
      
      totalInterestWithExtra += interestPayment;
      
      if (extraPayment > 0) {
        balance -= (principalPayment + extraPayment);
      } else {
        balance -= principalPayment;
      }
    }

    const timeSaved = totalPayments - months;
    const interestSavings = totalInterest - totalInterestWithExtra;
    const newPayoffDate = new Date();
    newPayoffDate.setMonth(newPayoffDate.getMonth() + months);

    const totalPrincipalAndInterest = loanAmount + totalInterest;
    const totalPrincipalAndInterestWithExtra = loanAmount + totalInterestWithExtra;

    // Calculate savings account balance using annual rate
    let savingsBalance = 0;
    for (let i = 0; i < months; i++) {
      savingsBalance += extraPayment;
      savingsBalance *= (1 + savingsRate / 12); // Convert annual rate to monthly
    }

    const netDifference = savingsBalance - interestSavings;

    const chartData = this.#generateChartData(loanAmount, yearsLeft, interestRate, regularPayment, extraPayment);

    return {
      loanAmount,
      yearsLeft,
      interestRate,
      timeSaved,
      totalInterest,
      totalInterestWithExtra,
      interestSavings,
      originalPayoffDate,
      newPayoffDate,
      totalPrincipalAndInterest,
      totalPrincipalAndInterestWithExtra,
      savingsBalance,
      netDifference,
      monthlyPayment: regularPayment,
      monthlyPaymentWithExtra: regularPayment + extraPayment,
      chartData,
    };
  }

  #generateChartData(principal, years, annualRate, monthlyPayment, extraPayment) {
    const monthlyRate = annualRate / 12;
    const totalPayments = years * 12;
    let originalBalance = principal;
    let earlyPayoffBalance = principal;
    const data = [];

    const date = new Date();
    date.setFullYear(date.getFullYear());

    for (let year = 0; year <= years; year++) {
      data.push({
        year,
        date: new Date(date.setFullYear(date.getFullYear() + (year === 0 ? 0 : 1))),
        originalMortgage: originalBalance,
        earlyPayoff: earlyPayoffBalance,
      });

      for (let month = 1; month <= 12; month++) {
        if (originalBalance > 0) {
          const originalInterest = originalBalance * monthlyRate;
          originalBalance -= (monthlyPayment - originalInterest);
        }

        if (earlyPayoffBalance > 0) {
          const earlyPayoffInterest = earlyPayoffBalance * monthlyRate;
          earlyPayoffBalance -= (monthlyPayment + extraPayment - earlyPayoffInterest);
        }
      }

      originalBalance = Math.max(originalBalance, 0);
      earlyPayoffBalance = Math.max(earlyPayoffBalance, 0);
    }

    return data;
  }

  #renderResults(results) {
    const formatter = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    });

    const formattedResults = {
      timeSaved: `${Math.floor(results.timeSaved / 12)} years, ${results.timeSaved % 12} months`,
      interestSavings: formatter.format(results.interestSavings),
      savingsAccountBalance: formatter.format(results.savingsBalance),
      netDifference: formatter.format(Math.abs(results.netDifference)),
      yearsToGrow: results.yearsLeft,
      years: results.chartData.map(d => ({
        ...d,
        contributed: d.originalMortgage,
        interest: d.earlyPayoff
      }))
    };

    const resultsElement = this.resultsRenderer.render(formattedResults);
    this.resultsContainerTarget.innerHTML = "";
    this.resultsContainerTarget.appendChild(resultsElement);

    this.#updateNetDifference(results.netDifference);

    // Update chart data
    const chartElement = this.element.querySelector('#early-mortgage-payoff-calculator-chart');
    if (chartElement) {
      chartElement.setAttribute('data-time-series-two-lines-chart-data-value', JSON.stringify(formattedResults.years));
    }
  }

  #updateNetDifference(netDifference) {
    const netDifferenceValue = this.netDifferenceValueTarget;
    const netDifferenceComment = this.netDifferenceCommentTarget;

    netDifferenceValue.classList.remove('text-green-600', 'text-red-600', 'text-gray-600');
    netDifferenceComment.classList.remove('text-green-600', 'text-red-600', 'text-gray-600');

    if (netDifference > 0) {
      netDifferenceValue.classList.add('text-green-600');
      netDifferenceComment.textContent = "Investing the extra payments could potentially yield better returns than paying off the mortgage early.";
      netDifferenceComment.classList.add('text-green-600');
    } else if (netDifference < 0) {
      netDifferenceValue.classList.add('text-red-600');
      netDifferenceComment.textContent = "Paying off the mortgage early could potentially save you more money than investing the extra payments.";
      netDifferenceComment.classList.add('text-red-600');
    } else {
      netDifferenceComment.textContent = "The financial outcome is roughly the same whether you pay off the mortgage early or invest the extra payments.";
      netDifferenceComment.classList.add('text-gray-600');
    }
  }

  get resultsRenderer() {
    return new TemplateRenderer(this.resultsTemplateTarget);
  }
}