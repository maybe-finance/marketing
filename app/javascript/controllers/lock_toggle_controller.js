// app/javascript/controllers/lock_toggle_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["icon", "slider", "lockedIcon", "unlockedIcon"];

  connect() {
    this.locked = false;
  }

  toggleIcon() {
    if (this.lockedIconTarget.classList.contains("hidden")) {
      this.lockedIconTarget.classList.remove("hidden");
      this.unlockedIconTarget.classList.add("hidden");

      this.lockedIconTarget.classList.add("text-gray-400");
      this.lockedIconTarget.classList.remove("text-gray-100");
    } else {
      this.lockedIconTarget.classList.add("hidden");
      this.unlockedIconTarget.classList.remove("hidden");

      this.lockedIconTarget.classList.add("text-gray-100");
      this.lockedIconTarget.classList.remove("text-gray-400");

    }
  }

  toggle() {
    this.locked = !this.locked;
    this.toggleIcon();
    this.toggleSlider();
  }

  toggleSlider() {
    this.sliderTarget.disabled = this.locked;
  }
}
