import type { HandleClientError } from '@sveltejs/kit';

// Helpers

const errToStr = (err: unknown) => (err instanceof Error ? err.message : JSON.stringify(err));

// Loading/rendering error handling

export const handleError = (async ({ error }) => {
    console.error(error)
    return {
        message: 'Whoops! Something went wrong: ' + errToStr(error)
    };
}) satisfies HandleClientError;

// Runtime error handling (not SK native)

const handleRuntimeError = (error: unknown) => {
    alert('Whoops! Something went wrong: ' + errToStr(error));
};

// Register runtime error handlers

addEventListener('unhandledrejection', ev => handleRuntimeError(ev.reason));
addEventListener('error', ev => handleRuntimeError(ev.error));
