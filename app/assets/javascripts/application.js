const descriptionRequestButton = document.getElementById('description-request-btn');
const copyPrButton = document.getElementById('copy-suggestion-pr-btn');
const reselectPrButton = document.getElementById('reselect-pr-btn');
const createPrButton = document.getElementById('create-pr-btn');
const updatePrButton = document.getElementById('update-pr-btn');

const loadingContainer = document.getElementById('loading-container');
const openPrNumber = document.getElementById('open_pr_number');

const errorField = document.getElementById('error-field');
const feedbackField = document.getElementById('feedback-field');
const branchField = document.getElementById('branch-field');
const typeField = document.getElementById('type-field');
const prTitleField = document.getElementById('pr-title-field');
const descriptionField = document.getElementById('description-field');
const currentDescriptionField = document.getElementById('current-description-field');

const createPrContainer = document.getElementById('create-pr-container');
const openedPrContainer = document.getElementById('opened-pr-container');

async function jsonPost(path, data) {
  showSpinner();

  const response = await fetch(path, {
    method: 'post',
    body: JSON.stringify(data),
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    },
    credentials: 'same-origin'
  });

  if (!response.ok && response.status != 422) {
    hideSpinner();
    unlockSelectors();
    disableSubmission();
    throw new Error(`An error has occured: ${response.statusText}`);
  }

  return await response.json();
}

reselectPrButton.onclick = () => {
  feedbackField.textContent = '';
  unlockSelectors();
  disableSubmission();
}

descriptionRequestButton.onclick = () => {
  const data = { branch: branchField.value, type: typeField.value };

  lockSelectors();

  jsonPost('/rrtools/pull_request_ai/prepare', data).then(data => {
    hideSpinner();

    if ('errors' in data) {
      errorField.textContent = data.errors;
      unlockSelectors();
    }
    else {
      enableSubmission(data);
    }
  }).catch(errorMsg => {
    errorField.textContent = errorMsg;
  });
}

copyPrButton.onclick = () => {
  const suggestion = descriptionField.value;
  const current = currentDescriptionField.value;
  currentDescriptionField.value = current + "\n\n" + suggestion;
}

createPrButton.onclick = () => {
  const data = {
    branch: branchField.value, description: descriptionField.value, title: prTitleField.value
  };

  jsonPost('/rrtools/pull_request_ai/create', data).then(data => {
    hideSpinner();

    if ('errors' in data) {
      errorField.textContent = data.errors;
    }
    else {
      feedbackField.textContent = 'Pull Request created successfully';
    }
  }).catch(errorMsg => {
    errorField.textContent = errorMsg;
  });
}

updatePrButton.onclick = () => {
  const data = {
    number: openPrNumber.value, branch: branchField.value, description: currentDescriptionField.value, title: prTitleField.value
  };

  jsonPost('/rrtools/pull_request_ai/update', data).then(data => {
    hideSpinner();
    console.log('cenas')
    if ('errors' in data) {
      errorField.textContent = data.errors;
    }
    else {
      feedbackField.textContent = 'Pull Request updated successfully';
    }
  }).catch(errorMsg => {
    errorField.textContent = errorMsg;
  });
}

function showSpinner() {
  loadingContainer.style.display = 'block';
}

function hideSpinner() {
  loadingContainer.style.display = 'none';
}

function lockSelectors() {
  branchField.setAttribute('disabled', '');
  typeField.setAttribute('disabled', '');
}

function unlockSelectors() {
  branchField.removeAttribute('disabled');
  typeField.removeAttribute('disabled');
}

function enableSubmission(data) {
  errorField.textContent = '';
  descriptionField.value = data.description;
  if (data.opened) {
    openPrNumber.value = data.opened.number;
    prTitleField.value = data.opened.title
    currentDescriptionField.value = data.opened.description
    
    openedPrContainer.classList.remove('hide');

    createPrButton.classList.add('hide');
    updatePrButton.classList.remove('hide');
  }
  else {
    openPrNumber.value = '';
    prTitleField.value = ''
    currentDescriptionField.value = ''

    openedPrContainer.classList.add('hide');

    createPrButton.classList.remove('hide');
    updatePrButton.classList.add('hide');
  }
  descriptionRequestButton.classList.add('hide');
  createPrContainer.classList.remove('hide');
}

function disableSubmission() {
  errorField.textContent = '';
  descriptionRequestButton.classList.remove('hide');
  createPrContainer.classList.add('hide');
  openedPrContainer.classList.add('hide');
}