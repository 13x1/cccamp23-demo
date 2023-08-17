import { sveltekit } from '@sveltejs/kit/vite';
import autoprefixer from 'autoprefixer';
import { defineConfig } from 'vitest/config';
import tailwindcss from 'tailwindcss';

export default defineConfig({
    plugins: [
        sveltekit(),
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
