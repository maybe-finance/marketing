import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["text"];

  connect() {
    this.updateColor();
  }

  updateColor() {
    const text = this.textTarget.textContent.trim().toUpperCase();

    switch (text) {
      case "HIGH":
        this.textTarget.style.color = "#F23E94";
        break;
      case "MEDIUM":
      case "MODERATE":
        // colors from reference implementation
        this.textTarget.style.color = "#FDB022";
        break;
      case "LOW":
        this.textTarget.style.color = "#12B76A";
        break;
      default:
        this.textTarget.style.color = "#737373";
    }
  }
}
