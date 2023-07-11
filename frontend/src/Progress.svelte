<script>
import Layout from './lib/Layout.svelte'

export let data
let inicio_prev = -1
let inicio = 0
let fin = 0
let tiempo = 0
let contador = 0
let mensaje = ''
let porcentaje = 0
let timer = 0
$: {
	[inicio, fin, tiempo, mensaje] = data
	if (inicio != inicio_prev) {
		inicio_prev = inicio
		porcentaje = inicio
		contador = 0
		clearInterval(timer)
		timer = setInterval(progress, 1000)
	}
}

function progress() {
	if (tiempo == 0 || contador >= tiempo) {
		clearInterval(timer)
		return;
	}

	contador++
	porcentaje = Math.round(inicio + (fin - inicio) * contador / tiempo)
	porcentaje = Math.max(inicio, porcentaje)
	porcentaje = Math.min(fin, porcentaje)
}

</script>

<Layout>
	<span slot="title">Estamos preparando su cluster</span>
	<span slot="subtitle">
		Estamos configurando todo lo necesario para que pueda utilizar su cluster HPC personal. Será sólo unos minutos, le enviaremos un correo cuando esté listo.
	</span>

	<div class="mt-6 sm:mt-12 sm:mx-auto sm:max-w-lg flex flex-col items-center">
	    <!---->
	</div>
	<div class="h-8 w-full bg-gray-200 rounded-full dark:bg-gray-700">
	  <div class="leading-7 h-8 bg-blue-600 font-medium text-blue-100 text-center p-0.5 leading-none rounded-full" style="width: {porcentaje}%"> {porcentaje}%</div>
	</div>
	<p class="w-full mx-auto text-m mt-2 text-gray-500">{mensaje} ...</p>
</Layout>

