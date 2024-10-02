import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "auto" ]
  static values = { submitOnConnect: Boolean, triggerEvent: { type: String, default: "input" } }

  connect() {
    this.autoTargets.forEach((element) => {
      const event = element.dataset.autosubmitTriggerEvent || this.triggerEventValue
      element.addEventListener(event, this.handleInput)
    })

    if (this.submitOnConnectValue) {
      this.submit()
    }
  }

  disconnect() {
    this.autoTargets.forEach((element) => {
      const event = element.dataset.autosubmitTriggerEvent || this.triggerEventValue
      element.removeEventListener(event, this.handleInput)
    })
  }

  submit() {
    this.element.requestSubmit()
  }

  handleInput = () => {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      this.submit()
    }, 500)
  }
}
