import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]
  static values = {
    open: { type: Boolean, default: false },
    backdrop: { type: String, default: "true" },
    keyboard: { type: Boolean, default: true }
  }

  connect() {
    if (!window.bootstrap) return

    this.modal = new bootstrap.Modal(this.dialogTarget, {
      backdrop: this.backdropValue === "static" ? "static" : true,
      keyboard: this.keyboardValue
    })

    if (this.openValue) this.show()
  }

  disconnect() {
    this.modal?.dispose()
  }

  show() {
    this.modal?.show()
  }

  close() {
    this.modal?.hide()
  }
}
