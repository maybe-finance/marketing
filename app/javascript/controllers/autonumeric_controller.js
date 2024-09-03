/**
 * AutonumericController
 * 
 * This Stimulus controller integrates the AutoNumeric library to provide automatic
 * number formatting for input fields. It's useful for formatting currency, percentages,
 * or any numeric input that requires specific formatting.
 * 
 * @see https://github.com/autoNumeric/autoNumeric for more information on AutoNumeric
 */
import { Controller } from "@hotwired/stimulus"
import AutoNumeric from "autonumeric"

// Connects to data-controller="autonumeric"
export default class extends Controller {
  static values = {
    options: Object
  }

  /**
   * Initializes the AutoNumeric instance when the controller connects to the DOM.
   * 
   * @return {void}
   */
  connect() {
    this.anElement = new AutoNumeric(this.element, this.optionsValue)
  }
}
