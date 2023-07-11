
const DEFAULT_API_URL = 'http://localhost:5000';

export function getAPI() {
  let url = localStorage.getItem('base_api_url');
  if (url == null) {
    localStorage.setItem('base_api_url', DEFAULT_API_URL);
    url = DEFAULT_API_URL
  }
 return url;
}
