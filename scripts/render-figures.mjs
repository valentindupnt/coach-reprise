// Planche de contrôle des schémas (src/components/Figure.tsx), en SVG, pour la relecture.
//   node scripts/render-figures.mjs                    -> content/v5/schemas-etirements.svg (postures des sets guidés)
//   node scripts/render-figures.mjs id1 id2 ... sortie.svg
// Les silhouettes sont lues directement dans Figure.tsx : la planche montre exactement ce que l'app affichera.
import { readFileSync, writeFileSync } from 'node:fs';

const root = new URL('..', import.meta.url).pathname;
const src = readFileSync(`${root}src/components/Figure.tsx`, 'utf8');
const code = src.slice(src.indexOf('const C = {'), src.indexOf('function render('))
  .replace(/type Shape =[\s\S]*?\n\n/, '')
  .replace(/: keyof typeof C/g, '').replace(/: Shape\[\]/g, '').replace(/: Shape/g, '')
  .replace(/const POSES: Record<string, Shape\[\]> =/, 'const POSES =')
  .replace(/: number/g, '').replace(/: string/g, '');
const { C, POSES } = new Function(`${code}\nreturn { C, POSES };`)();

const args = process.argv.slice(2);
let out = `${root}content/v5/schemas-etirements.svg`;
let ids = args.filter((a) => !a.endsWith('.svg'));
if (args.some((a) => a.endsWith('.svg'))) out = args.find((a) => a.endsWith('.svg'));
let titles = {};
if (!ids.length) {
  const { SETS } = await import('../content/v5/etirements.mjs');
  ids = [...new Set(SETS.flatMap((s) => s.main.map((m) => m.split(/[@=*]/)[0])))];
  for (const s of SETS) for (const m of s.main) (titles[m.split(/[@=*]/)[0]] ??= []).push(s.title);
}
const esc = (t) => t.replace(/&/g, '&amp;').replace(/</g, '&lt;');
const shape = (s) => {
  const stroke = (c, w, dash) => `stroke="${C[c ?? 'body']}" stroke-width="${w ?? 11}" stroke-linecap="round"${dash ? ' stroke-dasharray="6 6"' : ''}`;
  switch (s.t) {
    case 'l': return `<line x1="${s.p[0]}" y1="${s.p[1]}" x2="${s.p[2]}" y2="${s.p[3]}" ${stroke(s.c, s.w, s.dash)}/>`;
    case 'h': return `<circle cx="${s.p[0]}" cy="${s.p[1]}" r="${s.r ?? 12}" fill="${C.head}"/>`;
    case 'a': return `<path d="${s.d}" fill="none" stroke="${C.arrow}" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>`;
    case 'r': return `<rect x="${s.p[0]}" y="${s.p[1]}" width="${s.p[2]}" height="${s.p[3]}" rx="${s.rx ?? 4}" fill="${C[s.c ?? 'prop']}"/>`;
    case 'p': return `<path d="${s.d}" fill="none" ${stroke(s.c, s.w, s.dash)}/>`;
  }
};
const W = 320, H = 170, cols = 3, gap = 14, lab = 34;
const rows = Math.ceil(ids.length / cols);
const cells = ids.map((id, i) => {
  const x = (i % cols) * (W + gap), y = Math.floor(i / cols) * (H + lab + gap);
  const body = POSES[id]
    ? POSES[id].map(shape).join('')
    : `<text x="20" y="90" font-size="14" fill="#b00">pas de schéma</text>`;
  const sub = titles[id] ? `<text x="8" y="${H + 30}" font-size="10" fill="#777">${esc([...new Set(titles[id])].join(' · '))}</text>` : '';
  return `<g transform="translate(${x},${y})"><rect width="${W}" height="${H}" rx="10" fill="#FBF7F0"/>`
    + `<line x1="6" y1="154" x2="314" y2="154" stroke="${C.floor}" stroke-width="3" stroke-linecap="round"/>${body}`
    + `<text x="8" y="${H + 15}" font-size="13" fill="#333">${esc(id)}</text>${sub}</g>`;
});
const w = cols * (W + gap), h = rows * (H + lab + gap);
writeFileSync(out, `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}" font-family="sans-serif">`
  + `<rect width="100%" height="100%" fill="#fff"/>${cells.join('')}</svg>\n`);
console.log(`${out} : ${ids.length} schémas`);
