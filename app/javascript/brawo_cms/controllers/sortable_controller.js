import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = {
    handle: { type: String, default: ".drag-handle" }
  }

  connect() {
    const isOutline = this.element.classList.contains("page-builder-outline-list")
    const isRepeater = this.element.classList.contains("repeater-items")

    let draggable = ".page-builder-block"
    if (isOutline) draggable = ".page-builder-outline-item"
    else if (isRepeater) draggable = ".repeater-row"

    const filter = isRepeater ? ".repeater-template" : ".block-insert-zone"

    this.sortable = Sortable.create(this.element, {
      handle: this.handleValue,
      animation: 150,
      draggable,
      filter,
      preventOnFilter: false,
      onEnd: () => this.dispatch("sorted", { bubbles: true })
    })
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
      this.sortable = null
    }
  }
}
