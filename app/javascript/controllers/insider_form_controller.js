import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
  }

  submit(event) {
    const symbol = event.target.value.split(' ')[0]

    if (symbol) {
      const url = `/tools/inside-trading-tracker/${symbol.toUpperCase()}`
      Turbo.visit(url)
    }
  }
}