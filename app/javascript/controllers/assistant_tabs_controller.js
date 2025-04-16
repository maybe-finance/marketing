import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  select(event) {
    this.element.querySelectorAll("a").forEach(tab => {
      tab.classList.remove("border-blue-500", "font-medium")
      tab.classList.add("text-gray-500", "border-transparent")
    })

    event.currentTarget.classList.remove("text-gray-500", "border-transparent")
    event.currentTarget.classList.add("font-medium")
  }
}
