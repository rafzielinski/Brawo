import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = {
    handle: { type: String, default: ".drag-handle" }
  }

  connect() {
    this.canvasDragging = false
    this.canvasSafetyActive = false
    this.boundCanvasDragSafety = this.handleCanvasDragSafety.bind(this)
    this.createSortable()
  }

  disconnect() {
    this.destroySortable()
    this.removeCanvasDragSafety()
  }

  reconnect() {
    this.destroySortable()
    this.createSortable()
  }

  createSortable() {
    const isStructureList = this.element.classList.contains("page-builder-structure-list")
    const isRepeater = this.element.classList.contains("repeater-items")
    const isCanvas = this.element.classList.contains("page-builder-canvas")

    let draggable = ".page-builder-block"
    if (isStructureList) draggable = ".page-builder-structure-item"
    else if (isRepeater) draggable = ".repeater-row"

    const options = {
      handle: this.handleValue,
      animation: 150,
      draggable,
      preventOnFilter: false,
      onEnd: () => this.dispatch("sorted", { bubbles: true })
    }

    if (isRepeater) {
      options.filter = ".repeater-template"
      options.onStart = () => this.setParentCanvasSortable(true)
      options.onEnd = () => {
        this.setParentCanvasSortable(false)
        this.dispatch("sorted", { bubbles: true })
      }
    } else if (isCanvas) {
      options.filter = ".block-insert-zone, .repeater-field, .repeater-items, .repeater-row"
      options.cancel = "input,textarea,button,select,option,.repeater-field,.repeater-items,.repeater-row,.repeater-drag-handle"
      options.bubbleScroll = true
      options.scrollSensitivity = 60
      options.scrollSpeed = 12
      options.onStart = (evt) => this.onCanvasDragStart(evt)
      options.onEnd = (evt) => this.onCanvasDragEnd(evt)
      this.addCanvasDragSafety()
    } else if (!isStructureList) {
      options.filter = ".block-insert-zone"
    }

    this.sortable = Sortable.create(this.element, options)
  }

  destroySortable() {
    if (this.sortable) {
      this.sortable.destroy()
      this.sortable = null
    }
  }

  setParentCanvasSortable(disabled) {
    const canvas = this.element.closest(".page-builder-canvas")
    if (!canvas) return

    const controller = this.application.getControllerForElementAndIdentifier(canvas, "sortable")
    controller?.sortable?.option("disabled", disabled)
  }

  addCanvasDragSafety() {
    if (this.canvasSafetyActive) return

    document.addEventListener("pointerup", this.boundCanvasDragSafety, true)
    document.addEventListener("pointercancel", this.boundCanvasDragSafety, true)
    this.canvasSafetyActive = true
  }

  removeCanvasDragSafety() {
    if (!this.canvasSafetyActive) return

    document.removeEventListener("pointerup", this.boundCanvasDragSafety, true)
    document.removeEventListener("pointercancel", this.boundCanvasDragSafety, true)
    this.canvasSafetyActive = false
  }

  onCanvasDragStart(evt) {
    this.canvasDragging = true
    this.setCanvasDragImage(evt)
  }

  onCanvasDragEnd() {
    this.canvasDragging = false
    this.cleanupCanvasDragState()
    this.dispatch("sorted", { bubbles: true })
  }

  handleCanvasDragSafety() {
    if (!this.element.classList.contains("page-builder-canvas")) return

    requestAnimationFrame(() => {
      if (!this.canvasDragging) return

      this.canvasDragging = false
      this.cleanupCanvasDragState()
      this.dispatch("sorted", { bubbles: true })
    })
  }

  setCanvasDragImage(evt) {
    const block = evt.item
    const event = evt.originalEvent
    if (!event?.dataTransfer || block.getBoundingClientRect().height < 320) return

    const header = block.querySelector(".page-builder-block-header")
    if (!header) return

    const preview = header.cloneNode(true)
    preview.style.cssText = `position:fixed;left:-9999px;top:0;width:${block.getBoundingClientRect().width}px;pointer-events:none;`
    document.body.appendChild(preview)
    event.dataTransfer.setDragImage(preview, event.offsetX, event.offsetY)
    requestAnimationFrame(() => preview.remove())
  }

  cleanupCanvasDragState() {
    this.element.querySelectorAll(".page-builder-block").forEach((block) => {
      block.classList.remove("sortable-ghost", "sortable-chosen", "sortable-drag")
      if (block.style.display === "none") block.style.removeProperty("display")
    })
  }
}
