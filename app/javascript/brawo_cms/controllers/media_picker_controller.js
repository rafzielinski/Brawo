import { Controller } from "@hotwired/stimulus"
import {
  uploadMediaFile,
  fileMatchesAccept,
  mediaImageUrl,
  escapeHtml
} from "brawo_cms/media_upload"

export default class extends Controller {
  static targets = ["input", "preview", "modal", "search", "grid", "fileInput", "uploadStatus", "removeButton", "uploadZone"]
  static values = {
    accept: { type: String, default: "*/*" },
    mediaIndexUrl: String,
    noneLabel: { type: String, default: "None" },
    uploadingLabel: { type: String, default: "Uploading…" },
    uploadFailedLabel: { type: String, default: "Upload failed" },
    invalidTypeLabel: { type: String, default: "File type not allowed" },
    successLabel: { type: String, default: "Uploaded" }
  }

  connect() {
    this.items = []
    this.mountModalOnBody()
    this.boundHandleGridClick = this.handleGridClick.bind(this)
    this.boundFilter = this.filter.bind(this)
    this.boundUploadFiles = (event) => this.uploadFiles(event)
    this.boundDragOver = (event) => {
      event.preventDefault()
      this.uploadZoneElement?.classList.add("is-dragover")
    }
    this.boundDragLeave = () => this.uploadZoneElement?.classList.remove("is-dragover")
    this.boundDrop = (event) => {
      event.preventDefault()
      this.uploadZoneElement?.classList.remove("is-dragover")
      this.processFiles(event.dataTransfer?.files)
    }

    this.modalElement?.addEventListener("click", this.boundHandleGridClick)
    this.searchElement?.addEventListener("input", this.boundFilter)
    this.fileInputElement?.addEventListener("change", this.boundUploadFiles)
    this.uploadZoneElement?.addEventListener("dragover", this.boundDragOver)
    this.uploadZoneElement?.addEventListener("dragleave", this.boundDragLeave)
    this.uploadZoneElement?.addEventListener("drop", this.boundDrop)

    this.updateRemoveButton()
  }

  disconnect() {
    this.modalElement?.removeEventListener("click", this.boundHandleGridClick)
    this.searchElement?.removeEventListener("input", this.boundFilter)
    this.fileInputElement?.removeEventListener("change", this.boundUploadFiles)
    this.uploadZoneElement?.removeEventListener("dragover", this.boundDragOver)
    this.uploadZoneElement?.removeEventListener("dragleave", this.boundDragLeave)
    this.uploadZoneElement?.removeEventListener("drop", this.boundDrop)
    this.disposeModalInstance()
    this.restoreModalFromBody()
  }

  async openModal(event) {
    event.preventDefault()
    this.setUploadStatus("")

    if (this.items.length === 0) {
      await this.loadMedia()
    }

    this.searchElement.value = ""
    this.renderGrid(this.items)
    this.getModalInstance().show()
  }

  filter() {
    if (!this.allItems) return

    const query = this.searchElement.value.trim().toLowerCase()
    const filtered = query
      ? this.allItems.filter((item) => {
          const title = (item.title || "").toLowerCase()
          const filename = (item.filename || "").toLowerCase()
          return title.includes(query) || filename.includes(query)
        })
      : this.allItems

    this.renderGrid(filtered)
  }

  uploadFiles(event) {
    this.processFiles(event.target.files)
    event.target.value = ""
  }

  async processFiles(fileList) {
    const files = Array.from(fileList || [])
    for (const file of files) {
      await this.uploadOne(file)
    }
  }

  openFilePicker(event) {
    if (event.target.closest("input[type='file']") || event.target.closest("label")) return
    event.preventDefault()
    this.fileInputElement?.click()
  }

  async uploadOne(file) {
    this.setUploadStatus(`${this.uploadingLabelValue}: ${file.name}`)

    try {
      if (!fileMatchesAccept(file, this.acceptValue)) {
        throw new Error("invalid_type")
      }

      const media = await uploadMediaFile(file, {
        mediaIndexUrl: this.mediaIndexUrlValue,
        accept: this.acceptValue
      })

      this.items = [media, ...this.items.filter((item) => item.id !== media.id)]
      this.allItems = this.items
      this.renderGrid(this.items)
      this.selectMedia(media)
    } catch (error) {
      const message = error.message === "invalid_type" ? this.invalidTypeLabelValue : error.message
      this.setUploadStatus(`${message}: ${file.name}`)
    }
  }

  setUploadStatus(text) {
    if (this.uploadStatusElement) {
      this.uploadStatusElement.textContent = text
    }
  }

  select(event) {
    event.preventDefault()
    const id = event.currentTarget.dataset.mediaId
    if (!id) return

    const media = this.items.find((item) => String(item.id) === String(id))
    if (media) this.selectMedia(media)
  }

  handleGridClick(event) {
    const button = event.target.closest("[data-media-id]")
    if (!button || !this.gridElement?.contains(button)) return

    this.select({ preventDefault: () => {}, currentTarget: button })
  }

  selectMedia(media) {
    this.inputTarget.value = media.id
    this.updatePreview(media)
    this.updateRemoveButton()
    this.setUploadStatus("")
    this.getModalInstance().hide()
  }

  clearMedia(event) {
    event.preventDefault()
    this.inputTarget.value = ""
    this.updatePreview(null)
    this.updateRemoveButton()
  }

  updateRemoveButton() {
    if (!this.hasRemoveButtonTarget) return

    const hasValue = this.inputTarget.value?.toString().trim().length > 0
    this.removeButtonTarget.classList.toggle("d-none", !hasValue)
    this.removeButtonTarget.disabled = !hasValue
  }

  async loadMedia() {
    const params = new URLSearchParams()
    if (this.acceptValue) params.set("accept", this.acceptValue)

    const response = await fetch(`${this.mediaIndexUrlValue}?${params.toString()}`, {
      headers: { Accept: "application/json" },
      credentials: "same-origin"
    })

    this.items = response.ok ? await response.json() : []
    this.allItems = this.items
  }

  renderGrid(items) {
    const selected = this.inputTarget.value
    const buttons = items.map((item) => {
      const selectedClass = String(item.id) === String(selected) ? " is-selected" : ""
      const preview = this.previewMarkup(item)
      return `<button type="button" class="brawo-media-picker__item${selectedClass}" data-media-id="${item.id}" title="${escapeHtml(item.title || item.filename || item.id)}">${preview}</button>`
    })

    this.gridElement.innerHTML = buttons.join("")
  }

  previewMarkup(item) {
    const src = mediaImageUrl(item, "thumb")
    if (item.content_type?.startsWith("image/") && src) {
      return `<img src="${escapeHtml(src)}" alt="" class="brawo-media-picker__item-image">`
    }

    return `<span class="brawo-media-picker__item-icon" aria-hidden="true"><i class="bi bi-file-earmark"></i></span>`
  }

  updatePreview(media) {
    if (!this.hasPreviewTarget) return

    if (!media) {
      this.previewTarget.innerHTML = `<span class="brawo-media-picker__placeholder">${escapeHtml(this.noneLabelValue)}</span>`
      return
    }

    if (media.content_type?.startsWith("image/") && mediaImageUrl(media, "thumb")) {
      this.previewTarget.innerHTML = `<img src="${escapeHtml(mediaImageUrl(media, "thumb"))}" alt="" class="brawo-media-picker__preview-image">`
      return
    }

    this.previewTarget.innerHTML = `<span class="brawo-media-picker__placeholder">${escapeHtml(media.filename || media.title || media.id)}</span>`
  }

  mountModalOnBody() {
    if (!this.hasModalTarget) return

    this.modalElement = this.modalTarget
    this.searchElement = this.searchTarget
    this.gridElement = this.gridTarget
    this.uploadStatusElement = this.hasUploadStatusTarget ? this.uploadStatusTarget : null
    this.fileInputElement = this.hasFileInputTarget ? this.fileInputTarget : null
    this.uploadZoneElement = this.hasUploadZoneTarget ? this.uploadZoneTarget : null
    this.modalPlaceholder = document.createComment("media-picker-modal-anchor")
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
