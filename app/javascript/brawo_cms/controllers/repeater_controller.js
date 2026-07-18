import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    fieldName: String
  }

  addRow(event) {
    event.preventDefault()
    const repeaterField = this.element
    const container = repeaterField.querySelector(".repeater-items")
    const template = container.querySelector(".repeater-template")
    if (!container || !template) return

    const newRow = template.cloneNode(true)
    newRow.classList.remove("repeater-template")
    newRow.style.display = ""

    const existingRows = container.querySelectorAll(".repeater-row:not(.repeater-template)")
    const nextIndex = existingRows.length
    this.updateRowIndex(newRow, "INDEX", nextIndex)

    const removeBtn = newRow.querySelector("[data-action*='removeRow']")
    if (removeBtn) {
      removeBtn.disabled = false
      removeBtn.addEventListener("click", (e) => this.removeRow(e))
    }

    container.insertBefore(newRow, template)
    this.reindexRows(container)
  }

  removeRow(event) {
    event.preventDefault()
    const row = event.currentTarget.closest(".repeater-row")
    if (!row) return

    const container = row.closest(".repeater-items")
    row.remove()
    if (container) this.reindexRows(container)
  }

  updateRowIndex(row, oldIndex, newIndex) {
    row.dataset.index = newIndex

    row.querySelectorAll("input, select, textarea, label").forEach((element) => {
      if (element.tagName === "LABEL") {
        const forAttr = element.getAttribute("for")
        if (forAttr) {
          element.setAttribute("for", forAttr.replace(
            new RegExp(`\\[${oldIndex}\\]`, "g"),
            `[${newIndex}]`
          ))
        }
      } else {
        const name = element.getAttribute("name")
        const id = element.getAttribute("id")
        if (name) {
          element.setAttribute("name", name.replace(
            new RegExp(`\\[${oldIndex}\\]`, "g"),
            `[${newIndex}]`
          ))
        }
        if (id) {
          element.setAttribute("id", id.replace(
            new RegExp(`_${oldIndex}_`, "g"),
            `_${newIndex}_`
          ).replace(
            new RegExp(`\\[${oldIndex}\\]`, "g"),
            `[${newIndex}]`
          ))
        }
      }
    })
  }

  reindexRows(container) {
    const rows = container.querySelectorAll(".repeater-row:not(.repeater-template)")
    rows.forEach((row, index) => {
      const currentIndex = row.dataset.index
      if (currentIndex !== index.toString()) {
        this.updateRowIndex(row, currentIndex, index)
      }
    })
  }
}
