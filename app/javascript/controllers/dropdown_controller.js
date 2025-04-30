import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
    this.iconTarget.classList.toggle("rotate-180")
  }
}
