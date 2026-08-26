import { Controller } from "@hotwired/stimulus"

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const SCHEME_PATTERN = /^([a-z][a-z0-9+.-]*):\/\//i
const DOMAIN_HOST_PATTERN = /^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}$/i
const LOCALHOST_PATTERN = /^localhost$/i

export default class extends Controller {
  static targets = ["input", "hidden", "feedback", "prefix"]
  static values = {
    kind: String,
    required: { type: Boolean, default: false },
    defaultScheme: { type: String, default: "https" },
    allowedSchemes: { type: Array, default: ["https", "http", "ftp"] },
    invalidMessage: String
  }

  connect() {
    this.boundValidate = this.validate.bind(this)
    this.boundPrepareUrlEdit = this.prepareUrlEdit.bind(this)
    this.boundSubmit = this.onFormSubmit.bind(this)
    this.inputTarget.addEventListener("blur", this.boundValidate)
    if (this.kindValue === "url") {
      this.inputTarget.addEventListener("focus", this.boundPrepareUrlEdit)
    }
    this.form = this.element.closest("form")
    if (this.form) {
      this.form.addEventListener("submit", this.boundSubmit)
    }
  }

  disconnect() {
    this.inputTarget?.removeEventListener("blur", this.boundValidate)
    if (this.kindValue === "url") {
      this.inputTarget?.removeEventListener("focus", this.boundPrepareUrlEdit)
    }
    this.form?.removeEventListener("submit", this.boundSubmit)
  }

  prepareUrlEdit() {
    if (!this.hasHiddenTarget) return

    const full = this.hiddenTarget.value.trim()
    if (!full) return

    const { scheme, body } = this.parseUrlInput(full)
    this.updatePrefix(scheme)
    this.inputTarget.value = body
  }

  onFormSubmit(event) {
    const valid = this.kindValue === "url" ? this.validateUrl() : this.validateEmail()
    if (!valid) {
      event.preventDefault()
      event.stopImmediatePropagation()
      this.inputTarget.focus()
    }
  }

  validate() {
    if (this.kindValue === "url") {
      this.validateUrl()
    } else {
      this.validateEmail()
    }
  }

  validateEmail() {
    const value = this.inputTarget.value.trim()

    if (!value) {
      if (this.requiredValue) {
        this.showError()
        return false
      }
      this.clearError()
      return true
    }

    if (!EMAIL_PATTERN.test(value)) {
      this.showError()
      return false
    }

    this.clearError()
    return true
  }

  validateUrl() {
    const raw = this.inputTarget.value.trim()

    if (!raw) {
      if (this.hasHiddenTarget) {
        this.hiddenTarget.value = ""
      }
      if (this.requiredValue) {
        this.showError()
        return false
      }
      this.clearError()
      return true
    }

    const { scheme, body } = this.parseUrlInput(raw)

    if (!body.trim()) {
      this.rejectUrl()
      return false
    }

    const normalized = `${scheme}://${body}`

    if (!this.isAllowedScheme(scheme) || !this.isValidUrl(normalized)) {
      this.rejectUrl()
      return false
    }

    this.updatePrefix(scheme)
    if (this.hasHiddenTarget) {
      this.hiddenTarget.value = normalized
    }
    this.inputTarget.value = body
    this.clearError()
    return true
  }

  rejectUrl() {
    if (this.hasHiddenTarget) {
      this.hiddenTarget.value = ""
    }
    this.showError()
  }

  parseUrlInput(raw) {
    const match = raw.match(SCHEME_PATTERN)
    if (match) {
      const scheme = match[1].toLowerCase()
      const body = raw.slice(match[0].length)
      return { scheme, body }
    }

    return { scheme: this.defaultSchemeValue, body: raw }
  }

  isAllowedScheme(scheme) {
    return this.allowedSchemesValue.includes(scheme.toLowerCase())
  }

  isValidUrl(value) {
    try {
      const url = new URL(value)
      return this.isValidHostname(url.hostname)
    } catch (_error) {
      return false
    }
  }

  isValidHostname(hostname) {
    if (!hostname) return false

    const host = hostname.toLowerCase()

    if (LOCALHOST_PATTERN.test(host)) return true
    if (host.startsWith("[") && host.endsWith("]")) return true
    if (this.isValidIPv4(host)) return true

    if (!host.includes(".")) return false
    if (host.startsWith(".") || host.endsWith(".")) return false
    if (host.includes("..")) return false

    return DOMAIN_HOST_PATTERN.test(host)
  }

  isValidIPv4(host) {
    const parts = host.split(".")
    if (parts.length !== 4) return false

    return parts.every((part) => {
      if (!/^\d{1,3}$/.test(part)) return false
      const value = Number(part)
      return value >= 0 && value <= 255
    })
  }

  updatePrefix(scheme) {
    if (!this.hasPrefixTarget) return

    this.prefixTarget.textContent = `${scheme}://`
  }

  showError() {
    this.inputTarget.classList.add("is-invalid")
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.textContent = this.invalidMessageValue
      this.feedbackTarget.hidden = false
    }
  }

  clearError() {
    this.inputTarget.classList.remove("is-invalid")
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.textContent = ""
      this.feedbackTarget.hidden = true
    }
  }
}
