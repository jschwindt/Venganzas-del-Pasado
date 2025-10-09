// app/javascript/controllers/player_popup_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static values = {
		width: { type: Number, default: 640 },
		height: { type: Number, default: 160 },
		name: { type: String, default: "vdp-player" },
	};

	open(event) {
		event.preventDefault();

		const url = this.element.href;
		const features = `width=${this.widthValue},height=${this.heightValue},status=0,menubar=0,location=0,toolbar=0,scrollbars=0`;

		const popup = window.open(url, this.nameValue, features);
		if (window.focus && popup) popup.focus();
	}
}
