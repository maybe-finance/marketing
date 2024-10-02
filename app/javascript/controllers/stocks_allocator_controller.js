import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "allocation", "totalDisplay", "warningText" ]

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
