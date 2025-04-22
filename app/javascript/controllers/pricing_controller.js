import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "monthlyPrice", "yearlyPrice", "monthlyBilling", "yearlyBilling", "yearlyBillingBadge"]
  static values = {
    monthlyPrice: Number,
    yearlyPrice: Number
  }

  connect() {
    this.showMonthlyPricing()
  }

  toggle() {
    if (this.toggleTarget.checked) {
      this.showYearlyPricing()
    } else {
      this.showMonthlyPricing()
    }
  }

  showMonthlyPricing() {
    this.monthlyPriceTargets.forEach(el => el.classList.remove('hidden'))
    this.yearlyPriceTargets.forEach(el => el.classList.add('hidden'))
    this.monthlyBillingTarget.classList.add('text-gray-900', 'font-medium')
    this.yearlyBillingTarget.classList.remove('text-gray-900', 'font-medium')
    this.yearlyBillingBadgeTarget.classList.remove('text-gray-900')
  }

  showYearlyPricing() {
    this.monthlyPriceTargets.forEach(el => el.classList.add('hidden'))
    this.yearlyPriceTargets.forEach(el => el.classList.remove('hidden'))
    this.monthlyBillingTarget.classList.remove('text-gray-900', 'font-medium')
    this.yearlyBillingTarget.classList.add('text-gray-900', 'font-medium')
    this.yearlyBillingBadgeTarget.classList.add('text-gray-900')
  }
}
