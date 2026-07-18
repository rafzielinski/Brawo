import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = {
    handle: { type: String, default: ".drag-handle" }
  }

  connect() {
    const isOutline = this.element.classList.contains("page-builder-outline-list")

    this.sortable = Sortable.create(this.element, {
      handle: this.handleValue,
      animation: 150,
      draggable: isOutline ? ".page-builder-outline-item" : ".page-builder-block",
      filter: ".block-insert-zone",
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
