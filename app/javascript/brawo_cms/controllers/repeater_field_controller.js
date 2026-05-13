import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["items", "template"]

  connect() {
    this.fieldName = this.element.dataset.fieldName
    this.boundClick = this.onClick.bind(this)
    this.element.addEventListener("click", this.boundClick)
  }

  disconnect() {
    this.element.removeEventListener("click", this.boundClick)
  }

  onClick(event) {
    const addBtn = event.target.closest(".repeater-add-btn")
    if (addBtn && this.element.contains(addBtn)) {
      event.preventDefault()
      this.addRow()
      return
    }

    const removeBtn = event.target.closest(".repeater-remove-btn")
    if (removeBtn && this.itemsTarget.contains(removeBtn)) {
      event.preventDefault()
      this.removeRow(removeBtn)
    }
  }

  addRow() {
    const container = this.itemsTarget
    const template = this.templateTarget
    const fieldName = this.fieldName

    const newRow = template.cloneNode(true)
    newRow.classList.remove("repeater-template")
    newRow.style.display = ""

    const existingRows = container.querySelectorAll(".repeater-row:not(.repeater-template)")
    const nextIndex = existingRows.length

    this.updateRowIndex(newRow, "INDEX", nextIndex, fieldName)

    container.insertBefore(newRow, template)
    this.reindexRows(container, fieldName)
  }

  removeRow(button) {
    const row = button.closest(".repeater-row")
    if (!row) return

    const container = row.closest(".repeater-items")
    row.remove()

    if (container) {
      const fieldName = container.closest(".repeater-field").dataset.fieldName
      this.reindexRows(container, fieldName)
    }
  }

  updateRowIndex(row, oldIndex, newIndex, fieldName) {
    row.dataset.index = newIndex

    row.querySelectorAll("input, select, textarea, label").forEach((element) => {
      if (element.tagName === "LABEL") {
        const forAttr = element.getAttribute("for")
        if (forAttr) {
          element.setAttribute(
            "for",
            forAttr.replace(new RegExp("\\[" + oldIndex + "\\]", "g"), "[" + newIndex + "]")
          )
        }
      } else {
        const name = element.getAttribute("name")
        const id = element.getAttribute("id")

        if (name) {
          element.setAttribute(
            "name",
            name.replace(new RegExp("\\[" + oldIndex + "\\]", "g"), "[" + newIndex + "]")
          )
        }

        if (id) {
          element.setAttribute(
            "id",
            id
              .replace(new RegExp("_" + oldIndex + "_", "g"), "_" + newIndex + "_")
              .replace(new RegExp("\\[" + oldIndex + "\\]", "g"), "[" + newIndex + "]")
          )
        }
      }
    })
  }

  reindexRows(container, fieldName) {
    const rows = container.querySelectorAll(".repeater-row:not(.repeater-template)")
    rows.forEach((row, index) => {
      const currentIndex = row.dataset.index
      if (currentIndex !== index.toString()) {
        this.updateRowIndex(row, currentIndex, index, fieldName)
      }
    })
  }
}
