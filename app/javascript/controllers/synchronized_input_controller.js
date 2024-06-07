import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="synchronized-input"
export default class extends Controller {
  static targets = [ "input" ]

  syncValue(event) {
    this.inputTargets.forEach(input => {
      if (input === event.target) return

      const value = this.eventTargetValue(event)
      this.setElementValue(input, value)

      const changeEvent = new Event("input-sync")
      input.dispatchEvent(changeEvent)
    })
  }

  setElementValue(element, value) {
    const autonumericController = this.application.getControllerForElementAndIdentifier(element, 'autonumeric')
    if (autonumericController) {
      autonumericController.anElement.set(value)
    } else {
      element.value = value
    }
  }

  eventTargetValue(event) {
    const autonumericController = this.application.getControllerForElementAndIdentifier(event.target, 'autonumeric')
    if (autonumericController) {
      return autonumericController.anElement.getNumber()
    } else {
      return event.target.value
    }
  }
}
