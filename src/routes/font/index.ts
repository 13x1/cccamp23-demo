export type Pixel = number;
export type Color = [number, number, number, number?];

export interface Glyph {
    offset: number;
    pixels: Array<Pixel[]>;
}

export interface Font {
    name: string;
    lineHeight: number;
    description: string;
    isFixedWidth: boolean;
    glyphs: {
        [key: string]: Glyph
    };
}

export interface RenderOptions {
    foreground: Color;
    background: Color;
    scale?: number;
}

import sevenPlus from './seven-plus.json?raw';

export const fonts = {
    sevenPlus: JSON.parse(sevenPlus) as Font,
};

const gap = [[0]];

const areTouching = (first: Pixel[][], second: Pixel[][]) => {
    for (let i = 0; i < first.length; ++i) {
        if (first[i] && first[i][first[i].length - 1] === 1) {
            for (let j = -1; j <= 1; ++j) {
                if (second[i + j] && second[i + j][0] === 1) {
                    return true;
                }
            }
        }
    }
}

export const renderLine = (text: string, font: Font): number[][] => {
    const letters = text.split("");
    const characters = [];
    let maxHeight = 0;
    for (const letter of letters) {
        let glyph = font.glyphs[""];
        if (font.glyphs[letter]) {
            glyph = font.glyphs[letter]
        } else {
            console.log(`Missing letter ${letter}`)
        }
        const newCharacter: Pixel[][] = [];
        glyph.pixels.forEach((row, index) => {
            newCharacter[index + glyph.offset] = row;
        });
        maxHeight = Math.max(maxHeight, newCharacter.length);
        if (font.isFixedWidth ||
            (characters.length && areTouching(characters[characters.length - 1], newCharacter))) {
            characters.push(gap);
        }
        characters.push(newCharacter);
    }
    return characters.reduce((acc, cur) => {
        const blankRow = Array(cur[cur.length - 1].length).fill(0);
        for (let i = 0; i < maxHeight; ++i) {
            const row = cur[i] || blankRow;
            acc[i].push(...row);
        }
        return acc;
    }, Array(maxHeight).fill(0).map(() => []));
}

export function renderPixels(text: string, font: Font): Array<Pixel[]> {
    const lines = text.split("\n").map(line => [[0]].concat(renderLine(line, font)));
    lines[0].shift();
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    return [].concat(...lines);
}

export default {}

