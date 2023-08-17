<script lang="ts">
    import Box from './Box.svelte';
    import { onMount } from 'svelte';
    import { getShaderPixels, initShader, renderShader, type Resolution, sendToShader } from '../runner/run_shader';
    import shaderSrc from "../shader/texture.glsl?raw"

    const res: Resolution = [128, 128]

    let canvas: HTMLCanvasElement;

    const loc = {
        time: ["u_time", "1f"],
        resolution: ["u_resolution", "2f"],
        boxes: ["u_checkboxes", "2f"]
    } as const

    let boxes: number[] = []

    onMount(() => {
        let shader = initShader(canvas, res, shaderSrc)
        let x = 1
        function anim() {
            sendToShader(shader, loc.resolution, ...res)
            sendToShader(shader, loc.boxes, ...res)
            sendToShader(shader, loc.time, x)
            // shader.gl.drawArrays(shader.gl.POINTS, 0, 1)
            renderShader(shader)
            x -= 0.01
            if (x < 0.5) x = 1
            let pixels: Uint8Array = getShaderPixels(shader)
            boxes = Array.from(pixels).reverse().filter((_, i) => i % 4 === 1)
            requestAnimationFrame(anim)
        }
        anim()
    })

</script>

<canvas id="canvas" width={res[0]} height={res[1]} bind:this={canvas}></canvas>

<div class="inline-grid" style="
    grid-template-rows: repeat({res[0]}, 1fr);
    grid-template-columns: repeat({res[1]}, 1fr);
">
    {#each boxes as box}
        <Box value={box} />
    {/each}
</div>
