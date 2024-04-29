import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // Hello
    this.element.textContent = "Hello World!";
  }
}
