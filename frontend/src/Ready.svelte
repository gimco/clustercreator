<script>
import Layout from './lib/Layout.svelte'

export let url
</script>

<Layout>
	<span slot="title">
		¡Su entorno HPC está listo para usar!
	</span>
	<span slot="subtitle">
		 Nos complace informarte que el entorno HPC está completamente configurado y listo para que lo utilice en sus investigaciones y proyectos científicos.
	</span>

	<div class="my-4 flex items-center justify-center">
    <a href="{url}" target="_blank" class="ui-button ui-button-base ui-button-primary" type="submit">Acceder a Jupyter Notebook</a>
  </div>

	<img src="ready.avif" alt="Científicos pensando">
</Layout>