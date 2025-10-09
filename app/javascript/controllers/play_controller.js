import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	connect() {
		// Select all links with href starting with "#play-"
		const playLinks = this.element.querySelectorAll('a[href^="#play-"]');
		playLinks.forEach((link) => {
			link.addEventListener("click", (event) => {
				// Handle the click event
				event.preventDefault();
				const player = event.target
					.closest("article.post")
					?.querySelector("audio");
				this.seekAndPlay(event.target.href, player);
			});
		});
	}

	stopAll() {
		const allAudio = document.querySelectorAll("audio");
		allAudio.forEach((audio) => {
			audio.pause();
		});
	}

	secondsFromHash(href) {
		const hash = new URL(href).hash;
		const h_m_s = hash.replace("#play-", "").split(":");
		var seconds = 0;
		if (h_m_s.length === 2) {
			seconds = parseInt(h_m_s[0], 10) * 60 + parseInt(h_m_s[1], 10);
		} else if (h_m_s.length === 3) {
			seconds =
				parseInt(h_m_s[0], 10) * 3600 +
				parseInt(h_m_s[1], 10) * 60 +
				parseInt(h_m_s[2], 10);
		}
		return seconds < 8000 ? seconds : -1;
	}

	seekAndPlay(href, player) {
		var current_time = this.secondsFromHash(href);
		if (player && current_time >= 0) {
			this.stopAll();
			player.currentTime = current_time;
			player.play();
			player.oncanplay = (_e) => {
				if (player.currentTime === 0) {
					player.currentTime = current_time;
				}
			};
		}
	}
}
