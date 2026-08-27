import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["outline", "outlineEmpty"]
  static outlets = ["page-builder"]

  connect() {
    requestAnimationFrame(() => this.syncOutline())
  }

  pickBlockType(event) {
    event.preventDefault()
    const blockType = event.currentTarget.dataset.blockType
    if (!this.hasPageBuilderOutlet) return

    this.pageBuilderOutlet.insertBlockAt(this.pageBuilderOutlet.currentInsertPosition(), blockType)
    this.adminSidePanel()?.close()
  }

  reindexFromOutline() {
    if (!this.hasOutlineTarget || !this.hasPageBuilderOutlet) return
    this.pageBuilderOutlet.reindexFromOutline(this.outlineTarget)
  }

  focusBlock(event) {
    if (event.target.closest(".page-builder-structure-item__handle")) return

    const item = event.currentTarget.closest(".page-builder-structure-item")
    if (!item || !this.hasPageBuilderOutlet) return

    const block = this.pageBuilderOutlet.findBlockByIndex(item.dataset.blockIndex)
    if (!block) return

    const wasFocused = block.classList.contains("is-focused")
    this.pageBuilderOutlet.focusBlockElement(block)

    if (!wasFocused) this.adminSidePanel()?.close()
  }

  syncOutline() {
    if (!this.hasOutlineTarget || !this.hasPageBuilderOutlet) return

    const blocks = this.pageBuilderOutlet.canvasBlocks()
    const list = this.outlineTarget
    list.innerHTML = ""

    if (this.hasOutlineEmptyTarget) {
      this.outlineEmptyTarget.classList.toggle("d-none", blocks.length > 0)
    }

    blocks.forEach((block, index) => {
      const label = block.dataset.blockLabel || block.dataset.blockType
      const item = document.createElement("li")
      item.className = "page-builder-structure-item"
      item.dataset.blockIndex = index
      item.dataset.action = "click->page-builder-side-panel#focusBlock"

      item.innerHTML = `
        <span class="page-builder-structure-item__handle brawo-icon-btn" title="${this.escapeHtml(this.pageBuilderOutlet.translation("drag_to_reorder"))}"><i class="bi bi-grip-vertical brawo-icon" aria-hidden="true"></i></span>
        <span class="page-builder-structure-item__label">
          <strong>${this.escapeHtml(label)}</strong>
        </span>
      `

      list.appendChild(item)
    })

    const activeIndex = this.pageBuilderOutlet.activeBlockIndex()
    if (activeIndex !== null) {
      const activeItem = list.querySelector(`.page-builder-structure-item[data-block-index="${activeIndex}"]`)
      activeItem?.classList.add("is-active")
    }
  }

  adminSidePanel() {
    return this.application.getControllerForElementAndIdentifier(this.element, "admin-side-panel")
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
