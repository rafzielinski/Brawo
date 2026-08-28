import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "collapseAllBtn"]
  static values = {
    fieldName: String,
    formPrefix: String,
    translations: Object
  }

  connect() {
    this.insertPosition = 0
    this.relativeBlock = null
    this.panelSection = "add"
    this.updateEmptyState()
    this.syncPanelOutline()
  }

  openPanel(event) {
    event.preventDefault()
    event.stopPropagation()

    if (event.currentTarget.dataset.insertPosition !== undefined) {
      this.insertPosition = parseInt(event.currentTarget.dataset.insertPosition, 10) || 0
    }

    this.panelSection = event.currentTarget.dataset.panelSection || "add"
    this.relativeBlock = null
    this.clearBlockFocus()
    this.adminSidePanel()?.open({ section: this.panelSection })
  }

  openPicker(event) {
    this.openPanel(event)
  }

  openPickerRelative(event) {
    event.preventDefault()
    event.stopPropagation()
    const block = event.currentTarget.closest(".page-builder-block")
    const offset = parseInt(event.currentTarget.dataset.insertOffset, 10) || 0
    this.relativeBlock = block
    this.insertPosition = parseInt(block.dataset.blockIndex, 10) + offset
    this.panelSection = event.currentTarget.dataset.panelSection || "add"
    this.clearBlockFocus()
    this.adminSidePanel()?.open({ section: this.panelSection })
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
    const block = this.findBlockByIndex(String(position))
    if (block) this.scrollBlockIntoView(block)
  }

  removeBlock(event) {
    event.preventDefault()
    const block = event.currentTarget.closest(".page-builder-block")
    if (!block) return

    if (block.classList.contains("is-focused")) this.clearBlockFocus()
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
    if (!this.hasCanvasTarget) return

    const blocks = [...this.canvasTarget.querySelectorAll(":scope > .page-builder-block")]
    blocks.forEach((block, index) => this.assignIndex(block, index))
    this.renumberInsertZones()
    this.updateAddBarPositions(blocks.length)
    this.syncPanelOutline()
  }

  currentInsertPosition() {
    return this.insertPosition
  }

  reindexFromOutline(outlineEl) {
    if (!outlineEl || !this.hasCanvasTarget) return

    const blocks = [...outlineEl.querySelectorAll(".page-builder-structure-item")]
      .map((item) => this.findBlockByIndex(item.dataset.blockIndex))
      .filter(Boolean)

    this.rebuildCanvasWithBlocks(blocks)
  }

  findBlockByIndex(index) {
    if (!this.hasCanvasTarget) return null
    return this.canvasTarget.querySelector(`.page-builder-block[data-block-index="${index}"]`)
  }

  canvasBlocks() {
    if (!this.hasCanvasTarget) return []
    return [...this.canvasTarget.querySelectorAll(":scope > .page-builder-block")]
  }

  activeBlockIndex() {
    const active = this.element.querySelector(".page-builder-block.is-focused")
    return active ? active.dataset.blockIndex : null
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

    canvas.innerHTML = ""
    canvas.appendChild(fragment)

    blocks.forEach((block) => this.wireBlockActions(block))

    this.updateAddBarPositions(blocks.length)
    this.updateEmptyState()
    this.syncPanelOutline()
    this.refreshCanvasSortable()
  }

  renumberInsertZones() {
    if (!this.hasCanvasTarget) return

    let position = 0
    this.canvasTarget.querySelectorAll(":scope > .block-insert-zone").forEach((zone) => {
      zone.dataset.insertPosition = String(position)
      const btn = zone.querySelector(".block-insert-zone-btn")
      if (btn) btn.dataset.insertPosition = String(position)
      position += 1
    })
  }

  refreshCanvasSortable() {
    if (!this.hasCanvasTarget) return

    const controller = this.application.getControllerForElementAndIdentifier(this.canvasTarget, "sortable")
    controller?.reconnect()
  }

  createInsertZone(position) {
    const zone = document.createElement("div")
    zone.className = "block-insert-zone"
    zone.dataset.insertPosition = position

    const btn = document.createElement("button")
    btn.type = "button"
    btn.className = "block-insert-zone-btn"
    btn.title = this.translation("insert_block")
    btn.innerHTML = `<i class="bi bi-plus-lg brawo-icon brawo-icon--sm" aria-hidden="true"></i>`
    btn.dataset.action = "page-builder#openPanel"
    btn.dataset.insertPosition = position
    btn.dataset.panelSection = "add"

    zone.appendChild(btn)
    return zone
  }

  updateAddBarPositions(count) {
    const topBtn = this.element.querySelector(".page-builder-toolbar:not(.page-builder-toolbar--bottom) [data-insert-position]")
    const bottomBtn = this.element.querySelector(".page-builder-toolbar--bottom [data-insert-position]")
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

  syncPanelOutline() {
    this.pageBuilderSidePanel()?.syncOutline()
  }

  adminSidePanel() {
    const panel = document.getElementById("page-builder-side-panel")
    if (!panel) return null

    return this.application.getControllerForElementAndIdentifier(panel, "admin-side-panel")
  }

  pageBuilderSidePanel() {
    const panel = document.getElementById("page-builder-side-panel")
    if (!panel) return null

    return this.application.getControllerForElementAndIdentifier(panel, "page-builder-side-panel")
  }

  toggleBlockFocus(event) {
    if (event.target.closest(".drag-handle")) return
    if (event.target.closest(".collapsible-toggle")) return
    if (event.target.closest(".dropdown, .dropdown-menu, .item-actions-menu")) return

    const block = event.currentTarget.closest(".page-builder-block")
    if (block) this.focusBlockElement(block)
  }

  clearFocus(event) {
    if (!this.element.contains(event.target)) return
    if (event.target.closest(".page-builder-block")) return
    if (event.target.closest("#page-builder-side-panel")) return

    this.clearBlockFocus()
  }

  clearFocusOnEscape(event) {
    if (event.key !== "Escape") return
    if (document.getElementById("page-builder-side-panel")?.classList.contains("is-open")) return

    this.clearBlockFocus()
  }

  clearBlockFocus() {
    const hadFocus = this.element.querySelector(".page-builder-block.is-focused")
    if (!hadFocus) return

    this.element.querySelectorAll(".page-builder-block.is-focused").forEach((el) => {
      el.classList.remove("is-focused")
    })
    this.syncPanelOutline()
  }

  focusBlockElement(block) {
    const alreadyFocused = block.classList.contains("is-focused")

    this.element.querySelectorAll(".page-builder-block.is-focused").forEach((el) => {
      el.classList.remove("is-focused")
    })

    if (alreadyFocused) {
      this.syncPanelOutline()
      return
    }

    block.classList.add("is-focused")
    this.scrollBlockIntoView(block)
    this.syncPanelOutline()
  }

  scrollBlockIntoView(block) {
    const container = block.closest(".brawo-admin-main")
    if (!container) {
      block.scrollIntoView({ behavior: "smooth", block: "start" })
      return
    }

    const offset = this.focusScrollOffset()
    const blockTop = block.getBoundingClientRect().top
    const containerTop = container.getBoundingClientRect().top
    const targetScroll = container.scrollTop + (blockTop - containerTop) - offset

    container.scrollTo({ top: targetScroll, behavior: "smooth" })
  }

  focusScrollOffset() {
    const root = getComputedStyle(document.documentElement)
    const raw = root.getPropertyValue("--brawo-page-builder-focus-scroll-offset").trim()
    if (!raw) return 12

    const value = parseFloat(raw)
    if (raw.endsWith("rem")) return value * parseFloat(root.fontSize)
    return value
  }

  updateEmptyState() {
    if (!this.hasCanvasTarget) return

    const empty = this.element.querySelector(".page-builder-empty")
    if (!empty) return

    const count = this.canvasTarget.querySelectorAll(":scope > .page-builder-block").length
    empty.classList.toggle("is-hidden", count > 0)
  }

  toggleAllBlocksCollapse(event) {
    event.preventDefault()

    const blocks = this.canvasBlocks()
    if (blocks.length === 0) return

    const allCollapsed = blocks.every((block) => block.classList.contains("is-collapsed"))
    blocks.forEach((block) => {
      block.classList.toggle("is-collapsed", !allCollapsed)
      this.syncCollapsibleToggle(block)
    })

    if (this.hasCollapseAllBtnTarget) {
      const label = allCollapsed
        ? this.translation("collapse_all")
        : this.translation("expand_all")

      this.collapseAllBtnTargets.forEach((btn) => {
        btn.textContent = label
      })
    }
  }

  syncCollapsibleToggle(element) {
    const toggle = element.querySelector(".collapsible-toggle")
    if (toggle) toggle.setAttribute("aria-expanded", !element.classList.contains("is-collapsed"))
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
