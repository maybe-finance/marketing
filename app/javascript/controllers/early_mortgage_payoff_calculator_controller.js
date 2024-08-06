import { Controller } from "@hotwired/stimulus";
import TemplateRenderer from "helpers/template_renderer";

// Connects to data-controller="early-mortgage-payoff-calculator"
export default class extends Controller {
  static targets = ["resultsTemplate", "resultsContainer", "netDifferenceValue", "netDifferenceComment"];

  connect() {
    this.calculate();
  }

  calculate() {
    const formData = new FormData(this.element.querySelector('form'));
    const parseFormData = key => parseFloat(formData.get(key).replace(/[^0-9.-]+/g, ''));

    const loanAmount = parseFormData("loan_amount");
    const originalTerm = parseFormData("original_term");
    const yearsLeft = parseFormData("years_left");
    const interestRate = parseFormData("interest_rate") / 100;
    const extraPayment = parseFormData("extra_payment");
    const savingsRate = parseFormData("savings_rate") / 100; // Annual rate

    const results = this.#calculatePayoff(loanAmount, originalTerm, yearsLeft, interestRate, extraPayment, savingsRate);

    this.#renderResults(results);
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

    return {
      timeSaved,
      totalInterest,
      totalInterestWithExtra,
      interestSavings,
      originalPayoffDate,
      newPayoffDate,
      totalPrincipalAndInterest,
      totalPrincipalAndInterestWithExtra,
      savingsBalance,
      netDifference
    };
  }

  #renderResults(results) {
    const formatter = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    });

    const formattedResults = {
      timeSaved: `${Math.floor(results.timeSaved / 12)} years, ${results.timeSaved % 12} months`,
      totalInterest: formatter.format(results.totalInterest),
      totalInterestWithExtra: formatter.format(results.totalInterestWithExtra),
      interestSavings: formatter.format(results.interestSavings),
      originalPayoffDate: results.originalPayoffDate.toLocaleDateString('en-US', { year: 'numeric', month: 'long' }),
      newPayoffDate: results.newPayoffDate.toLocaleDateString('en-US', { year: 'numeric', month: 'long' }),
      totalPrincipalAndInterest: formatter.format(results.totalPrincipalAndInterest),
      totalPrincipalAndInterestWithExtra: formatter.format(results.totalPrincipalAndInterestWithExtra),
      savingsAccountBalance: formatter.format(results.savingsBalance),
      netDifference: formatter.format(results.netDifference)
    };

    const resultsElement = this.resultsRenderer.render(formattedResults);
    this.resultsContainerTarget.innerHTML = "";
    this.resultsContainerTarget.appendChild(resultsElement);

    // Color the net difference and add commentary
    const netDifferenceValue = this.netDifferenceValueTarget;
    const netDifferenceComment = this.netDifferenceCommentTarget;

    if (results.netDifference > 0) {
      netDifferenceValue.classList.add('text-green-600');
      netDifferenceComment.textContent = "Investing the extra payments could potentially yield better returns than paying off the mortgage early.";
      netDifferenceComment.classList.add('text-green-600');
    } else if (results.netDifference < 0) {
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