import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fromCurrency", "toCurrency"]

  connect() {
    // Only update URL on connect if we're not on the root calculator page
    if (window.location.pathname !== '/tools/exchange-rate-calculator') {
      this.updateURL()
    }
  }

  updateURL() {
    const fromCurrency = this.fromCurrencyTarget.value
    const toCurrency = this.toCurrencyTarget.value
    const currentPath = window.location.pathname
    const pathParts = currentPath.split('/')

    // Check if current URL has an amount
    const hasAmount = !isNaN(pathParts[pathParts.length - 1])
    const currentAmount = hasAmount ? pathParts[pathParts.length - 1] : '1'

    const desiredUrl = `/tools/exchange-rate-calculator/${fromCurrency}/${toCurrency}${hasAmount ? `/${currentAmount}` : ''}`

    if (currentPath !== desiredUrl) {
      history.pushState({}, "", desiredUrl)

      // Prevent form submission entirely when URL changes
      this.element.addEventListener('submit', this.preventSubmit, { once: true })

      // Trigger a Turbo visit instead
      Turbo.visit(desiredUrl, { action: 'replace' })
    }
  }

  preventSubmit = (event) => {
    event.preventDefault()
  }

  currencyChanged(event) {
    this.updateURL()
  }
}