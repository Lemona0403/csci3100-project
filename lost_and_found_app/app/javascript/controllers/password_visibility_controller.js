import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "button"]

  toggle() {
    const showPassword = this.inputTarget.type === "password"
    this.inputTarget.type = showPassword ? "text" : "password"
    this.buttonTarget.textContent = showPassword ? "Hide password" : "Show password"
    this.buttonTarget.setAttribute("aria-pressed", showPassword)
  }
}
