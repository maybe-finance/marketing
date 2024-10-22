import { Controller } from "@hotwired/stimulus"
import Fuse from 'fuse.js'

export default class extends Controller {
  static targets = [ "allocation", "totalDisplay", "warningText" ]
  static values = { stocks: Array }

  connect() {
    this.isFuseInitialized = false;
    window.prioritizeTickerFilter = this.prioritizeTickerFilter.bind(this)
  }

  initializeFuse(dataList) {
    if (!this.isFuseInitialized) {
      this.fuseInstance = new Fuse(dataList, {
        keys: ['value', 'name'],
        threshold: 0.3,
        includeScore: true
      })
      this.isFuseInitialized = true;
    }
  }

  submitForm(event) {
    if (this.#totalAllocation < 100) {
      this.warningTextTarget.textContent = "The total allocation is below 100%. Please review and adjust your allocations."
      this.warningTextTarget.classList.remove("hidden")
      event.preventDefault()
    } else if (this.#totalAllocation > 100) {
      this.warningTextTarget.textContent = "The total allocation exceeds 100%. Please review and adjust your allocations."
      this.warningTextTarget.classList.remove("hidden")
      event.preventDefault()
    } else {
      this.warningTextTarget.textContent = ""
      this.warningTextTarget.classList.add("hidden")
    }
  }

  updateAllocation() {
    this.totalDisplayTarget.textContent = `${this.#totalAllocation}%`
    this.totalDisplayTarget.classList.toggle("text-red-500", this.#totalAllocation > 100)
  }

  distributeEvenly() {
    this.allocationTargets.filter(visible).forEach((element, index) => {
      const isLastAllocation = index === this.#visibleAllocatorCount - 1
      const evenAllocation = Math.floor(100 / this.#visibleAllocatorCount)

      if (isLastAllocation) {
        element.querySelector("input[type='number']").value = 100 - evenAllocation * (this.#visibleAllocatorCount - 1)
      } else {
        element.querySelector("input[type='number']").value = evenAllocation
      }
    })

    this.updateAllocation()
  }

  addStockSelector() {
    const nextAllocator = this.allocationTargets.find(input => input.classList.contains("hidden"))

    if (nextAllocator) {
      nextAllocator.classList.remove("hidden")

      nextAllocator.querySelector("input[type='number']").setAttribute("required", "")
      nextAllocator.querySelector("input[type='number']").disabled = false

      nextAllocator.querySelector("input[type='text']").setAttribute("required", "")
      nextAllocator.querySelector("input[type='text']").disabled = false
      nextAllocator.querySelector("input[type='hidden']").disabled = false
    }

    this.updateAllocation()
  }

  removeStockSelector() {
    if (this.#visibleAllocatorCount > 1) {
      const lastAllocator = this.allocationTargets[this.#visibleAllocatorCount - 1]

      lastAllocator.classList.add("hidden")

      lastAllocator.querySelector("input[type='number']").removeAttribute("required")
      lastAllocator.querySelector("input[type='number']").value = ""
      lastAllocator.querySelector("input[type='number']").disabled = true

      lastAllocator.querySelector("input[type='text']").removeAttribute("required")
      lastAllocator.querySelector("input[type='text']").value = ""
      lastAllocator.querySelector("input[type='text']").disabled = true
      lastAllocator.querySelector("input[type='hidden']").disabled = true
    }

    this.updateAllocation()
  }

  prioritizeTickerFilter(dataList, filterValue) {
    if (!this.isFuseInitialized) {
      this.initializeFuse(dataList)
    }
    const results = this.fuseInstance.search(filterValue);
    
    return results
      .map(result => result.item)
      .sort((a, b) => {
        const aStartsWithFilter = a.value.toLowerCase().startsWith(filterValue.toLowerCase());
        const bStartsWithFilter = b.value.toLowerCase().startsWith(filterValue.toLowerCase());
        if (aStartsWithFilter && !bStartsWithFilter) return -1;
        if (!aStartsWithFilter && bStartsWithFilter) return 1;
        return 0;
      });
  };

  get #totalAllocation() {
    return this.allocationTargets.reduce((acc, allocation) => {
      const value = parseFloat(allocation.querySelector("input[type='number']").value)
      return isNaN(value) ? acc : acc + value
    }, 0)
  }

  get #visibleAllocatorCount() {
    return this.allocationTargets.filter(visible).length
  }
}

function visible(element) {
  return !element.classList.contains("hidden")
}
