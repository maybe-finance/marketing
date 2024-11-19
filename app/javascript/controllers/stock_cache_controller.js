import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]
  static values = {
    key: String,
    url: String
  }

  connect() {
    this.observeFrameLoads()
  }

  observeFrameLoads() {
    const frames = this.element.querySelectorAll("turbo-frame")
    let loadedFrames = 0

    frames.forEach(frame => {
      frame.addEventListener("turbo:frame-load", () => {
        loadedFrames++
        if (loadedFrames === frames.length) {
          this.cacheFullPage()
        }
      })
    })
  }

  async cacheFullPage() {
    const content = this.contentTarget.innerHTML
    await fetch(this.urlValue, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ content, key: this.keyValue })
    })
  }
}