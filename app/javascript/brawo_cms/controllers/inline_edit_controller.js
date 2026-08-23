import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "input"]
  static values = { open: { type: Boolean, default: false } }

  connect() {
    if (this.openValue) this.showInput()
  }

  edit(event) {
    event.preventDefault()

    const field = this.fieldElement()
    if (field) {
      this.originalValue = this.displayValue()
      field.value = this.originalValue
    }

    this.showInput()
  }

  cancel(event) {
    event.preventDefault()

    const field = this.fieldElement()
    if (field && this.originalValue !== undefined) field.value = this.originalValue

    this.hideInput()
  }

  showInput() {
    this.displayTarget.classList.add("d-none")
    this.inputTarget.classList.remove("d-none")

    const field = this.fieldElement()
    if (field) field.focus()
  }

  hideInput() {
    this.inputTarget.classList.add("d-none")
    this.displayTarget.classList.remove("d-none")
  }

  fieldElement() {
    return this.inputTarget.querySelector("input, textarea")
  }

  displayValue() {
    const title = this.displayTarget.querySelector(".content-meta__title")
    if (title) return title.textContent.trim()

    const link = this.displayTarget.querySelector(".content-meta__permalink")
    if (link) return link.textContent.trim()

    const field = this.fieldElement()
    return field ? field.value : ""
  }
}
