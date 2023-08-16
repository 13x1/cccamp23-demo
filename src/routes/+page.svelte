<script lang="ts">
    import { onMount } from 'svelte';

    import shader from './shader/hello.glsl?raw'

    const size = 512

    let canvas: HTMLCanvasElement

    function renderGl(glslShader: string) {
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
        gl.uniform2f(gl.getUniformLocation(program, 'u_resolution'), 1, 1);


        // render to canvas
        gl.drawArrays(gl.POINTS, 0, 1)


        console.log("log:", gl.getShaderInfoLog(fragmentShader))
    }

    onMount(() => {
        renderGl(shader)
    })
</script>

<canvas bind:this={canvas} width={size} height={size} style="border: 2px solid black">

</canvas>
