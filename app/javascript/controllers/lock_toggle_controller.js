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
    } else {
      this.lockedIconTarget.classList.add("hidden");
      this.unlockedIconTarget.classList.remove("hidden");
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
