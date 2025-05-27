import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bank-search"
export default class extends Controller {
  static targets = [
    "input", "results", "loading", "pagination", "countryFilter",
    "prevButton", "nextButton", "pageInfo", "resultStart", "resultEnd", "resultTotal",
    "clearButton", "searchStats", "searchStatsText"
  ]
  static values = { url: String }

  connect() {
    console.log("Bank search controller connected")
    this.currentPage = 1
    this.searchTimeout = null
    this.lastQuery = ""
    this.lastCountry = ""
  }

  search() {
    // Update clear button visibility
    this.updateClearButton()

    // Clear existing timeout
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }

    // Debounce search requests
    this.searchTimeout = setTimeout(() => {
      this.performSearch()
    }, 300)
  }

  handleKeydown(event) {
    // Handle escape key to clear search
    if (event.key === 'Escape') {
      this.clearSearch()
    }
  }

  clearSearch() {
    this.inputTarget.value = ""
    this.countryFilterTarget.value = ""
    this.updateClearButton()
    this.performSearch()
    this.inputTarget.focus()
  }

  updateClearButton() {
    const hasValue = this.inputTarget.value.trim().length > 0 ||
      this.countryFilterTarget.value !== ""

    if (hasValue) {
      this.clearButtonTarget.classList.remove('hidden')
    } else {
      this.clearButtonTarget.classList.add('hidden')
    }
  }

  async performSearch() {
    const query = this.inputTarget.value.trim()
    const country = this.countryFilterTarget.value

    // Check if this is a new search (reset page) or pagination
    const isNewSearch = query !== this.lastQuery ||
      country !== this.lastCountry

    if (isNewSearch) {
      this.currentPage = 1
    }

    // Update last search values
    this.lastQuery = query
    this.lastCountry = country

    // Show loading state
    this.showLoading()

    try {
      const params = new URLSearchParams({
        query: query,
        country: country,
        page: this.currentPage,
        per_page: 20
      })

      const response = await fetch(`${this.urlValue}?${params}`)
      const data = await response.json()

      if (response.ok) {
        this.displayResults(data)
        this.updateSearchStats(data, query, country)
      } else {
        this.displayError(data.message || "Search failed")
        this.hideSearchStats()
      }
    } catch (error) {
      console.error("Search error:", error)
      this.displayError("Network error occurred")
      this.hideSearchStats()
    } finally {
      this.hideLoading()
    }
  }

  async nextPage() {
    this.currentPage++
    await this.performSearch()
  }

  async previousPage() {
    if (this.currentPage > 1) {
      this.currentPage--
      await this.performSearch()
    }
  }

  displayResults(data) {
    const { institutions, pagination } = data

    if (institutions.length === 0) {
      this.resultsTarget.innerHTML = this.emptyStateHTML()
      this.hidePagination()
      return
    }

    // Display institutions
    this.resultsTarget.innerHTML = institutions.map(institution =>
      this.institutionHTML(institution)
    ).join('')

    // Update pagination
    this.updatePagination(pagination)
  }

  displayError(message) {
    this.resultsTarget.innerHTML = `
      <div class="text-center py-8">
        <div class="text-red-500 mb-2">
          <svg class="mx-auto h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.962-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z" />
          </svg>
        </div>
        <p class="text-gray-600">${message}</p>
      </div>
    `
    this.hidePagination()
  }

  institutionHTML(institution) {


    return `
      <div class="border border-gray-200 rounded-lg p-4 mb-3 hover:shadow-md transition-shadow">
        <div class="flex items-start justify-between">
          <div class="flex items-center flex-1">
            ${institution.logo_url ?
        `<img src="${institution.logo_url}" alt="${institution.name}" class="w-8 h-8 rounded mr-3 object-contain flex-shrink-0">` :
        `<div class="w-8 h-8 rounded mr-3 bg-gray-200 flex items-center justify-center flex-shrink-0">
                   <span class="text-xs font-medium text-gray-600">${institution.name.charAt(0)}</span>
                 </div>`
      }
            <div class="flex-1 min-w-0">
              <h3 class="text-lg font-semibold text-gray-900 truncate">${institution.name}</h3>
              <div class="flex items-center gap-3 mt-1">

                ${institution.website ? `
                  <a href="${institution.website}" target="_blank" rel="noopener noreferrer" class="text-xs text-blue-600 hover:text-blue-800">
                    Visit website →
                  </a>
                ` : ''}
              </div>
            </div>
          </div>
          
          <div class="ml-4 flex-shrink-0 flex items-center gap-1">
            ${institution.country_codes.map(code =>
        `<div class="inline-flex items-center" title="${code}">
           <img src="https://hatscripts.github.io/circle-flags/flags/${code.toLowerCase()}.svg" 
                alt="${code}" 
                class="w-6 h-6 rounded-full border border-gray-200" 
                onerror="this.style.display='none'; this.nextElementSibling.style.display='inline-flex';">
           <span class="hidden inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">${code}</span>
         </div>`
      ).join('')}
          </div>
        </div>
      </div>
    `
  }

  emptyStateHTML() {
    return `
      <div class="text-center py-12 text-gray-500">
        <svg class="mx-auto h-12 w-12 text-gray-400 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 12h6m-6-4h6m2 5.291A7.962 7.962 0 0118 12a8 8 0 00-16 0 8.001 8.001 0 005.293 7.293z" />
        </svg>
        <p class="text-lg mb-2">No banks found</p>
        <p class="text-sm">Try adjusting your search terms or filters</p>
      </div>
    `
  }

  updatePagination(pagination) {
    if (pagination.total_pages <= 1) {
      this.hidePagination()
      return
    }

    this.showPagination()

    // Update pagination info
    this.pageInfoTarget.textContent = `Page ${pagination.current_page} of ${pagination.total_pages}`
    this.resultStartTarget.textContent = ((pagination.current_page - 1) * pagination.per_page) + 1
    this.resultEndTarget.textContent = Math.min(pagination.current_page * pagination.per_page, pagination.total_count)
    this.resultTotalTarget.textContent = pagination.total_count

    // Update button states
    this.prevButtonTargets.forEach(btn => {
      btn.disabled = !pagination.has_prev
    })
    this.nextButtonTargets.forEach(btn => {
      btn.disabled = !pagination.has_next
    })
  }

  showLoading() {
    this.loadingTarget.classList.remove('hidden')
    this.resultsTarget.classList.add('opacity-50')
  }

  hideLoading() {
    this.loadingTarget.classList.add('hidden')
    this.resultsTarget.classList.remove('opacity-50')
  }

  showPagination() {
    this.paginationTarget.classList.remove('hidden')
  }

  hidePagination() {
    this.paginationTarget.classList.add('hidden')
  }



  updateSearchStats(data, query, country) {
    const { pagination } = data
    const filters = []

    if (query) filters.push(`"${query}"`)
    if (country) filters.push(`in ${country}`)

    const filterText = filters.length > 0 ? ` for ${filters.join(' ')}` : ''
    const resultText = pagination.total_count === 1 ? 'result' : 'results'

    this.searchStatsTextTarget.textContent =
      `Found ${pagination.total_count} ${resultText}${filterText}`

    this.showSearchStats()
  }

  showSearchStats() {
    this.searchStatsTarget.classList.remove('hidden')
  }

  hideSearchStats() {
    this.searchStatsTarget.classList.add('hidden')
  }


} 