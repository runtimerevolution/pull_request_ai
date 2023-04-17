const descriptionRequestButton = document.getElementById('description-request-btn');
const createPrButton = document.getElementById('create-pr-btn');

const loadingContainer = document.getElementById('loading-container');

const errorField = document.getElementById('error-field');
const feedbackField = document.getElementById('feedback-field');
const branchField = document.getElementById('branch-field');
const typeField = document.getElementById('type-field');
const descriptionField = document.getElementById('description-field');
const prTitleField = document.getElementById('pr-title-field');

const createPrContainer = document.getElementById('create-pr-container');

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

    throw new Error(`An error has occured: ${response.statusText}`);
  }

  return await response.json();
}

descriptionRequestButton.onclick = () => {
  const data = { branch: branchField.value, type: typeField.value };

  jsonPost('pull_request_ai/prepare', data).then(data => {
    hideSpinner();

    if ('errors' in data) {
      errorField.textContent = data.errors;
    }
    else {
      errorField.textContent = '';
      descriptionField.value = data.description;

      branchField.setAttribute('disabled', '');
      typeField.setAttribute('disabled', '');
      descriptionRequestButton.classList.add('hide');
      createPrContainer.classList.remove('hide');
    }
  }).catch(errorMsg => {
    errorField.textContent = errorMsg;
  });
}

createPrButton.onclick = () => {
  const data = {
    branch: branchField.value, description: descriptionField.value, title: prTitleField.value
  };

  jsonPost('pull_request_ai/create', data).then(data => {
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

function showSpinner() {
  loadingContainer.style.display = 'block';
}

function hideSpinner() {
  loadingContainer.style.display = 'none';
}
