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

export default class extends Controller {
  static values = {
    options: Object
  }

  connect() {
    this.anElement = new AutoNumeric(this.element, this.optionsValue)
  }
}
