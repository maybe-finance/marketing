import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
export default class extends Controller {
  static targets = ["btn", "tab"]
  static values = { defaultTab: String }

  connect() {
    this.tabTargets.map(x => x.hidden = true)
    try {
      let selectedBtn = this.btnTargets.find(element => element.id === this.defaultTabValue)
      let selectedTab = this.tabTargets.find(element => element.id === this.defaultTabValue)
      selectedTab.hidden = false
      selectedBtn.classList.add("tab-item-active")
    } catch { }
  }

  select(event) {
    let selectedTab = this.tabTargets.find(element => element.id === event.currentTarget.id)
    if (selectedTab.hidden) {
      this.tabTargets.map(x => x.hidden = true) 
      this.btnTargets.map(x => x.classList.remove("tab-item-active")) 
      selectedTab.hidden = false 
      event.currentTarget.classList.add("tab-item-active") 
    } else {
      this.tabTargets.map(x => x.hidden = true)
      this.btnTargets.map(x => x.classList.remove("tab-item-active"))
      selectedTab.hidden = true
      event.currentTarget.classList.remove("tab-item-active")
    }
  }
}