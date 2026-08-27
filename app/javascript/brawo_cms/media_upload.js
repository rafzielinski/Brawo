export function readCsrfToken() {
  const meta = document.querySelector("meta[name='csrf-token']")
  return meta?.getAttribute("content") || ""
}

export function fileMatchesAccept(file, accept) {
  if (!accept || accept === "*/*") return true

  const patterns = accept.split(",").map((part) => part.trim()).filter(Boolean)
  return patterns.some((pattern) => {
    if (pattern.endsWith("/*")) {
      return file.type.startsWith(pattern.slice(0, -1))
    }

    return file.type === pattern
  })
}

export async function uploadMediaFile(file, options) {
  const { mediaIndexUrl, accept } = options

  if (!fileMatchesAccept(file, accept)) {
    throw new Error("invalid_type")
  }

  const formData = new FormData()
  formData.append("media[file]", file)
  formData.append("media[title]", file.name)

  const response = await fetch(mediaIndexUrl, {
    method: "POST",
    headers: {
      Accept: "application/json"
    },
    credentials: "same-origin",
    body: formData
  })

  if (!response.ok) {
    const data = await response.json().catch(() => ({}))
    const message = formatErrors(data.errors) || "Upload failed"
    throw new Error(message)
  }

  return response.json()
}

export function formatErrors(errors) {
  if (!errors) return null
  if (Array.isArray(errors)) return errors.join(", ")

  return Object.values(errors)
    .flat()
    .map((value) => (Array.isArray(value) ? value.join(", ") : String(value)))
    .join(", ")
}

export function mediaImageUrl(media, variant = "thumb") {
  if (!media) return null
  if (variant === "original") return media.url
  return media.thumbnail_url || media.url
}

export function mediaPreviewMarkup(media) {
  const src = mediaImageUrl(media, "thumb")
  if (media.content_type?.startsWith("image/") && src) {
    return `<img src="${escapeHtml(src)}" alt="" class="brawo-media-upload__log-thumb">`
  }

  return `<span class="brawo-media-upload__log-icon" aria-hidden="true"><i class="bi bi-file-earmark"></i></span>`
}

export function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;")
}
