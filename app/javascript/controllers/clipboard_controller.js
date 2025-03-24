import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = { content: String }

  copy() {
    navigator.clipboard.writeText(this.contentValue)
      .then(() => {
        // Update button text temporarily
        const originalText = this.buttonTarget.textContent
        this.buttonTarget.textContent = "Copied!"

        // Reset button text after 2 seconds
        setTimeout(() => {
          this.buttonTarget.textContent = originalText
        }, 2000)
      })
      .catch(err => {
        console.error('Failed to copy text: ', err)
      })
  }
}
