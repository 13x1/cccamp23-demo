<script lang="ts">
    import { onMount } from 'svelte';
    import * as png from '@stevebel/png/src';

    import shader from './shader/hello.glsl?raw'

    const size = 32

    let url: string | null = null;

    let boxes: Array<boolean> = []

    let canvas: HTMLCanvasElement

    function renderGl(glslShader: string, x: number, y: number) {
        // load vertex shader
        let gl = canvas.getContext("webgl")!

        // vertex shader
        let vertexShader = gl.createShader(gl.VERTEX_SHADER)!
        gl.shaderSource(vertexShader, `
        #version 100
        precision highp float;

        attribute vec2 position;

        void main() {
            gl_Position = vec4(position, 0.0, 1.0);
            gl_PointSize = ${(size).toFixed(1)};
        }
        `)
        gl.compileShader(vertexShader)

        // fragment shader
        let fragmentShader = gl.createShader(gl.FRAGMENT_SHADER)!
        gl.shaderSource(fragmentShader, glslShader)
        gl.compileShader(fragmentShader)

        // link shaders to create our program
        let program = gl.createProgram()!
        gl.attachShader(program, vertexShader)
        gl.attachShader(program, fragmentShader)
        gl.linkProgram(program)
        gl.useProgram(program)

        gl.uniform1f(gl.getUniformLocation(program, 'u_time'), 0.5);
        gl.uniform2f(gl.getUniformLocation(program, 'u_resolution'), x, y);

        // render to canvas
        gl.drawArrays(gl.POINTS, 0, 1)

        console.log(url)
        canvas.toBlob(async b => { try {
            let img = png.decode(await b!.arrayBuffer())
            boxes = img.data.filter((_, i) => i % 4 === 1).map(e => e < 50)
        } catch(e) {
            console.log(e)
        }}, 'image/png')

        console.log("log:", gl.getShaderInfoLog(fragmentShader))
    }

    let x: number = 1;
    let y: number = 1;

    $: loaded && renderGl(shader, x, y)
    let loaded = false;
    onMount(() => loaded = true)


</script>

<canvas bind:this={canvas} width={size} height={size} style="border: 2px solid black">

</canvas>

x <input type="range" min="-2" max="2" step="0.1" bind:value={x}> {x}<br>
y <input type="range" min="-2" max="2" step="0.1" bind:value={y}> {y}
<br>
<div style="transform: rotate(180deg); line-height: 80%">
{#each boxes as box}
    <input type="checkbox" checked={!box}>
{/each}
</div>
