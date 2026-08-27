import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = {
    handle: { type: String, default: ".drag-handle" }
  }

  connect() {
    this.createSortable()
  }

  disconnect() {
    this.destroySortable()
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
}
