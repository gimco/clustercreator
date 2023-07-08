import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import { resolve } from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [svelte()],
  build: {
    rollupOptions: {
      input: {
        new: resolve(__dirname, 'new.html'),
        main: resolve(__dirname, 'index.html')
      }
    }
  }
})




