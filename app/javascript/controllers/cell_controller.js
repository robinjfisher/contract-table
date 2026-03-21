import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "form", "input"]

  #cancelling = false

  edit() {
    this.#cancelling = false
    this.displayTarget.classList.add("hidden")
    this.formTarget.classList.remove("hidden")
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  submit() {
    if (this.#cancelling) return
    this.formTarget.requestSubmit()
  }

  cancel() {
    this.#cancelling = true
    this.formTarget.classList.add("hidden")
    this.displayTarget.classList.remove("hidden")
  }
}
