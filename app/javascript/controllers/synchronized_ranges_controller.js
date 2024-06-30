import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="synchronized-ranges"
export default class extends Controller {
  static targets = ["slider"];
  static locked = false;

  connect() {
    this.updateSliders();
  }

  updateSliders() {
    const total = this.calculateTotal();
    if (total !== 100) {
      const diff = 100 - total;
      this.adjustSlider(this.sliderTargets[0], diff);
    }
  }

  syncSliders(event) {
    if (this.locked) return;

    this.locked = true;
    const total = this.calculateTotal();
    const adjustment = 100 - total;
    
    if (adjustment !== 0) {
      this.adjustSliders(event.target, adjustment);
    }

    this.locked = false;
  }

  adjustSlider(slider, share) {
    slider.value = Math.max(0, Math.min(100, parseInt(slider.value) + share));
    this.dispatchInputEvent(slider);
  }

  adjustSliders(excludeSlider, adjustment) {
    const otherSliders = this.sliderTargets.filter(slider => slider !== excludeSlider && !slider.disabled);

    if (Math.abs(adjustment) === 1) {
      this.adjustSlider(otherSliders[0], adjustment);
    } else {
      const share = adjustment / otherSliders.length;
      otherSliders.forEach(slider => this.adjustSlider(slider, share));
    }

    this.updateSliders();
  }

  calculateTotal() {
    return this.sliderTargets.reduce((sum, slider) => sum + parseInt(slider.value), 0);
  }

  dispatchInputEvent(slider) {
    slider.dispatchEvent(new Event("input"));
    slider.dispatchEvent(new Event("input-sync"));
  }
}
