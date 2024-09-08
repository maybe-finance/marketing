import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "btn", "tab" ]
  static values = { defaultTab: String }

  connect() {
    const selectedBtn = this.btnTargets.find(element => element.id === this.defaultTabValue)
    const selectedTab = this.tabTargets.find(element => element.id === this.defaultTabValue)

    this.tabTargets.map(x => x.hidden = true)
    selectedTab.hidden = false
    selectedBtn.classList.add("tab-item-active")
  }

  select(event) {
    const selectedTab = this.tabTargets.find(element => element.id === event.currentTarget.id)

    this.tabTargets.map(x => x.hidden = true)
    this.btnTargets.map(x => x.classList.remove("tab-item-active"))

    selectedTab.hidden = !selectedTab.hidden
    event.currentTarget.classList.add("tab-item-active")
  }
}
