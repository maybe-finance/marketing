import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["low", "high", "current", "currentPriceTick", "timeframeSelect"]
  static values = { symbol: String }

  connect() {
    if (this.hasTimeframeSelectTarget) {
      this.updatePricePerformance(this.timeframeSelectTarget.value)
    }
  }

  updateTimeframe(event) {
    this.updatePricePerformance(event.target.value)
  }

  updatePricePerformance(timeframe) {
    this.element.classList.add('opacity-50')
    fetch(`/stocks/${this.symbolValue}/price_performance?timeframe=${timeframe}`, {
      headers: { "Accept": "application/json" }
    })
      .then(response => response.json())
      .then(data => {
        this.lowTarget.textContent = `$${Number(data.low).toFixed(2)}`
        this.highTarget.textContent = `$${Number(data.high).toFixed(2)}`
        
        const range = data.high - data.low
        const position = (data.current - data.low) / range
        
        this.currentPriceTickTarget.style.left = `${position * 100}%`


        this.element.classList.remove('opacity-50')
      })
      .catch(error => {
        console.error('Error:', error)
        this.element.classList.remove('opacity-50')
      })
  }
}