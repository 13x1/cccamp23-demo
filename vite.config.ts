import { sveltekit } from '@sveltejs/kit/vite';
import autoprefixer from 'autoprefixer';
import { defineConfig } from 'vitest/config';
import tailwindcss from 'tailwindcss';
import glsl from "vite-plugin-glsl"
import { nodePolyfills } from 'vite-plugin-node-polyfills'

export default defineConfig({
    plugins: [
        glsl(),
        sveltekit(),
        nodePolyfills({
            // Whether to polyfill specific globals.
            globals: {
                Buffer: true, // can also be 'build', 'dev', or false
                // global: true,
                process: true,
            },
            // Whether to polyfill `node:` protocol imports.
            protocolImports: true,
        }),
    ],
    test: {
        include: ['./src/**/*.test.ts', './src/tests/unit/**/*.ts'],
        exclude: ['./src/tests/e2e/**/*'],
        benchmark: {
            outputFile: './test-results/vitest-benchmark.json'
        },
        outputFile: './test-results/vitest-report/index.html',
        reporters: ['html', 'default'],
        coverage: {
            reportsDirectory: './test-results/vitest-coverage'
        }
    },
    css: {
        postcss: {
            plugins: [tailwindcss(), autoprefixer()]
        }
    }
});
