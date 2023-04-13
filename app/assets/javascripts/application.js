const descriptionRequestBtn = document.getElementById('description-request-btn');
const errorField = document.getElementById('error-field');
const branchField = document.getElementById('branch-field');
const typeField = document.getElementById('type-field');

async function fetchPrDescription() {
  const response = await fetch('/pull_request_ai/prepare', {
    method: 'post',
    body: JSON.stringify({ branch: branchField.value, type: typeField.value }),
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    },
    credentials: 'same-origin'
  });

  if (!response.ok && response.status != 422) {
    throw new Error(`An error has occured: ${response.statusText}`);
  }

  return await response.json();
}

descriptionRequestBtn.onclick = () => {
  fetchPrDescription().then(data => {
    if ('errors' in data) {
      errorField.textContent += data.errors;
    }
    else {
      console.log('deu')
    }
  }).catch(error => {
    errorField.textContent += error;
  });
}



// fetch('/pull_request_ai/prepare', {
//   method: 'post',
//   body: JSON.stringify({first_name: "Ricky", last_name: "Bobby"}),
//   headers: {
//     'Content-Type': 'application/json',
//     'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
//   },
//   credentials: 'same-origin'
// }).then(function(response) {
//   if(!response.ok) {
//     throw new Error("not ok");
//   }

//   return response.json();
// }).then(function(data) {
//   console.log(data);
// }).catch(error => {
//   debugger;
//   console.log(error)
// });