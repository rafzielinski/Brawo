import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = {
    checked: { type: Boolean, default: false },
    useState: { type: Boolean, default: false },
    state: { type: String, default: "" },
    offState: { type: String, default: "off" },
    onState: { type: String, default: "on" },
    disabled: { type: Boolean, default: false },
    disabledOn: { type: Boolean, default: false }
  }

  connect() {
    if (this.hasInputTarget) {
      this.checkedValue = this.inputTarget.checked
    }

    this.syncVisualState()
  }

  checkedValueChanged() {
    this.syncVisualState()
  }

  stateValueChanged() {
    this.syncVisualState()
  }

  toggle(event) {
    event?.preventDefault()
    if (this.disabledValue) return

    if (this.useStateValue) {
      if (this.isOn()) {
        this.setOff()
      } else if (!this.disabledOnValue) {
        this.setOn()
      }
      return
    }

    if (this.hasInputTarget) {
      this.inputTarget.checked = !this.inputTarget.checked
      this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
      this.checkedValue = this.inputTarget.checked
    } else {
      this.checkedValue = !this.checkedValue
    }

    this.dispatchChange()
  }

  selectOff(event) {
    event?.preventDefault()
    if (this.disabledValue) return

    this.setOff()
  }

  selectOn(event) {
    event?.preventDefault()
    if (this.disabledValue || this.disabledOnValue) return

    this.setOn()
  }

  setOff() {
    if (this.useStateValue) {
      if (this.stateValue === this.offStateValue) return

      this.stateValue = this.offStateValue
      this.dispatchChange()
      return
    }

    if (this.hasInputTarget) {
      if (!this.inputTarget.checked) return

      this.inputTarget.checked = false
      this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
      this.checkedValue = false
    } else if (this.checkedValue) {
      this.checkedValue = false
    } else {
      return
    }

    this.dispatchChange()
  }

  setOn() {
    if (this.useStateValue) {
      if (this.stateValue === this.onStateValue) return

      this.stateValue = this.onStateValue
      this.dispatchChange()
      return
    }

    if (this.hasInputTarget) {
      if (this.inputTarget.checked) return

      this.inputTarget.checked = true
      this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
      this.checkedValue = true
    } else if (!this.checkedValue) {
      this.checkedValue = true
    } else {
      return
    }

    this.dispatchChange()
  }

  syncFromInput() {
    if (!this.hasInputTarget) return

    this.checkedValue = this.inputTarget.checked
    this.dispatchChange()
  }

  isOn() {
    return this.useStateValue ? this.stateValue === this.onStateValue : this.checkedValue
  }

  syncVisualState() {
    const isOn = this.isOn()

    this.element.classList.toggle("is-on", isOn)
    this.element.classList.toggle("is-off", !isOn)

    this.element.querySelectorAll("[data-toggle-role='switch']").forEach((control) => {
      control.setAttribute("aria-checked", isOn ? "true" : "false")
    })
  }

  dispatchChange() {
    this.dispatch("change", {
      detail: {
        checked: this.checkedValue,
        state: this.useStateValue ? this.stateValue : (this.isOn() ? this.onStateValue : this.offStateValue)
      }
    })
  }
}
