import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop"]

  connect() {
    this._onKeydown = this._onKeydown.bind(this)
    document.addEventListener("keydown", this._onKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this._onKeydown)
  }

  open() {
    this.backdropTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  close() {
    this.backdropTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  // Close when clicking the backdrop (not the modal card itself)
  backdropClick(event) {
    if (event.target === this.backdropTarget) this.close()
  }

  // Close after a successful Turbo form submission
  submitEnd(event) {
    if (event.detail.success) this.close()
  }

  _onKeydown(event) {
    if (event.key === "Escape") this.close()
  }
}
