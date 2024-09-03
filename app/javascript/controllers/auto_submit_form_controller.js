/**
 * AutoSubmitFormController
 * 
 * This Stimulus controller handles automatic form submission based on user input.
 * It allows for configurable trigger events and debounces the submission to prevent
 * excessive requests.
 * 
 * @example
 * <form data-controller="auto-submit-form">
 *   <input data-auto-submit-form-target="auto" type="text" name="search">
 * </form>
 */
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // By default, auto-submit is "opt-in" to avoid unexpected behavior.  Each `auto` target
  // will trigger a form submission when the configured event is triggered.
  static targets = ["auto"];
  static values = {
    triggerEvent: { type: String, default: "input" },
  };

  /**
   * Connects the controller and sets up event listeners for auto-submit targets.
   */
  connect() {
    this.autoTargets.forEach((element) => {
      const event =
        element.dataset.autosubmitTriggerEvent || this.triggerEventValue;
      element.addEventListener(event, this.handleInput);
    });
  }

  /**
   * Disconnects the controller and removes event listeners.
   */
  disconnect() {
    this.autoTargets.forEach((element) => {
      const event =
        element.dataset.autosubmitTriggerEvent || this.triggerEventValue;
      element.removeEventListener(event, this.handleInput);
    });
  }

  /**
   * Handles input events and debounces form submission.
   * @param {Event} event - The input event that triggered the handler.
   */
  handleInput = () => {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
    }, 500);
  };
}
