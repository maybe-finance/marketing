import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["allocator", "allocation"]

  connect() {
    this.updateAllocation();
  }

  updateAllocation() {
    const newPercent = parseFloat(this.allocationTarget.value) || 0;
    const oldPercent = parseFloat(this.element.dataset.allocationPercent) || 0;
    
    const backtestController = this.getControllerByIdentifier("stock-portfolio-backtest");
    if (backtestController) {
      const currentTotal = parseFloat(backtestController.totalAllocation) || 0;
      const newTotal = currentTotal + (newPercent - oldPercent);

      this.element.dataset.allocationPercent = newPercent;
      const action = newPercent > oldPercent ? 'increment' : 'decrement';
      backtestController.updateTotalAllocation(Math.abs(newPercent - oldPercent), action);
      
      if (newTotal > 100) {
        alert("Total allocation cannot exceed 100%");
      }
    }
  }

  addStockSelector(event) {
    const currentAllocator = event.target.closest("[data-controller='stocks-allocator']");
    const currentIndex = parseInt(currentAllocator.dataset.index, 10);
    const nextAllocator = document.querySelector(`[data-controller='stocks-allocator'][data-index='${currentIndex + 1}']`);
    if (nextAllocator && this.countVisibleAllocators() < 10) {
      nextAllocator.classList.remove("hidden");
    }
  }

  removeStockSelector(event) {
    const currentAllocator = event.target.closest("[data-controller='stocks-allocator']");
    if (this.countVisibleAllocators() > 1) {
      currentAllocator.classList.add("hidden");

      const searchSelectController = this.getControllerByIdentifier("search-select", currentAllocator);
      if (searchSelectController) {
        searchSelectController.resetInput();
      }
    }
  }

  countVisibleAllocators() {
    return document.querySelectorAll("[data-controller='stocks-allocator']:not(.hidden)").length;
  }

  getControllerByIdentifier(identifier, element = document) {
    return this.application.getControllerForElementAndIdentifier(
      element.querySelector(`[data-controller='${identifier}']`),
      identifier
    );
  }
}