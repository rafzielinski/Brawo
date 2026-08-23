import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    formSelector: { type: String, default: "[data-slug-conflict-form]" },
    fieldSelector: { type: String, default: '[name="content[slug]"]' },
    acceptFieldId: { type: String, default: "accept_adjusted_slug" }
  }

  accept(event) {
    event.preventDefault()

    const acceptField = document.getElementById(this.acceptFieldIdValue)
    if (acceptField) acceptField.value = "1"

    this.formElement()?.requestSubmit()
  }

  goBack(event) {
    event.preventDefault()

    const field = document.querySelector(this.fieldSelectorValue)
    field?.focus()
    field?.select()
  }

  formElement() {
    return document.querySelector(this.formSelectorValue)
  }
}
