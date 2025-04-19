import { Controller } from "@hotwired/stimulus"
import Masonry from "masonry-layout"

export default class extends Controller {
  connect() {

    console.log("Masonry controller connected")
    this.initializeMasonry()
  }

  initializeMasonry() {
    if (!CSS.supports("grid-template-rows", "masonry")) {
      this.masonry = new Masonry(this.element, {
        itemSelector: '.masonry-item',
        columnWidth: '.masonry-sizer',
        percentPosition: true,
        gutter: 24,
        initLayout: true,
        // horizontalOrder: true,
        transitionDuration: '0.2s'
      })
    }
  }

  disconnect() {
    if (this.masonry) {
      this.masonry.destroy()
    }
  }
}
