import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["shareInput", "dollarInput"]
  static values = { symbol: String }

  connect() {
    this.stockPrice = 0
    this.fetchLatestPrice().then(() => {
      this.convertFromShares()
    })
  }

  async fetchLatestPrice() {
    try {
      const response = await fetch(`/stocks/${this.symbolValue}/chart.json`)
      if (!response.ok) throw new Error('Network response was not ok')
      const data = await response.json()
      this.stockPrice = data.latest_price
    } catch (error) {
      console.error('Error fetching stock price:', error)
    }
  }

  convertFromShares() {
    if (this.stockPrice === 0) {
      this.fetchLatestPrice().then(() => this.convertFromShares())
      return
    }
    const shares = parseFloat(this.shareInputTarget.value)
    if (isNaN(shares)) {
      this.dollarInputTarget.value = "0"
      return
    }
    const dollars = shares * this.stockPrice
    this.dollarInputTarget.value = this.formatNumber(dollars, 2)
  }

  convertFromDollars() {
    if (this.stockPrice === 0) {
      this.fetchLatestPrice().then(() => this.convertFromDollars())
      return
    }
    const dollars = parseFloat(this.dollarInputTarget.value)
    if (isNaN(dollars)) {
      this.shareInputTarget.value = "0"
      return
    }
    const shares = dollars / this.stockPrice
    this.shareInputTarget.value = this.formatNumber(shares, 2)
  }

  formatNumber(number, maxDecimals) {
    return parseFloat(number.toFixed(maxDecimals)).toString()
  }
}