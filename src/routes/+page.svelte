<script lang="ts">
    import Box from './Box.svelte';
    import { onMount } from 'svelte';
    import { fonts, renderLine } from './font/index';
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

    let running = true

    let started = false
    let debug = false
    async function animateStart() {
        if (!debug) await document.documentElement.requestFullscreen()
        document.addEventListener("fullscreenchange", () => {window.close()});

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

        let newBoxes = boxes.map((_, i) => {
            let x = (i % res[0])
            let y = Math.floor(i / res[0])

            let xRel = x / res[0]

            let vRel = 1 - Math.abs(xRel - 0.30) - 0.25
            let v = Math.floor(vRel * res[0])

            let line = renderLine("CHECKBOXES", fonts.sevenPlus)

            let lineBox = line[Math.floor((y - v) / 4)]?.[Math.floor((x - 5) / 2)]

            return  (lineBox ? 255 : 0)
        })

        for (let idx = 0; idx < targetRes[0]; idx++) {
            for (let idy = 0; idy < targetRes[1]; idy++) {
                let n = idx + idy * targetRes[0]

                boxes[n] = newBoxes[n]
            }
            if ((idx - 4) % 12 === 0) await s(0.25)
        }

        await s(3)

        let shader = initShader(canvas, res, shaderSrc)
        let currentTime = 1

        function anim() {
            sendToShader(shader, loc.resolution, ...res)
            sendToShader(shader, loc.boxes, ...res)
            sendToShader(shader, loc.time, currentTime)
            // shader.gl.drawArrays(shader.gl.POINTS, 0, 1)
            renderShader(shader)
            currentTime += 0.01
            let pixels: Uint8Array = getShaderPixels(shader)
            boxes = Array.from(pixels).reverse().filter((_, i) => i % 4 === 1)
            if (running) requestAnimationFrame(anim)
        }

        anim()

    }

    let text = "I agree to the terms and conditions, the privacy policy," +
        " and the cookie policy. I also agree to receive updates from the" +
        " daily newsletter with advertising, and agree to sacrifice my firstborn" +
        " child, and sell my soul to the authors of this demo. I also forfeit all" +
        " of my mortal possessions, and agree to"

    let keyHandler = (e: KeyboardEvent) => {
        if (e.key === "r") {
            location.reload()
        }
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

<label style="
    position: absolute;
    left: 950px;
    width: 700px;
    height: 780px;
    top: 130px;
    font-size: 50px;
    /* gradient */
    background: linear-gradient(180deg, black 0%, black 70%, transparent 95%, transparent 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
" for="checkbox">
    {text}
</label>

<canvas id="canvas" style="opacity: 0" width={res[0]} height={res[1]} bind:this={canvas}></canvas>

<style global>
    body {
        overflow: hidden;
        height: 100%;
        margin: 40px !important;
        background: #fff;
        font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica Neue, Arial, Noto Sans, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", Segoe UI Symbol, "Noto Color Emoji";
    }
</style>

<svelte:window on:keydown={keyHandler}></svelte:window>
