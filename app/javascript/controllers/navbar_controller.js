import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="navbar"
export default class extends Controller {
	toggle(event) {
		document.querySelector(".navbar-burger").classList.toggle("is-active");
		document
			.getElementById(event.currentTarget.dataset.navbarMenuId)
			.classList.toggle("is-active");
	}
}
