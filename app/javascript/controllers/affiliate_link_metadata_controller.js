import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["affiliateUrl", "button", "imageUrl", "name", "productUrl", "status"];
  static values = { url: String };

  async load() {
    const url = this.affiliateUrlTarget.value.trim();

    if (!url) {
      this.setStatus("Ingresá una URL de afiliado.", true);
      return;
    }

    this.setLoading(true);
    this.setStatus("Cargando metadata...");

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        },
        body: JSON.stringify({ url }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || "No se pudo cargar la metadata.");
      }

      this.fillTargets(data);
      this.setStatus("Metadata cargada.");
    } catch (error) {
      this.setStatus(error.message, true);
    } finally {
      this.setLoading(false);
    }
  }

  fillTargets(data) {
    this.nameTarget.value = data.name || "";
    this.productUrlTarget.value = data.product_url || "";
    this.imageUrlTarget.value = data.image_url || "";
  }

  setLoading(loading) {
    this.buttonTarget.disabled = loading;
    this.buttonTarget.classList.toggle("is-loading", loading);
  }

  setStatus(message, error = false) {
    this.statusTarget.textContent = message;
    this.statusTarget.classList.toggle("has-text-danger", error);
    this.statusTarget.classList.toggle("has-text-success", !error && message.length > 0);
  }
}
