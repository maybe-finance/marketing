import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tableBody", "loading"]

  connect() {
    this.sortDirection = {}
  }

  sort(event) {
    const column = event.currentTarget.dataset.column
    this.sortDirection[column] = !this.sortDirection[column]

    const rows = Array.from(this.tableBodyTarget.children)
    const sortedRows = this.sortRows(rows, column)

    this.showLoading()

    setTimeout(() => {
      this.tableBodyTarget.innerHTML = ''
      for (const row of sortedRows) {
        this.tableBodyTarget.appendChild(row)
      }
      this.hideLoading()
    }, 200)
  }

  sortRows(rows, column) {
    return rows.sort((a, b) => {
      let aVal = this.getCellValue(a, column)
      let bVal = this.getCellValue(b, column)

      if (column === 'date') {
        aVal = new Date(aVal)
        bVal = new Date(bVal)
      } else if (column === 'shares' || column === 'value') {
        aVal = this.parseNumericValue(aVal)
        bVal = this.parseNumericValue(bVal)
      }

      return this.sortDirection[column] ?
        this.compareValues(aVal, bVal) :
        this.compareValues(bVal, aVal)
    })
  }

  getCellValue(row, column) {
    const index = {
      name: 0,
      position: 1,
      date: 2,
      shares: 3,
      value: 4,
      holdings: 5,
      type: 6
    }[column]

    return row.children[index].textContent.trim()
  }

  parseNumericValue(value) {
    return Number.parseFloat(value.replace(/[^-\d.]/g, ''))
  }

  compareValues(a, b) {
    return a > b ? 1 : a < b ? -1 : 0
  }

  showLoading() {
    this.loadingTarget.classList.remove('hidden')
    this.tableBodyTarget.classList.add('opacity-50')
  }

  hideLoading() {
    this.loadingTarget.classList.add('hidden')
    this.tableBodyTarget.classList.remove('opacity-50')
  }
}