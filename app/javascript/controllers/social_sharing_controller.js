import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static values = {
		title: String,
		url: String,
	};

	static targets = ["facebook", "twitter"];

	connect() {
		// Add click event listeners to the sharing buttons
		this.facebookTarget.addEventListener(
			"click",
			this.shareOnFacebook.bind(this),
		);
		this.twitterTarget.addEventListener(
			"click",
			this.shareOnTwitter.bind(this),
		);
	}

	shareOnFacebook(event) {
		event.preventDefault();

		const shareUrl = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(this.urlValue)}`;

		this.openPopup(shareUrl, "facebook-share", 555, 626);
	}

	shareOnTwitter(event) {
		event.preventDefault();

		const text = encodeURIComponent(this.titleValue);
		const url = encodeURIComponent(this.urlValue);
		const shareUrl = `https://twitter.com/intent/tweet?text=${text}&url=${url}`;

		this.openPopup(shareUrl, "twitter-share", 550, 420);
	}

	openPopup(url, name, width, height) {
		const left = (window.innerWidth - width) / 2;
		const top = (window.innerHeight - height) / 2;

		const popup = window.open(
			url,
			name,
			`width=${width},height=${height},left=${left},top=${top},resizable=yes,scrollbars=yes`,
		);

		if (popup) {
			popup.focus();
		}
	}
}
