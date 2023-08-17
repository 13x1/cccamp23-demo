<script lang="ts">
    import Box from './Box.svelte';
    import { onMount } from 'svelte';
    import { getShaderPixels, initShader, renderShader, type Resolution, sendToShader } from './runner/run_shader';
    import shaderSrc from "./shader/texture.glsl?raw"

    let targetRes: Resolution = [128, 128]
    let res: Resolution = [1, 1]
    let scale = targetRes[0] / res[0]

    let canvas: HTMLCanvasElement;

    const loc = {
        time: ["u_time", "1f"],
        resolution: ["u_resolution", "2f"],
        boxes: ["u_checkboxes", "2f"]
    } as const

    let boxes: number[] = Array(res[0] * res[1]).fill(0).map(() => 255)

    onMount(() => {
        if (Math.random() > 0) return

    })

    function trans(cb: () => void) {
        // eslint-disable-next-line @typescript-eslint/ban-ts-comment
        // @ts-ignore
        if (document.startViewTransition) {
            // eslint-disable-next-line @typescript-eslint/ban-ts-comment
            // @ts-ignore
            document.startViewTransition(cb)
        } else {
            cb()
        }
    }

    function s(n: number) {
        return new Promise(r => setTimeout(r, n * 1000))
    }
    let started = false
    let debug = false
    async function animateStart() {
        if (started) return
        started = true
        if (!debug) {
            do {
                await s(1)
                scale /= 2;
                await s(1)
                trans(() => {
                    res = [res[0] * 2, res[1] * 2]
                    boxes = Array(res[0] * res[1]).fill(0).map((_, i) => {
                        return (i < res[0] * res[1] / 2) && (i % res[0] < res[0] / 2) ? 0 : 255
                    })
                })
                await s(1)
                trans(() => {
                    boxes = boxes.map(() => 0)
                })
            } while (res[0] < targetRes[0])
        } else {
            scale = 1
            res = [...targetRes]
            boxes = Array(res[0] * res[1]).fill(0).map(() => 0)
        }
        await s(2);

        let newBoxes = boxes.map((orig, i) => {
            let x = (i % res[0]) / res[0]
            let y = Math.floor(i / res[0]) / res[1]

            let v = 1 - Math.abs(x - 0.33) - 0.2

            return Math.abs(v - y) < 0.1 ? 255 : 0
        })

        for (let idx = 0; idx < targetRes[0]; idx++) {
            for (let idy = 0; idy < targetRes[1]; idy++) {
                let n = idx + idy * targetRes[0]

                boxes[n] = newBoxes[n]
            }
            await s(0.005)
        }

        await s(2)

        let shader = initShader(canvas, res, shaderSrc)
        let x = 1

        function anim() {
            sendToShader(shader, loc.resolution, ...res)
            sendToShader(shader, loc.boxes, ...res)
            sendToShader(shader, loc.time, x)
            // shader.gl.drawArrays(shader.gl.POINTS, 0, 1)
            renderShader(shader)
            x += 0.01
            let pixels: Uint8Array = getShaderPixels(shader)
            boxes = Array.from(pixels).reverse().filter((_, i) => i % 4 === 1)
            requestAnimationFrame(anim)
        }

        anim()

    }

</script>

<div style="
">

<div class="inline-grid" style="
    transform-origin: top left;
    transform: scale({scale/2});
    position: absolute;

    {debug ? '' : 'transition: transform 1s;'}

    grid-template-rows: repeat({res[0]}, 1fr);
    grid-template-columns: repeat({res[1]}, 1fr);
" on:click={animateStart} on:keydown={() => void 0}>
    {#each boxes as box}
        <Box value={box}/>
    {/each}
</div>

</div>


<canvas id="canvas" style="opacity: 0" width={res[0]} height={res[1]} bind:this={canvas}></canvas>

<style global>
    html, body, :root {
        overflow: hidden;
        height: 100%;
    }
</style>
