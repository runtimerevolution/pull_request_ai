(function Notifications(window) {

	const partial = (fn, ...presetArgs) => (...laterArgs) => fn(...presetArgs, ...laterArgs);

	const append = (el, ...children) => children.forEach(child => el.appendChild(child));

	const isString = input => typeof input === 'string';

	const createElement = (elementType, ...classNames) => {
		const element = document.createElement(elementType);
		if(classNames.length) {
			classNames.forEach(currentClass => element.classList.add(currentClass));
		}
		return element;
	};

	const setInnerText = (element, text) => {
		element.innerText = text;
		return element;
	};

	const createTextElement = (elementType, ...classNames) => partial(setInnerText, createElement(elementType, ...classNames));

	const createParagraph = (...classNames) => createTextElement('p', ...classNames);

	const defaultOptions = {
		showDuration: 3000,
		theme: 'success'
	};

	function showNotification(options) {
		if(typeof options.showDuration !== 'number') {
			options.showDuration = defaultOptions.showDuration;
		}
		if(!isString(options.theme) || options.theme.length === 0) {
			options.theme = defaultOptions.theme;
		}
		if(!isString(options.message) || options.message.length === 0) {
			options.message = defaultOptions.theme;
		}

		const container = createNotificationContainer();
		const notificationEl = createElement('div', 'notification', options.theme);
		notificationEl.addEventListener('click', () => container.removeChild(notificationEl));
		
		if(isString(options.title) && options.title.length > 0) {
			append(notificationEl, createParagraph('notification-title')(options.title));
		}
		append(notificationEl, createParagraph('notification-message')(options.message));
		append(container, notificationEl);

		if(options.showDuration && options.showDuration > 0) {
			const timeout = setTimeout(() => {
				container.removeChild(notificationEl);
				if(container.querySelectorAll('.notification').length === 0) {
					document.body.removeChild(container);
				}
			}, options.showDuration);

			notificationEl.addEventListener('click', () => clearTimeout(timeout));
		}
	}

	function createNotificationContainer() {
		let container = document.querySelector(`notification-container`);
		if(!container) {
			container = createElement('div', 'notification-container');
			append(document.body, container);
		}
		return container;
	}

	if (!window.showNotification) {
		window.showNotification = showNotification;
	}
})(window);