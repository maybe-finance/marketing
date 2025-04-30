import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["mobileMenu", "menuIcon", "closeIcon"];

  toggleMobileMenu() {
    this.mobileMenuTarget.classList.toggle("opacity-0");
    this.mobileMenuTarget.classList.toggle("invisible");
    this.menuIconTarget.classList.toggle("hidden");
    this.closeIconTarget.classList.toggle("hidden");
    document.body.classList.toggle("overflow-hidden");
  }
}
