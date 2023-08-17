function n<T>(x: T, msg?: string): asserts x is NonNullable<T> {
    if (x === undefined || x === null) throw new Error(msg ?? "Null check failed!");
}
function logIf(msg: string | null | undefined) {
    if (msg && msg.length > 0) console.log("log:\n"+msg)
}

// eslint-disable-next-line
const T = null as any

export type Resolution = [width: number, height: number]

export type UniformTypes = `${1|2|3|4}${'f'|'i'}`

type Skip1<T extends Array<unknown>> = T extends [unknown, ...infer U] ? U : never;

export type UniformTuple<T extends UniformTypes> = Skip1<Parameters<WebGLRenderingContextBase[`uniform${T}`]>>

export function sendToShader<T extends UniformTypes>(
    shader: Shader,
    [name, uniform]: readonly [name: string, uniform: T],
    ...params: UniformTuple<T>)
{
    const loc = shader.cache[name] ??= shader.gl.getUniformLocation(shader.program, name)
    if (!loc) {
        return;
    }
    shader.gl[`uniform${uniform}`](
        loc,
        // eslint-disable-next-line @typescript-eslint/ban-ts-comment
        // @ts-ignore
        ...params
    )
}

export function getShaderPixels(shader: Shader): Uint8Array {
    const pixels = new Uint8Array(
        shader.gl.drawingBufferWidth * shader.gl.drawingBufferHeight * 4,
    );
    shader.gl.readPixels(
        0,
        0,
        shader.gl.drawingBufferWidth,
        shader.gl.drawingBufferHeight,
        shader.gl.RGBA,
        shader.gl.UNSIGNED_BYTE,
        pixels,
    );
    return pixels
}

// const locations = {
//     time: ["u_time", "1f"],
//     resolution: ["u_resolution", "2f"],
// } as const
//
// sendToShader(T, locations.resolution, 1, 1);
// sendToShader(T, locations.time, 1);

export interface Shader {
    cv: HTMLCanvasElement
    gl: WebGLRenderingContext,
    vertexShader: WebGLShader,
    fragmentShader: WebGLShader,
    program: WebGLProgram,
    cache: Record<string, WebGLUniformLocation | null>,
}

export function initShader(cv: HTMLCanvasElement, res: Resolution, glsl: string) {
    const gl = cv.getContext("webgl"); n(gl)

    const vertexShader = gl.createShader(gl.VERTEX_SHADER); n(vertexShader)
    // gl.shaderSource(vertexShader, `
    //     #version 100
    //     precision highp float;
    //
    //     attribute vec2 position;
    //
    //     void main() {
    //         gl_Position = vec4(position, 0.0, 1.0);
    //         gl_PointSize = ${(Math.max(...res)).toFixed(5)};
    //     }
    // `)
    gl.shaderSource(vertexShader, `
    attribute vec4 a_position;

    void main() {
        gl_Position = vec4(a_position.xy, 0.0, 1.0);
    }
    `)
    gl.compileShader(vertexShader)

    logIf(gl.getShaderInfoLog(vertexShader))

    const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER); n(fragmentShader)
    gl.shaderSource(fragmentShader, glsl)
    gl.compileShader(fragmentShader)

    logIf(gl.getShaderInfoLog(fragmentShader))

    const program = gl.createProgram(); n(program)
    gl.attachShader(program, vertexShader)
    gl.attachShader(program, fragmentShader)
    gl.linkProgram(program)
    gl.useProgram(program)

    logIf(gl.getProgramInfoLog(program))

    return { cv, gl, vertexShader, fragmentShader, program, cache: {} } as Shader
}

export function renderShader({gl, program}: Shader) {
    // Specify vertex data and draw
    const vertices = new Float32Array([
        -5.0, -5.0,
        5.0, -5.0,
        0.0, 5.0
    ]);

    const buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);

    const positionAttribLocation = gl.getAttribLocation(program, "a_position");
    gl.enableVertexAttribArray(positionAttribLocation);
    gl.vertexAttribPointer(positionAttribLocation, 2, gl.FLOAT, false, 0, 0);
    gl.drawArrays(gl.TRIANGLES, 0, 3);
}

export default {}
