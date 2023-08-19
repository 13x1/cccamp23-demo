<script lang="ts">
    import Box from './Box.svelte';
    import { fonts, renderLine } from './font/index';
    import { getShaderPixels, initShader, renderShader, type Resolution, sendToShader } from './runner/run_shader';
    import shaderSrc1 from "./shader/hello.glsl?raw"
    import shaderSrc2 from "./shader/texture.glsl?raw"

    let paused = true;



    let targetRes: Resolution = [128, 128]
    let res: Resolution = [1, 1]
    let scale = targetRes[0] / res[0]

    let canvas1: HTMLCanvasElement;
    let canvas2: HTMLCanvasElement;

    let hasTransisioned = false;

    const loc = {
        time: ["u_time", "1f"],
        resolution: ["u_resolution", "2f"],
        boxes: ["u_checkboxes", "2f"]
    } as const

    let boxes: number[] = Array(res[0] * res[1]).fill(0).map(() => 255)

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
    function af() { return new Promise(r => requestAnimationFrame(r)) }

    let running = true

    let line = renderLine("CHECKBOXES - presented by :3 maf1a", fonts.sevenPlus)

    let calls = 0

    let scroller_start = performance.now()
    let scroller_precomputed = Array(line[0].length + targetRes[0]).fill(0).map((_, of) => {
        let res = targetRes;
        of *= 1.5
        return Array(res[0]*res[1]).fill(0).map((_, i) => {
            calls++

            let x = (i % res[0])
            let y = Math.floor(i / res[0])

            let xRel = x / res[0]

            let vRel = 1 - Math.abs(xRel - 0.30) - 0.30

            if (Math.abs(vRel - y / res[1]) > 0.3) return 0

            let v = Math.floor(vRel * res[0])

            let lineBox = line[Math.floor((y - v) / 4)]?.[Math.floor((x - 5 + of) / 2)]

            return (lineBox ? 255 : 0)
        })
    })
    console.log("precomputed", performance.now() - scroller_start)

    let startTime = performance.now()
    let currentTime = performance.now()

    let started = false
    let debug = false
    async function animateStart() {
        if (!debug) {
            await document.documentElement.requestFullscreen();
            await s(2)
            document.addEventListener('fullscreenchange', () => {location.reload();});
        }
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

            let vRel = 1 - Math.abs(xRel - 0.30) - 0.30
            let v = Math.floor(vRel * res[0])

            let line = renderLine("CHECKBOXES", fonts.sevenPlus)

            let lineBox = line[Math.floor((y - v) / 4)]?.[Math.floor((x - 5) / 2)]

            return  (lineBox ? 255 : 0)
        })

        if (!debug) for (let idx = 0; idx < targetRes[0]; idx++) {
            for (let idy = 0; idy < targetRes[1]; idy++) {
                let n = idx + idy * targetRes[0]

                boxes[n] = newBoxes[n]
            }
            if ((idx - 4) % 12 === 0) await s(0.25)
        }

        await s(0.5)

        // for (let of = 0; of < res[0] + line[0].length + 100; of++) {
        //     boxes = boxes.map((_, i) => {
        //         let x = (i % res[0])
        //         let y = Math.floor(i / res[0])
        //
        //         let xRel = x / res[0]
        //
        //         let vRel = 1 - Math.abs(xRel - 0.30) - 0.25
        //
        //         if (Math.abs(vRel - y / res[1]) > 0.3) return 0
        //
        //         let v = Math.floor(vRel * res[0])
        //
        //         let lineBox = line[Math.floor((y - v) / 4)]?.[Math.floor((x - 5 + of) / 2)]
        //
        //         return (lineBox ? 255 : 0)
        //     })
        //
        //     await s(0.02)
        // }

        if (!debug) for (let img of scroller_precomputed) {
            boxes = img
            await af()
        }

        if (!debug) await s(1.5)

        let shader1 = initShader(canvas1, res, shaderSrc1)
        let shader2 = initShader(canvas2, res, shaderSrc2)

        let timeConst = 0.00025

        paused = false
        startTime = performance.now()

        if (!debug) for (let of = 0; of < res[0] * 2; of++) {
            sendToShader(shader1, loc.resolution, ...res)
            sendToShader(shader1, loc.time, (currentTime-startTime) * timeConst)
            renderShader(shader1)
            let pixels: Uint8Array = getShaderPixels(shader1)
            boxes = Array.from(pixels).reverse().filter((_, i) => i % 4 === 1).map((orig, i) => {
                let x = (i % res[0])
                let y = Math.floor(i / res[0])

                let xRel = x / res[0]

                let vRel = 1 - Math.abs(xRel * 1.001 - 0.30) - 0.30

                // trial and success
                if (Math.abs(vRel - y / res[1]) > (of / res[0])) return 0
                if (Math.abs(vRel - y / res[1]) > (of / res[0]) - 0.25) return 255
                return orig
            })

            currentTime = performance.now()
            await af()
        }

        // let slidingBanner = renderLine(" CHECKBOXES ", fonts.sevenPlus)
        // slidingBanner.push(slidingBanner[0].map(() => 0))
        //
        // boxes = boxes.map((orig, i) => {
        //     let x = (i % res[0])
        //     let y = Math.floor(i / res[0])
        //
        //     return slidingBanner[y % slidingBanner.length][x % slidingBanner[0].length] ? 255 : 0
        //
        //     return orig
        // })
        //
        // await s(10000)



        async function anim() {
            sendToShader(shader1, loc.resolution, ...res)
            sendToShader(shader1, loc.time, (currentTime - startTime) * timeConst)
            // shader.gl.drawArrays(shader.gl.POINTS, 0, 1)
            renderShader(shader1)
            currentTime = performance.now()
            let pixels: Uint8Array = getShaderPixels(shader1)
            boxes = Array.from(pixels).reverse().filter((_, i) => i % 4 === 1)

//            if (currentTime - startTime > 24500) {
            if (currentTime - startTime > 16000 && !hasTransisioned) {
                console.log("here")
                hasTransisioned = true
                startTime = performance.now()
                shader1 = shader2
            } else {

            }

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

<canvas id="canvas" style="
    opacity: {debug ? 1 : 0};
    position: absolute;
    left: 0;
    top: 874px;
    transform: rotateY(180deg);
" width={res[0]} height={res[1]} bind:this={canvas1}></canvas>

<canvas id="canvas" style="
    opacity: {debug ? 1 : 0};
    position: absolute;
    left: {res[0] + 10}px;
    top: 874px;
    transform: rotateY(180deg);
" width={res[0]} height={res[1]} bind:this={canvas2}></canvas>

<audio src="/Blackout_BGM.flac" bind:paused />

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
