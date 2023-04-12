async function fetchPrDescription(branch) {
  const response = await fetch('/pull_request_ai/prepare', {
    method: 'post',
    body: JSON.stringify({ branch }),
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    },
    credentials: 'same-origin'
  });

  if (!response.ok) {
    const message = `An error has occured: ${response.status}`;
    throw new Error(message);
  }

  return await response.json();
}

fetchPrDescription('main').then(data => {
  console.log(data);
}).catch(error => {
  console.log(error)
});


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