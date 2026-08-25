import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preview", "frame", "loader", "label", "menuItem"]
  static values = {
    mode: { type: String, default: "edit" },
    previewUrl: String,
    editLabel: String,
    previewLabel: String
  }

  connect() {
    this.boundFinishLoading = this.finishLoading.bind(this)
    this.applyMode()
  }

  disconnect() {
    this.removeFrameListener()
  }

  setMode(event) {
    const mode = event.params.mode
    if (mode === "preview" && !this.previewUrlValue) return

    this.modeValue = mode
  }

  modeValueChanged() {
    this.applyMode()
  }

  applyMode() {
    if (this.modeValue === "preview" && !this.previewUrlValue) {
      this.modeValue = "edit"
      return
    }

    const isPreview = this.modeValue === "preview"

    this.element.classList.toggle("brawo-admin--preview", isPreview)

    if (this.hasPreviewTarget) {
      this.previewTarget.setAttribute("aria-hidden", isPreview ? "false" : "true")
    }

    if (isPreview) {
      this.startPreview()
    } else {
      this.stopPreview()
    }

    if (this.hasLabelTarget) {
      this.labelTarget.textContent = isPreview ? this.previewLabelValue : this.editLabelValue
    }

    this.menuItemTargets.forEach((item) => {
      item.classList.toggle("active", item.dataset.adminModeModeParam === this.modeValue)
    })
  }

  startPreview() {
    if (!this.hasFrameTarget) return

    this.element.classList.add("brawo-admin--preview-loading")
    this.setLoaderVisible(true)
    this.removeFrameListener()
    this.frameTarget.addEventListener("load", this.boundFinishLoading)
    this.frameTarget.addEventListener("error", this.boundFinishLoading)
    this.frameTarget.src = this.previewUrlValue
  }

  stopPreview() {
    this.element.classList.remove("brawo-admin--preview-loading")
    this.setLoaderVisible(false)
    this.removeFrameListener()

    if (this.hasFrameTarget) {
      this.frameTarget.src = "about:blank"
    }
  }

  finishLoading() {
    this.element.classList.remove("brawo-admin--preview-loading")
    this.setLoaderVisible(false)
    this.removeFrameListener()
  }

  setLoaderVisible(visible) {
    if (!this.hasLoaderTarget) return

    this.loaderTarget.setAttribute("aria-hidden", visible ? "false" : "true")
  }

  removeFrameListener() {
    if (!this.hasFrameTarget) return

    this.frameTarget.removeEventListener("load", this.boundFinishLoading)
    this.frameTarget.removeEventListener("error", this.boundFinishLoading)
  }
}
