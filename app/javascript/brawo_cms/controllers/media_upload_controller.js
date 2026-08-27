import { Controller } from "@hotwired/stimulus"
import {
  uploadMediaFile,
  fileMatchesAccept,
  mediaPreviewMarkup,
  mediaImageUrl,
  escapeHtml
} from "brawo_cms/media_upload"

export default class extends Controller {
  static targets = ["zone", "fileInput", "log", "grid", "emptyState"]
  static values = {
    mediaIndexUrl: String,
    accept: { type: String, default: "image/*,application/pdf" },
    uploadingLabel: { type: String, default: "Uploading…" },
    successLabel: { type: String, default: "Uploaded" },
    failedLabel: { type: String, default: "Upload failed" },
    invalidTypeLabel: { type: String, default: "File type not allowed" },
    viewLabel: { type: String, default: "View" },
    editLabel: { type: String, default: "Edit" }
  }

  dragOver(event) {
    event.preventDefault()
    this.zoneTarget.classList.add("is-dragover")
  }

  dragLeave() {
    this.zoneTarget.classList.remove("is-dragover")
  }

  drop(event) {
    event.preventDefault()
    this.zoneTarget.classList.remove("is-dragover")
    this.queueFiles(event.dataTransfer?.files)
  }

  pickFiles(event) {
    this.queueFiles(event.target.files)
    event.target.value = ""
  }

  openFilePicker(event) {
    if (event.target.closest("input[type='file']")) return
    event.preventDefault()
    this.fileInputTarget.click()
  }

  async queueFiles(fileList) {
    const files = Array.from(fileList || [])
    for (const file of files) {
      await this.uploadOne(file)
    }
  }

  async uploadOne(file) {
    const entry = this.addLogEntry(file, "uploading")

    try {
      if (!fileMatchesAccept(file, this.acceptValue)) {
        throw new Error("invalid_type")
      }

      const media = await uploadMediaFile(file, {
        mediaIndexUrl: this.mediaIndexUrlValue,
        accept: this.acceptValue
      })

      this.updateLogEntry(entry, "success", media)
      this.appendGridCard(media)
      this.hideEmptyState()
    } catch (error) {
      const message = error.message === "invalid_type" ? this.invalidTypeLabelValue : error.message
      this.updateLogEntry(entry, "error", null, message)
    }
  }

  addLogEntry(file, status) {
    const item = document.createElement("li")
    item.className = `brawo-media-upload__log-item brawo-media-upload__log-item--${status}`
    item.dataset.filename = file.name
    item.innerHTML = this.logEntryHtml({ name: file.name, type: file.type }, status)
    this.logTarget.hidden = false
    this.logTarget.prepend(item)
    return item
  }

  updateLogEntry(entry, status, media, errorMessage = null) {
    entry.className = `brawo-media-upload__log-item brawo-media-upload__log-item--${status}`
    const payload = media || { filename: entry.dataset.filename, name: entry.dataset.filename }
    entry.innerHTML = this.logEntryHtml(payload, status, errorMessage)
  }

  logEntryHtml(fileOrMedia, status, errorMessage = null) {
    const filename = fileOrMedia.filename || fileOrMedia.name || "file"
    const preview = status === "success" && fileOrMedia.url
      ? mediaPreviewMarkup(fileOrMedia)
      : fileOrMedia.type?.startsWith("image/")
        ? `<span class="brawo-media-upload__log-icon" aria-hidden="true"><i class="bi bi-image"></i></span>`
        : `<span class="brawo-media-upload__log-icon" aria-hidden="true"><i class="bi bi-file-earmark"></i></span>`

    let statusText = this.uploadingLabelValue
    if (status === "success") statusText = this.successLabelValue
    if (status === "error") statusText = errorMessage || this.failedLabelValue

    return `
      <span class="brawo-media-upload__log-preview">${preview}</span>
      <span class="brawo-media-upload__log-body">
        <span class="brawo-media-upload__log-name">${escapeHtml(filename)}</span>
        <span class="brawo-media-upload__log-status">${escapeHtml(statusText)}</span>
      </span>
    `
  }

  appendGridCard(media) {
    if (!this.hasGridTarget) return

    this.gridTarget.classList.remove("d-none")
    const card = document.createElement("div")
    card.className = "brawo-media-card"
    card.innerHTML = this.gridCardHtml(media)
    this.gridTarget.prepend(card)
  }

  gridCardHtml(media) {
    const preview = media.content_type?.startsWith("image/") && mediaImageUrl(media, "thumb")
      ? `<img src="${escapeHtml(mediaImageUrl(media, "thumb"))}" class="brawo-media-card__image" alt="">`
      : `<div class="brawo-media-card__file-icon" aria-hidden="true"><i class="bi bi-file-earmark"></i></div>`

    const title = escapeHtml(media.title || media.filename || `Media #${media.id}`)
    const filename = media.filename ? `<div class="brawo-media-card__meta text-muted small">${escapeHtml(media.filename)}</div>` : ""
    const showPath = `/admin/admin/media/${media.id}`
    const editPath = `/admin/admin/media/${media.id}/edit`

    return `
      <div class="brawo-media-card__preview">${preview}</div>
      <div class="brawo-media-card__body">
        <div class="brawo-media-card__title">${title}</div>
        ${filename}
        <div class="brawo-media-card__actions">
          <a href="${showPath}" class="btn btn-sm btn-outline-secondary">${escapeHtml(this.viewLabelValue)}</a>
          <a href="${editPath}" class="btn btn-sm btn-outline-primary">${escapeHtml(this.editLabelValue)}</a>
        </div>
      </div>
    `
  }

  hideEmptyState() {
    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.classList.add("d-none")
    }
  }
}
