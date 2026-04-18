import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {
    this.debouncedSubmit = this.#debounce(this.#submit.bind(this), 300)
  }

  #submit() {
    this.element.requestSubmit()
  }

  #debounce(fn, delay) {
    let timer
    return (...args) => {
      clearTimeout(timer)
      timer = setTimeout(() => fn(...args), delay)
    }
  }
}
