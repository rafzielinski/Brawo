import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "picker", "outline", "outlinePanel"]
  static values = {
    fieldName: String,
    formPrefix: String,
    translations: Object
  }

  connect() {
    this.insertPosition = 0
    this.relativeBlock = null
    if (this.hasPickerTarget && window.bootstrap) {
      this.picker = new bootstrap.Offcanvas(this.pickerTarget)
    }
    this.outlineOpen = false
    this.updateEmptyState()
    this.refreshOutline()
  }

  openPicker(event) {
    event.preventDefault()
    event.stopPropagation()
    this.relativeBlock = null
    this.insertPosition = parseInt(event.currentTarget.dataset.insertPosition, 10) || 0
    this.showPicker()
  }

  openPickerRelative(event) {
    event.preventDefault()
    event.stopPropagation()
    const block = event.currentTarget.closest(".page-builder-block")
    const offset = parseInt(event.currentTarget.dataset.insertOffset, 10) || 0
    this.relativeBlock = block
    this.insertPosition = parseInt(block.dataset.blockIndex, 10) + offset
    this.showPicker()
  }

  showPicker() {
    if (this.picker) {
      this.picker.show()
    } else if (this.hasPickerTarget) {
      this.pickerTarget.classList.add("show")
    }
  }

  closePicker(event) {
    if (event) event.preventDefault()
    if (this.picker) {
      this.picker.hide()
    } else if (this.hasPickerTarget) {
      this.pickerTarget.classList.remove("show")
    }
  }

  closePickerOnEscape(event) {
    if (event.key === "Escape") this.closePicker()
  }

  pickBlockType(event) {
    event.preventDefault()
    const blockType = event.currentTarget.dataset.blockType
    this.insertBlockAt(this.insertPosition, blockType)
    this.closePicker()
  }

  insertBlockAt(position, blockType) {
    const template = this.element.querySelector(`.page-builder-template[data-block-type="${blockType}"]`)
    if (!template || !this.hasCanvasTarget) return

    const clone = template.querySelector(".page-builder-block").cloneNode(true)
    this.enableFields(clone)
    this.wireBlockActions(clone)

    const canvas = this.canvasTarget
    const zone = canvas.querySelector(`.block-insert-zone[data-insert-position="${position}"]`)

    if (zone) {
      canvas.insertBefore(clone, zone.nextElementSibling)
    } else {
      const templates = this.element.querySelector(".page-builder-templates")
      canvas.insertBefore(clone, templates ? null : undefined)
    }

    this.rebuildCanvasStructure()
    this.focusBlockElement(clone)
  }

  removeBlock(event) {
    event.preventDefault()
    const block = event.currentTarget.closest(".page-builder-block")
    if (!block) return

    block.remove()
    this.rebuildCanvasStructure()
  }

  moveBlock(event) {
    event.preventDefault()
    const block = event.currentTarget.closest(".page-builder-block")
    if (!block || !this.hasCanvasTarget) return

    const blocks = [...this.canvasTarget.querySelectorAll(":scope > .page-builder-block")]
    const index = blocks.indexOf(block)
    const targetIndex = this.targetIndex(index, blocks.length, event.currentTarget.dataset.moveDirection)
    if (targetIndex === null || targetIndex === index) return

    blocks.splice(index, 1)
    blocks.splice(targetIndex, 0, block)
    this.rebuildCanvasWithBlocks(blocks)
    this.focusBlockElement(block)
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

  reindex() {
    this.rebuildCanvasStructure()
  }

  reindexFromOutline() {
    if (!this.hasOutlineTarget || !this.hasCanvasTarget) return

    const blocks = [...this.outlineTarget.querySelectorAll(".page-builder-outline-item")]
      .map((item) => {
        const index = item.dataset.blockIndex
        return this.canvasTarget.querySelector(`.page-builder-block[data-block-index="${index}"]`)
      })
      .filter(Boolean)

    this.rebuildCanvasWithBlocks(blocks)
  }

  rebuildCanvasStructure() {
    if (!this.hasCanvasTarget) return

    const canvas = this.canvasTarget
    const blocks = [...canvas.querySelectorAll(":scope > .page-builder-block")]
    this.rebuildCanvasWithBlocks(blocks)
  }

  rebuildCanvasWithBlocks(blocks) {
    const canvas = this.canvasTarget
    canvas.querySelectorAll(":scope > .block-insert-zone").forEach((zone) => zone.remove())

    blocks.forEach((block, index) => {
      this.assignIndex(block, index)
    })

    const fragment = document.createDocumentFragment()
    fragment.appendChild(this.createInsertZone(0))

    blocks.forEach((block, index) => {
      fragment.appendChild(block)
      fragment.appendChild(this.createInsertZone(index + 1))
    })

    const templates = this.element.querySelector(".page-builder-templates")
    canvas.innerHTML = ""
    canvas.appendChild(fragment)

    blocks.forEach((block) => this.wireBlockActions(block))

    this.updateAddBarPositions(blocks.length)
    this.updateEmptyState()
    this.refreshOutline()
  }

  createInsertZone(position) {
    const zone = document.createElement("div")
    zone.className = "block-insert-zone"
    zone.dataset.insertPosition = position

    const btn = document.createElement("button")
    btn.type = "button"
    btn.className = "block-insert-zone-btn"
    btn.title = this.translation("insert_block")
    btn.textContent = "+"
    btn.dataset.action = "page-builder#openPicker"
    btn.dataset.insertPosition = position

    zone.appendChild(btn)
    return zone
  }

  updateAddBarPositions(count) {
    const topBtn = this.element.querySelector(".page-builder-toolbar [data-insert-position]")
    const bottomBtn = this.element.querySelector(".page-builder-add-bar--bottom [data-insert-position]")
    if (topBtn) topBtn.dataset.insertPosition = "0"
    if (bottomBtn) bottomBtn.dataset.insertPosition = String(count)
  }

  assignIndex(block, index) {
    block.dataset.blockIndex = index
    const fieldName = this.fieldNameValue

    block.querySelectorAll("input, select, textarea, label").forEach((element) => {
      ["name", "for", "id"].forEach((attr) => {
        const value = element.getAttribute(attr)
        if (!value) return

        const updated = value
          .replace(new RegExp(`\\[${fieldName}\\]\\[\\d+\\]`), `[${fieldName}][${index}]`)
          .replace(/\[INDEX\]/g, `[${index}]`)

        element.setAttribute(attr, updated)
      })
    })
  }

  enableFields(block) {
    block.querySelectorAll("input, select, textarea, button").forEach((el) => {
      el.disabled = false
    })
  }

  wireBlockActions(block) {
    block.querySelectorAll("[data-action*='removeBlock']").forEach((btn) => {
      btn.disabled = false
    })
  }

  refreshOutline() {
    if (!this.hasOutlineTarget || !this.hasCanvasTarget) return

    const canvas = this.canvasTarget
    const blocks = [...canvas.querySelectorAll(":scope > .page-builder-block")]
    const list = this.outlineTarget
    list.innerHTML = ""

    blocks.forEach((block, index) => {
      const label = block.dataset.blockLabel || block.dataset.blockType

      const item = document.createElement("li")
      item.className = "page-builder-outline-item"
      item.dataset.blockIndex = index

      item.innerHTML = `
        <span class="outline-drag-handle" title="${this.escapeHtml(this.translation("drag_to_reorder"))}">⋮⋮</span>
        <span class="outline-item-label">
          <strong>${this.escapeHtml(label)}</strong>
        </span>
      `

      item.addEventListener("click", (event) => {
        if (event.target.closest(".outline-drag-handle")) return
        this.focusBlockElement(block)
      })

      list.appendChild(item)
    })
  }

  focusBlock(event) {
    const item = event.currentTarget.closest(".page-builder-outline-item")
    if (!item || !this.hasCanvasTarget) return

    const index = item.dataset.blockIndex
    const block = this.canvasTarget.querySelector(`.page-builder-block[data-block-index="${index}"]`)
    if (block) this.focusBlockElement(block)
  }

  focusBlockElement(block) {
    this.element.querySelectorAll(".page-builder-block.is-focused").forEach((el) => {
      el.classList.remove("is-focused")
    })
    this.element.querySelectorAll(".page-builder-outline-item.is-active").forEach((el) => {
      el.classList.remove("is-active")
    })

    block.classList.add("is-focused")
    block.scrollIntoView({ behavior: "smooth", block: "center" })

    const index = block.dataset.blockIndex
    const outlineItem = this.hasOutlineTarget
      ? this.outlineTarget.querySelector(`.page-builder-outline-item[data-block-index="${index}"]`)
      : null
    if (outlineItem) outlineItem.classList.add("is-active")
  }

  toggleOutline() {
    if (!this.hasOutlinePanelTarget) return
    this.outlineOpen = !this.outlineOpen
    this.outlinePanelTarget.classList.toggle("is-collapsed", !this.outlineOpen)
    this.element.classList.toggle("outline-collapsed", !this.outlineOpen)

    const btn = this.element.querySelector(".page-builder-structure-btn")
    if (btn) btn.classList.toggle("active", this.outlineOpen)
  }

  updateEmptyState() {
    if (!this.hasCanvasTarget) return

    const empty = this.element.querySelector(".page-builder-empty")
    if (!empty) return

    const count = this.canvasTarget.querySelectorAll(":scope > .page-builder-block").length
    empty.classList.toggle("is-hidden", count > 0)
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  translation(key, replacements = {}) {
    let value = this.hasTranslationsValue ? this.translationsValue[key] : null
    if (!value) return ""

    Object.entries(replacements).forEach(([name, replacement]) => {
      value = value.replace(`%{${name}}`, replacement)
    })

    return value
  }
}
