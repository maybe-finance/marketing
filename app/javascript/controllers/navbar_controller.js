import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['mobileMenu'];
  static classes = ['hidden'];

  toggleMobileMenu() {
    this.mobileMenuTarget.classList.toggle(this.hiddenClass);
  }
}
