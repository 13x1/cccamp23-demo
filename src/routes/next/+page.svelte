<script lang="ts">
    import { onMount } from 'svelte';
    import { getShaderPixels, initShader, type Resolution, sendToShader } from '../runner/run_shader';
    import shaderSrc from "../shader/hello.glsl?raw"

    const res: Resolution = [32, 32]

    let canvas: HTMLCanvasElement;

    const loc = {
        time: ["u_time", "1f"],
        resolution: ["u_resolution", "2f"]
    } as const

    let boxes: boolean[] = []

    onMount(() => {
        let shader = initShader(canvas, res, shaderSrc)
        let x = 1
        function anim() {
            sendToShader(shader, loc.resolution, 1, x)
            shader.gl.drawArrays(shader.gl.POINTS, 0, 1)
            x -= 0.01
            if (x < 0.5) x = 1
            let pixels: Uint8Array = getShaderPixels(shader)
            boxes = Array.from(pixels).reverse().filter((_, i) => i % 4 === 1).map(e => e < 50)
            requestAnimationFrame(anim)
        }
        anim()
    })

</script>

<canvas id="canvas" width={res[0]} height={res[1]} bind:this={canvas}></canvas>

<div style="line-height: 80%">
    {#each boxes as box}
        <input type="checkbox" checked={!box}>
    {/each}
</div>
