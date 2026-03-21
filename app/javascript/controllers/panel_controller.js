import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "overlay", "preview", "previewOverlay"]

  // Source panel
  open() {
    this.panelTarget.classList.remove("translate-x-full")
    this.overlayTarget.classList.remove("hidden")
  }

  close() {
    this.panelTarget.classList.add("translate-x-full")
    this.overlayTarget.classList.add("hidden")
  }

  // Preview panel
  openPreview() {
    this.previewTarget.classList.remove("translate-x-full")
    this.previewOverlayTarget.classList.remove("hidden")
  }

  closePreview() {
    this.previewTarget.classList.add("translate-x-full")
    this.previewOverlayTarget.classList.add("hidden")
  }
}
