<script lang="ts">
    import { onMount } from 'svelte';

    export let value = 0;

    let checkbox: HTMLInputElement;

    // let idx = 0
    // let max = 3;

    let run = false;
    onMount(() => {
        run = true
        // function runFrames() {
        //     if (run) {
        //
        //         checkbox.checked = Math.random() < (255 - value) / 255
        //         // checkbox.checked = (idx/max) < (value/255)
        //         // idx = (idx + 1) % max
        //         requestAnimationFrame(runFrames)
        //     }
        // }
        // runFrames()
        return () => {run = false}
    })

    let last = false;

    $: if (run) {
        let res = value < 128
        if (res !== last) {
            checkbox.checked = res
            last = res
        }
    }
</script>

<input type="checkbox" bind:this={checkbox} />
