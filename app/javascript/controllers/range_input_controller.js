import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="range-input"
export default class extends Controller {
  connect() {
    this.update();
  }

  update() {
    this.element.style.setProperty("--range-before-width", this.percentage + "%");
  }

  get percentage() {
    return (this.element.value - this.element.min) / (this.element.max - this.element.min) * 100;
  }
}
