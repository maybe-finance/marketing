import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["section", "link"];
  static classes = ["active"];

  connect() {
    this.updateActiveLink();
    window.addEventListener("scroll", () => this.updateActiveLink());
  }

  disconnect() {
    window.removeEventListener("scroll", () => this.updateActiveLink());
  }

  updateActiveLink() {
    let currentSectionId = "";

    this.sectionTargets.forEach((section) => {
      const sectionTop = section.offsetTop;
      const sectionHeight = section.clientHeight;

      if (window.scrollY >= sectionTop - sectionHeight / 3) {
        currentSectionId = section.getAttribute("id");
      }
    });

    currentSectionId = currentSectionId || "#";

    this.linkTargets.forEach((link) => {
      link.classList.remove(...this.activeClasses);

      if (link.getAttribute("href").slice(1).includes(currentSectionId)) {
        link.classList.add(...this.activeClasses);
      }
    });
  }
}
