import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fromCurrency", "toCurrency"]

  connect() {
    this.updateURL()
  }

  updateURL() {
    const fromCurrency = this.fromCurrencyTarget.value
    const toCurrency = this.toCurrencyTarget.value
    const currentPath = window.location.pathname
    const baseUrl = `/tools/exchange-rate-calculator/${fromCurrency}/${toCurrency}`

    // Only update URL if currencies are different from current URL
    if (!currentPath.includes(fromCurrency) || !currentPath.includes(toCurrency)) {
      history.pushState({}, "", baseUrl + window.location.search)
    }
  }

  currencyChanged() {
    this.updateURL()
  }
}