import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "modal", "search", "grid"]
  static values = {
    icons: { type: Array, default: [] },
    iconsUrl: String,
    variant: { type: String, default: "outline" },
    noneLabel: { type: String, default: "None" }
  }

  connect() {
    this.allIcons = null
    this.mountModalOnBody()
    this.boundHandleGridClick = this.handleGridClick.bind(this)
    this.boundFilter = this.filter.bind(this)
    this.modalElement?.addEventListener("click", this.boundHandleGridClick)
    this.searchElement?.addEventListener("input", this.boundFilter)
  }

  disconnect() {
    this.modalElement?.removeEventListener("click", this.boundHandleGridClick)
    this.searchElement?.removeEventListener("input", this.boundFilter)
    this.disposeModalInstance()
    this.restoreModalFromBody()
  }

  async openModal(event) {
    event.preventDefault()

    if (!this.allIcons) {
      await this.loadIcons()
    }

    this.searchElement.value = ""
    this.renderGrid(this.allIcons)
    this.getModalInstance().show()
  }

  filter() {
    if (!this.allIcons) return

    const query = this.searchElement.value.trim().toLowerCase()
    const filtered = query
      ? this.allIcons.filter((name) => name.toLowerCase().includes(query))
      : this.allIcons

    this.renderGrid(filtered)
  }

  select(event) {
    event.preventDefault()
    const name = event.currentTarget.dataset.iconName
    if (!name) return

    this.inputTarget.value = name
    this.updatePreview(name)
    this.getModalInstance().hide()
  }

  handleGridClick(event) {
    const button = event.target.closest("[data-icon-name]")
    if (!button || !this.gridElement?.contains(button)) return

    this.select({ preventDefault: () => {}, currentTarget: button })
  }

  async loadIcons() {
    if (this.iconsValue.length > 0) {
      this.allIcons = this.iconsValue
      return
    }

    if (!this.hasIconsUrlValue) {
      this.allIcons = []
      return
    }

    const response = await fetch(this.iconsUrlValue)
    this.allIcons = await response.json()
  }

  renderGrid(icons) {
    const selected = this.inputTarget.value
    const buttons = icons.map((name) => {
      const selectedClass = name === selected ? " is-selected" : ""
      return `<button type="button" class="brawo-icon-picker__item${selectedClass}" data-icon-name="${this.escapeHtml(name)}" title="${this.escapeHtml(name)}"><i class="bi bi-${this.escapeHtml(name)}" aria-hidden="true"></i></button>`
    })

    this.gridElement.innerHTML = buttons.join("")
  }

  updatePreview(name) {
    if (!this.hasPreviewTarget) return

    if (!name) {
      this.previewTarget.innerHTML = `<span class="brawo-icon-picker__placeholder">${this.escapeHtml(this.noneLabelValue)}</span>`
      return
    }

    const iconClass = this.iconClass(name)
    this.previewTarget.innerHTML = `<i class="bi ${iconClass} brawo-icon" aria-hidden="true"></i>`
  }

  iconClass(name) {
    const base = String(name).replaceAll("_", "-")
    if (this.variantValue === "fill" && !base.endsWith("-fill")) {
      return `bi-${base}-fill`
    }

    return `bi-${base}`
  }

  escapeHtml(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }

  mountModalOnBody() {
    if (!this.hasModalTarget) return

    this.modalElement = this.modalTarget
    this.searchElement = this.searchTarget
    this.gridElement = this.gridTarget
    this.modalPlaceholder = document.createComment("icon-picker-modal-anchor")
    this.modalElement.parentNode.insertBefore(this.modalPlaceholder, this.modalElement)
    document.body.appendChild(this.modalElement)
  }

  restoreModalFromBody() {
    if (!this.modalPlaceholder?.parentNode || !this.modalElement) return

    this.modalPlaceholder.parentNode.insertBefore(this.modalElement, this.modalPlaceholder)
    this.modalPlaceholder.remove()
    this.modalPlaceholder = null
  }

  getModalInstance() {
    return window.bootstrap.Modal.getOrCreateInstance(this.modalElement)
  }

  disposeModalInstance() {
    const instance = window.bootstrap.Modal.getInstance(this.modalElement)
    if (instance) instance.dispose()
  }
}
