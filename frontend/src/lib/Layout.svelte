
<div class="mt-6 sm:text-center">
  <h2 class="text-3xl font-black tracking-tight text-gray-900 sm:text-4xl md:text-5xl md:leading-tight md:max-w-4xl md:mx-auto">
  	<slot name="title" />
  </h2>
  <p class="max-w-2xl mx-auto mt-6 italic text-gray-700 sm:text-lg">
  	<span>
  		<slot name="subtitle" />
  	</span>
  </p>
</div>

<form class="grid gap-2 grid-cols-1 sm:w-full sm:flex sm:items-center sm:flex-wrap mt-6 sm:mt-6 sm:mx-auto sm:max-w-lg">
  <div class="w-full">
		<slot />
	</div>
</form>

