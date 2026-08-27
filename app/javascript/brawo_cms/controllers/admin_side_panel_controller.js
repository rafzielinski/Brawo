import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["section", "title"]

  connect() {
    this.activeSection = null
    this.defaultTitle = this.hasTitleTarget ? this.titleTarget.textContent : ""
    this.boundEscape = this.closeOnEscape.bind(this)
    this.hideSections()
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundEscape)
  }

  open({ section = "add" } = {}) {
    this.activeSection = section
    this.showSection()
    this.element.classList.add("is-open")
    this.element.setAttribute("aria-hidden", "false")
    document.addEventListener("keydown", this.boundEscape)
  }

  close(event) {
    if (event) event.preventDefault()
    this.element.classList.remove("is-open")
    this.element.setAttribute("aria-hidden", "true")
    document.removeEventListener("keydown", this.boundEscape)
    this.hideSections()
  }

  closeOnEscape(event) {
    if (event.key === "Escape") this.close()
  }

  showSection() {
    this.sectionTargets.forEach((target) => {
      target.hidden = target.dataset.section !== this.activeSection
    })

    const active = this.sectionTargets.find((target) => target.dataset.section === this.activeSection)
    if (this.hasTitleTarget) {
      this.titleTarget.textContent = active?.dataset.title || this.defaultTitle
    }
  }

  hideSections() {
    this.sectionTargets.forEach((target) => {
      target.hidden = true
    })
  }
}
