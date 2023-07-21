import preprocess from 'svelte-preprocess';
import adapter from '@sveltejs/adapter-auto';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';
import type { Config } from '@sveltejs/kit';

/** @type {import('@sveltejs/kit').Config} */
const config: Config = {
    preprocess: [
        vitePreprocess(),
        preprocess({
            postcss: true,
            sass: false // no clue why, but sass doesn't work otherwise
        })
    ],

    kit: {
        adapter: adapter(),
        env: {
            privatePrefix: 'PRIVATE_',
            publicPrefix: 'PUBLIC_'
        }
    }
};

export default config;
