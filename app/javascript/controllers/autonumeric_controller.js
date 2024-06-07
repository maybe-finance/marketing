import { Controller } from "@hotwired/stimulus"
import AutoNumeric from "autonumeric"

// Connects to data-controller="autonumeric"
export default class extends Controller {
  connect() {
    this.anElement = new AutoNumeric(this.element)
  }
}
