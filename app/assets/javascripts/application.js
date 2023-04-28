const descriptionRequestButton = document.getElementById('description-request-btn');
const copyPrButton = document.getElementById('copy-suggestion-pr-btn');
const reselectPrButton = document.getElementById('reselect-pr-btn');
const createPrButton = document.getElementById('create-pr-btn');
const clipboardButton = document.getElementById('clipboard-btn');
const updatePrButton = document.getElementById('update-pr-btn');
const reloadButton = document.getElementById('reload-btn');

const loadingContainer = document.getElementById('loading-container');
const openPrNumber = document.getElementById('open_pr_number');

const errorField = document.getElementById('error-field');
const noticeField = document.getElementById('notice-field');
const feedbackField = document.getElementById('feedback-field');
const branchField = document.getElementById('branch-field');
const typeField = document.getElementById('type-field');
const prTitleField = document.getElementById('pr-title-field');
const descriptionField = document.getElementById('description-field');
const summaryField = document.getElementById('summary-field');
const currentDescriptionField = document.getElementById('current-description-field');

const titlePrContainer = document.getElementById('pr-title-container');
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

reloadButton.onclick = () => {
  window.location.reload();
}

reselectPrButton.onclick = () => {
  window.location.reload();
}

clipboardButton.onclick = () => {
  if (navigator.clipboard) {
    var text = descriptionField.value;
    navigator.clipboard.writeText(text);
  } else {
    descriptionField.select();
    document.execCommand("copy");
  }
}

descriptionRequestButton.onclick = () => {
  const data = { branch: branchField.value, type: typeField.value, summary: summaryField.value };

  lockSelectors();

  jsonPost('/rrtools/pull_request_ai/prepare', data).then(data => {
    hideSpinner();
    unlockSelectors();
    if (setErrorsOrNoticeIfNeeded(data) == false) {
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
    if (setErrorsOrNoticeIfNeeded(data) == false) {
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
    if (setErrorsOrNoticeIfNeeded(data) == false) {
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
  summaryField.setAttribute('disabled', '');
}

function unlockSelectors() {
  branchField.removeAttribute('disabled');
  typeField.removeAttribute('disabled');
  summaryField.removeAttribute('disabled');
}

function clearErrorsAndNoticeIfNeeded() {
  errorField.textContent = '';
  noticeField.textContent = '';
}

function setErrorsOrNoticeIfNeeded(data) {
  clearErrorsAndNoticeIfNeeded();
  if ('errors' in data) {
    errorField.textContent = data.errors;
    return true;
  }
  else if ('notice' in data) {
    noticeField.textContent = data.notice;
    return true;
  }
  return false;
}

function enableSubmission(data) {
  errorField.textContent = '';
  descriptionField.value = data.description;

  titlePrContainer.classList.add('hide');
  createPrButton.classList.add('hide');
  updatePrButton.classList.add('hide');

  if (data.open_pr) {
    openPrNumber.value = data.open_pr.number;
    prTitleField.value = data.open_pr.title
    currentDescriptionField.value = data.open_pr.description
    
    openedPrContainer.classList.remove('hide');

    if (data.github_enabled) {
      updatePrButton.classList.remove('hide');  
      titlePrContainer.classList.remove('hide');  
    }
  }
  else {
    openPrNumber.value = '';
    prTitleField.value = ''
    currentDescriptionField.value = ''

    openedPrContainer.classList.add('hide');

    if (data.github_enabled) {
      createPrButton.classList.remove('hide');
      titlePrContainer.classList.remove('hide');  
    }
  }
  createPrContainer.classList.remove('hide');
}

function disableSubmission() {
  errorField.textContent = '';
  createPrContainer.classList.add('hide');
  openedPrContainer.classList.add('hide');
}