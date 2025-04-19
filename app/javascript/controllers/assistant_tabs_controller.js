import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  select(event) {
    this.element.querySelectorAll("a").forEach(tab => {
      tab.classList.remove( "font-medium", "bg-gray-50", "rounded-full")
      tab.classList.add("text-gray-500")
    })

    event.currentTarget.classList.remove("text-gray-500")
    event.currentTarget.classList.add("font-medium", "bg-gray-50", "rounded-full")
  }
}
