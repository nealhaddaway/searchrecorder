// (c) Justin Golden 2019

window.onload = () => {
	const keywords = document.getElementById('keywords');
	const string_name = document.getElementById('string_name');
	const notes = keywords;
	const iconDiv = document.getElementById('iconDiv');
	const theme = document.getElementById('theme');

	notes.onchange = () => {
		if (localStorage) localStorage.setItem('noteData', notes.value);
	};

	const iconNames = [
		'save',
		'help',
		'info',
	];
	const capitalize = (str) =>
		str.substring(0, 1).toUpperCase() + str.substring(1);
	for (iconName of iconNames) {
		const icon = document.createElement('img');
		icon.src = 'img/icon/' + iconName + '.svg';
		icon.className = 'icon';

		const btn = document.createElement('button');
		btn.className = 'icon-btn';
		btn.title = capitalize(iconName);
		btn.id = iconName;

		btn.appendChild(icon);
		iconDiv.appendChild(btn);

		if (iconName === 'spellcheck') {
			iconDiv.appendChild(document.createElement('hr'));
		}
	}

	document.getElementById('save').title = 'Download Notes as Text File';

	document.getElementById('version').innerHTML =
		'Version ' + chrome.runtime.getManifest().version;
	
	document.getElementById('save').onclick = () => {
		notes.focus();
		const file = {
			url:
				'data:application/txt,' +
				encodeURIComponent(notes.value.replace(/\r?\n/g, '\r\n')),
			filename: 'notes.txt',
		};
		chrome.downloads.download(file);
	};

	if (localStorage) {
		// load note
		notes.value = localStorage.getItem('noteData');
		// load night
		if (localStorage.getItem('nightData') === 'true') {
			theme.href = 'css/night.css';
		}
		// load spellcheck
		if (localStorage.getItem('spellcheck') === 'true') {
			notes.spellcheck = true;
			document.getElementById('spellcheck').classList.add('active');
		}
		// load size
		notes.style.width = localStorage.getItem('noteWidth') + 'px';
		notes.style.height = localStorage.getItem('noteHeight') + 'px';
	}

	document.onkeydown = (evt) => {
		if (evt.key === 'n' && notes !== document.activeElement) {
			document.getElementById('night-mode').onclick();
			notes.blur();
		}
		storeSize();
	};

	document.onmouseup = storeSize;

	// Modals
	document.getElementById('keyboard').title = 'Keyboard Shortcuts';
	setupModal('help', 'help-modal');
	setupModal('info', 'info-modal');
	setupModal('keyboard', 'keyboard-modal');
};

function storeSize() {
	if (localStorage) {
		localStorage.setItem('noteWidth', notes.clientWidth);
		localStorage.setItem('noteHeight', notes.clientHeight);
	}
}
