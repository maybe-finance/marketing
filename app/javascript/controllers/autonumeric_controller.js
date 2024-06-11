import { Controller } from "@hotwired/stimulus"
import AutoNumeric from "autonumeric"

// Connects to data-controller="autonumeric"
export default class extends Controller {
  static values = {
    options: Object
  }

  connect() {
    this.anElement = new AutoNumeric(this.element, this.optionsValue)
  }
}
