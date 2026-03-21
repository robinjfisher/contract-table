import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "zone"]

  dragover(event) {
    event.preventDefault()
    this.zoneTarget.classList.add("border-blue-400", "bg-blue-50")
  }

  dragleave() {
    this.zoneTarget.classList.remove("border-blue-400", "bg-blue-50")
  }

  drop(event) {
    event.preventDefault()
    this.zoneTarget.classList.remove("border-blue-400", "bg-blue-50")

    const dt = new DataTransfer()
    Array.from(event.dataTransfer.files).forEach(file => dt.items.add(file))
    this.inputTarget.files = dt.files

    this.element.requestSubmit()
  }

  change() {
    this.element.requestSubmit()
  }
}
