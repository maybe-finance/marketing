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
    const searchParams = new URLSearchParams(window.location.search)
    const amount = searchParams.get('amount') || '1'
    const baseUrl = `/tools/exchange-rate-calculator/${fromCurrency}/${toCurrency}/${amount}`

    if (currentPath !== baseUrl) {
      history.pushState({}, "", baseUrl)

      // Prevent form submission entirely when URL changes
      this.element.addEventListener('submit', this.preventSubmit, { once: true })

      // Trigger a Turbo visit instead
      Turbo.visit(baseUrl, { action: 'replace' })
    }
  }

  preventSubmit = (event) => {
    event.preventDefault()
  }

  currencyChanged(event) {
    this.updateURL()
  }
}