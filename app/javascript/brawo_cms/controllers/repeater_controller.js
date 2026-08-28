import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["collapseAllBtn"]

  static values = {
    fieldName: String,
    translations: Object
  }

  connect() {
    this.updateCollapseAllBtn()
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

  moveRow(event) {
    event.preventDefault()
    const row = event.currentTarget.closest(".repeater-row")
    if (!row) return

    const container = row.closest(".repeater-items")
    if (!container) return

    const rows = [...container.querySelectorAll(".repeater-row:not(.repeater-template)")]
    const index = rows.indexOf(row)
    if (index === -1) return

    const targetIndex = this.targetIndex(index, rows.length, event.currentTarget.dataset.moveDirection)
    if (targetIndex === null || targetIndex === index) return

    const template = container.querySelector(".repeater-template")
    row.remove()

    const remaining = [...container.querySelectorAll(".repeater-row:not(.repeater-template)")]
    if (targetIndex >= remaining.length) {
      container.insertBefore(row, template)
    } else {
      container.insertBefore(row, remaining[targetIndex])
    }

    this.reindexRows(container)
  }

  targetIndex(index, count, direction) {
    switch (direction) {
      case "up":
        return index > 0 ? index - 1 : null
      case "down":
        return index < count - 1 ? index + 1 : null
      case "top":
        return index > 0 ? 0 : null
      case "bottom":
        return index < count - 1 ? count - 1 : null
      default:
        return null
    }
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

  reindex() {
    const container = this.element.querySelector(".repeater-items")
    if (container) this.reindexRows(container)
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

  toggleAllRowsCollapse(event) {
    event.preventDefault()
    event.stopPropagation()

    const rows = this.repeaterRows()
    if (rows.length === 0) return

    const allCollapsed = rows.every((row) => row.classList.contains("is-collapsed"))
    rows.forEach((row) => {
      row.classList.toggle("is-collapsed", !allCollapsed)
      this.syncCollapsibleToggle(row)
    })

    this.updateCollapseAllBtn()
  }

  repeaterRows() {
    return [...this.element.querySelectorAll(".repeater-items .repeater-row:not(.repeater-template)")]
  }

  syncCollapsibleToggle(element) {
    const toggle = element.querySelector(".collapsible-toggle")
    if (toggle) toggle.setAttribute("aria-expanded", !element.classList.contains("is-collapsed"))
  }

  updateCollapseAllBtn() {
    if (!this.hasCollapseAllBtnTarget) return

    const rows = this.repeaterRows()
    const allCollapsed = rows.length > 0 && rows.every((row) => row.classList.contains("is-collapsed"))

    this.collapseAllBtnTarget.textContent = allCollapsed
      ? this.translation("expand_all")
      : this.translation("collapse_all")
  }

  translation(key) {
    return this.hasTranslationsValue ? this.translationsValue[key] || "" : ""
  }
}
