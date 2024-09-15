import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "durationInput", "interestRateInput" ]
  static values = { rate30: Number, rate15: Number }

  connect() {
    this.sync()
  }

  sync() {
    if (this.#selectedDuration == "30") {
      this.interestRateInputTarget.value = this.rate30Value
    } else {
      this.interestRateInputTarget.value = this.rate15Value
    }
  }

  get #selectedDuration() {
    return this.durationInputTarget.value
  }
}
