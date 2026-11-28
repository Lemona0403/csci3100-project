import { Controller } from "@hotwired/stimulus"

const supportedImageTypes = new Set(["image/jpeg", "image/png", "image/webp"])

export default class extends Controller {
  static targets = ["container", "image"]

  preview(event) {
    this.clearPreview()

    const file = event.currentTarget.files[0]
    if (!file || !supportedImageTypes.has(file.type)) return

    this.previewUrl = URL.createObjectURL(file)
    this.imageTarget.src = this.previewUrl
    this.containerTarget.hidden = false
  }

  disconnect() {
    this.clearPreview()
  }

  clearPreview() {
    if (this.previewUrl) {
      URL.revokeObjectURL(this.previewUrl)
      this.previewUrl = null
    }

    if (this.hasImageTarget) this.imageTarget.removeAttribute("src")
    if (this.hasContainerTarget) this.containerTarget.hidden = true
  }
}
