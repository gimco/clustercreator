<script>
import Form from './Form.svelte'
import Progress from './Progress.svelte'
import Error from './Error.svelte'
import Ready from './Ready.svelte'
import { getAPI } from './lib/api'

let url = ''
let state = 'form'
let progressData = [0, 0, 0, 'Inicializando']
let entorno = ''

async function create (event) {
  const {correo, nombre, tipo, nodos} = event.detail
  entorno = nombre
  const request = `/create?env=${entorno}&correo=${correo}&tipo=${tipo}&nodos=${nodos}`
  const response = await fetch(getAPI() + request)
  if (!response.ok) {
    state = 'error'
    return
  }
  const data = await response.json();
  state = 'progress'
  updateStatus()
}

async function updateStatus () {
  try {
    const response = await fetch(getAPI() + `/status?env=${entorno}`)
    if (!response.ok) {
      state = 'error'
      return
    }
    const data = await response.json();
    const {percentage_start, percentage_end, seconds, message} = data
    progressData = [percentage_start, percentage_end, seconds, message]

    if (percentage_start < 100) {
      setTimeout(updateStatus, 2000)
    } else {
      url = data.url
      setTimeout(() => state = 'ready', 2000)
    }
  } catch(error) {
    state = 'error'
  }
}


</script>

{#if state == 'form'}
<Form on:payed={create}/>
{:else if state == 'progress'}
<Progress data={progressData} />
{:else if state == 'ready'}
<Ready url={url}/>
{:else if state == 'error'}
<Error/>
{/if}

