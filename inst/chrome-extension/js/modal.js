function setupModal(btnName, modalName) {
	const modal = document.getElementById(modalName);
	const btn = document.getElementById(btnName);
	const close = modal.querySelector(' .close');

	btn.onclick = () => {
		modal.style.display = 'block';
		close.focus();
	};
	close.onclick = () => {
		modal.style.display = 'none';
	};

	close.tabIndex = 0;

	close.onkeydown = (evt) => {
		if (evt.key == 'Enter') close.onclick();
	};
}
