import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    event?.preventDefault()
    event?.stopPropagation()
    this.setCollapsed(!this.collapsed)
  }

  collapse(event) {
    event?.preventDefault()
    event?.stopPropagation()
    this.setCollapsed(true)
  }

  expand(event) {
    event?.preventDefault()
    event?.stopPropagation()
    this.setCollapsed(false)
  }

  toggleHeader(event) {
    if (event.target.closest(".collapsible-toggle, .repeater-drag-handle, .drag-handle, .dropdown, .dropdown-menu, .item-actions-menu")) {
      return
    }

    this.toggle(event)
  }

  setCollapsed(collapsed) {
    this.element.classList.toggle("is-collapsed", collapsed)
    this.syncAria()
  }

  syncAria() {
    const toggle = this.element.querySelector(".collapsible-toggle")
    if (toggle) toggle.setAttribute("aria-expanded", !this.collapsed)
  }

  get collapsed() {
    return this.element.classList.contains("is-collapsed")
  }
}
