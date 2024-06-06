import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="synchronized-input"
export default class extends Controller {
  static targets = [ "input" ]

  syncValue(event) {
    this.inputTargets.forEach(input => {
      if (input === event.target) return

      input.value = event.target.value

      const changeEvent = new Event("input-sync")
      input.dispatchEvent(changeEvent)
    })
  }
}
