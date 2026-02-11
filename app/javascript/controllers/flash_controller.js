import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => {
      this.dismiss();
    }, 4000);
  }

  dismiss() {
    if (this.timeout) clearTimeout(this.timeout);

    this.element.classList.add("fade-out");

    const removeElement = () => this.element.remove();

    this.element.addEventListener("animationend", removeElement, {
      once: true,
    });
    setTimeout(removeElement, 600);
  }
}
