const COLORIS_SRC = "https://cdn.jsdelivr.net/gh/mdbassit/Coloris@0.24.0/dist/coloris.min.js"

let colorisPromise = null

export default function loadColoris() {
  if (window.Coloris) return Promise.resolve(window.Coloris)

  if (!colorisPromise) {
    colorisPromise = new Promise((resolve, reject) => {
      const script = document.createElement("script")
      script.src = COLORIS_SRC
      script.async = true
      script.onload = () => resolve(window.Coloris)
      script.onerror = () => reject(new Error("Failed to load Coloris"))
      document.head.appendChild(script)
    })
  }

  return colorisPromise
}
