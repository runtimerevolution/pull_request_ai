const errorField = document.getElementById('error-field');
const noticeField = document.getElementById('notice-field');
const feedbackField = document.getElementById('feedback-field');

const reloadButton = document.getElementById('reload-btn');
const requestDescriptionButton = document.getElementById('request-description-btn');
const copyChatToClipboardButton = document.getElementById('copy-chat-to-clipboard-btn');
const copyChatToDescriptionButton = document.getElementById('copy-chat-to-description-btn');
const createPullRequestButton = document.getElementById('create-pull-request-btn');
const updatePullRequestButton = document.getElementById('update-pull-request-btn');
const copyDescriptionToClipboardButton = document.getElementById('copy-description-to-clipboard-btn');

const loadingContainer = document.getElementById('loading-container');
const prepareContainer = document.getElementById('prepare-container');
const chatDescriptionContainer = document.getElementById('chat-description-container');
const pullRequestContainer = document.getElementById('pull-request-container');

const branchField = document.getElementById('branch-field');
const typeField = document.getElementById('type-field');
const summaryField = document.getElementById('summary-field');

const chatDescriptionField = document.getElementById('chat-description-field');

const pullRequestNumberField = document.getElementById('pull-request-number-field');
const pullRequestTitleField = document.getElementById('pull-request-title-field');
const pullRequestDescriptionField = document.getElementById('pull-request-description-field');

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

copyChatToClipboardButton.onclick = () => {
  copyToClipboardValueFrom(chatDescriptionField)
  feedbackField.textContent = 'Chat description copied to the Clipboard.';
}

copyDescriptionToClipboardButton.onclick = () => {
  copyToClipboardValueFrom(pullRequestDescriptionField)
  feedbackField.textContent = 'Description copied to the Clipboard.';
}

requestDescriptionButton.onclick = () => {
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

copyChatToDescriptionButton.onclick = () => {
  const chat = chatDescriptionField.value;
  const current = pullRequestDescriptionField.value;
  pullRequestDescriptionField.value = current + "\n\n" + chat;
  feedbackField.textContent = 'Chat description copied to the Pull Request description.';
}

createPullRequestButton.onclick = () => {
  const data = {
    branch: branchField.value, title: pullRequestTitleField.value, description: pullRequestDescriptionField.value
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

updatePullRequestButton.onclick = () => {
  const data = {
    number: pullRequestNumberField.value, branch: branchField.value, title: pullRequestTitleField.value, description: pullRequestDescriptionField.value
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

function copyToClipboardValueFrom(field) {
  if (navigator.clipboard) {
    const text = field.value;
    navigator.clipboard.writeText(text);
  } else {
    field.select();
    document.execCommand("copy");
  }
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
  requestDescriptionButton.setAttribute('disabled', '');
}

function unlockSelectors() {
  branchField.removeAttribute('disabled');
  typeField.removeAttribute('disabled');
  summaryField.removeAttribute('disabled');
  requestDescriptionButton.removeAttribute('disabled');
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
  chatDescriptionField.value = data.description;

  if (data.github_enabled) {
    // With GitHub configured we always show the Pull Request form.
    pullRequestContainer.classList.remove('hide');
    if (data.open_pr) {
      // With a Pull Request open we show the chat description on top with the button to copy to the form.
      chatDescriptionContainer.classList.remove('hide');
      copyChatToDescriptionButton.classList.remove('hide');

      // Update the Pull Request form buttons accordingly.
      createPullRequestButton.classList.add('hide');
      updatePullRequestButton.classList.remove('hide');

      // Fill the form with the existing values.
      pullRequestNumberField.value = data.open_pr.number;
      pullRequestTitleField.value = data.open_pr.title;
      pullRequestDescriptionField.value = data.open_pr.description;
    } 
    else {
      // Without a Pull Request open we don't need to show the chat suggestion text area 
      // because we will use the form already filled with the suggestion.
      chatDescriptionContainer.classList.add('hide');

      // Update the Pull Request form buttons accordingly.
      createPullRequestButton.classList.remove('hide');
      updatePullRequestButton.classList.add('hide');

      // Clear the form and fill the description with the chat suggestion.
      pullRequestNumberField.value = '';
      pullRequestTitleField.value = '';
      pullRequestDescriptionField.value = data.description;
    }
  } 
  else {
    // Without GitHub configured we show the chat description with the copy button.
    pullRequestContainer.classList.add('hide');
    chatDescriptionContainer.classList.remove('hide');
    copyChatToDescriptionButton.classList.add('hide');
  }
}

function disableSubmission() {
  errorField.textContent = '';
  chatDescriptionContainer.classList.add('hide');
  pullRequestContainer.classList.add('hide');
}
