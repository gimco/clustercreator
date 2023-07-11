
const DEFAULT_API_URL = 'http://localhost:5000';

export function getAPI() {
  let url = localStorage.getItem('base_api_url');
  if (url == null) {
    localStorage.setItem('base_api_url', DEFAULT_API_URL);
    url = DEFAULT_API_URL
  }
 return url;
}

window["cambiar_backend"] = function (url) {
  localStorage.setItem('base_api_url', url)
}

console.log('Puedes cambiar la url del backend llamando a la función: cambiar_backend("http://xxxxxxx")')