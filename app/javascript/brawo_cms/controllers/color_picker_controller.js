import { Controller } from "@hotwired/stimulus"
import loadColoris from "brawo_cms/coloris"

let colorisInitialized = false

export default class extends Controller {
  static targets = ["input", "preview", "pickerInput"]
  static values = {
    swatches: Array,
    alpha: { type: Boolean, default: true },
    defaultColor: { type: String, default: "#000000" }
  }

  async connect() {
    const Coloris = await loadColoris()

    if (!colorisInitialized) {
      Coloris({
        themeMode: "light",
        theme: "default",
        wrap: false,
        format: "hex",
        margin: 8,
        alpha: true,
        clearButton: false,
        closeButton: false
      })
      colorisInitialized = true
    }

    const instanceOptions = {
      alpha: this.alphaValue,
      clearButton: false
    }

    if (this.swatchesValue.length > 0) {
      instanceOptions.swatches = this.swatchesValue
    }

    Coloris.setInstance(`#${this.pickerInputTarget.id}`, instanceOptions)
    this.pickerInputTarget.setAttribute("data-coloris", "")

    this.boundSyncFromPicker = this.syncFromPicker.bind(this)
    this.boundSyncFromInput = this.syncFromInput.bind(this)
    this.pickerInputTarget.addEventListener("input", this.boundSyncFromPicker)
    this.pickerInputTarget.addEventListener("change", this.boundSyncFromPicker)
    this.inputTarget.addEventListener("input", this.boundSyncFromInput)
    this.inputTarget.addEventListener("change", this.boundSyncFromInput)

    this.syncFromInput()
  }

  disconnect() {
    this.pickerInputTarget?.removeEventListener("input", this.boundSyncFromPicker)
    this.pickerInputTarget?.removeEventListener("change", this.boundSyncFromPicker)
    this.inputTarget?.removeEventListener("input", this.boundSyncFromInput)
    this.inputTarget?.removeEventListener("change", this.boundSyncFromInput)

    if (window.Coloris) {
      window.Coloris.close(true)
    }
  }

  openPicker(event) {
    event.preventDefault()

    if (window.Coloris) {
      window.Coloris({ parent: this.element })
    }

    this.pickerInputTarget.click()
  }

  syncFromPicker() {
    this.inputTarget.value = this.pickerInputTarget.value
    this.syncPreview()
  }

  syncFromInput() {
    const color = this.inputTarget.value.trim()
    this.pickerInputTarget.value = color
    this.syncPreview()
  }

  syncPreview() {
    if (!this.hasPreviewTarget) return

    const color = this.inputTarget.value.trim()
    this.previewTarget.style.backgroundColor = color || "transparent"
  }
}
