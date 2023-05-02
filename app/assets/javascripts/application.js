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
  copyToClipboardValueFrom(
    chatDescriptionField,
    "Chat description copied to the Clipboard."
  );
}

copyDescriptionToClipboardButton.onclick = () => {
  copyToClipboardValueFrom(
    pullRequestDescriptionField,
    "Description copied to the Clipboard."
  );
}

requestDescriptionButton.onclick = () => {
  const data = { branch: branchField.value, type: typeField.value, summary: summaryField.value };

  lockSelectors();

  jsonPost('/rrtools/pull_request_ai/prepare', data).then(data => {
    hideSpinner();
    unlockSelectors();
    if ('errors' in data) {
      window.showNotification({ message: data.errors, theme: "error" });
    }
    else if ('notice' in data) {
      window.showNotification({ message: data.notice, theme: "warning" });
    }
    else {
      enableSubmission(data);
    }
  }).catch(errorMsg => {
    window.showNotification({ message: errorMsg, theme: "error" });
  });
}

copyChatToDescriptionButton.onclick = () => {
  const chat = chatDescriptionField.value;
  const current = pullRequestDescriptionField.value;
  pullRequestDescriptionField.value = current + "\n\n" + chat;
  window.showNotification({
    message: "Chat description copied to the Pull Request description."
  });
}

createPullRequestButton.onclick = () => {
  const data = {
    branch: branchField.value, title: pullRequestTitleField.value, description: pullRequestDescriptionField.value
  };
  jsonPost('/rrtools/pull_request_ai/create', data).then(data => {
    hideSpinner();
    processData(data, "Pull Request created successfully.");
  }).catch(errorMsg => {
    window.showNotification({ message: errorMsg, theme: "error" });
  });
}

updatePullRequestButton.onclick = () => {
  const data = {
    number: pullRequestNumberField.value, branch: branchField.value, title: pullRequestTitleField.value, description: pullRequestDescriptionField.value
  };
  jsonPost('/rrtools/pull_request_ai/update', data).then(data => {
    hideSpinner();
    processData(data, "Pull Request updated successfully.");
  }).catch(errorMsg => {
    window.showNotification({ message: errorMsg, theme: "error" });
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
  requestDescriptionButton.setAttribute('disabled', '');
}

function unlockSelectors() {
  branchField.removeAttribute('disabled');
  typeField.removeAttribute('disabled');
  summaryField.removeAttribute('disabled');
  requestDescriptionButton.removeAttribute('disabled');
}

function copyToClipboardValueFrom(field, successMessage) {
  if (navigator.clipboard) {
    const text = field.value;
    navigator.clipboard.writeText(text);
  } else {
    field.select();
    document.execCommand("copy");
  }
  window.showNotification({ message: successMessage });
}

function processData(data, successMessage) {
  if ('errors' in data) {
    window.showNotification({ message: data.errors, theme: "error" });
  }
  else if ('notice' in data) {
    window.showNotification({ message: data.notice, theme: "warning" });
  }
  else {
    window.showNotification({ message: successMessage });
  }
}

function enableSubmission(data) {
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
  chatDescriptionContainer.classList.add('hide');
  pullRequestContainer.classList.add('hide');
}
