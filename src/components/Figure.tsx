// Illustrations simples des exercices (silhouettes en traits).
// Volontairement schématiques : elles montrent la position et le sens du
// mouvement, avec des amplitudes modestes adaptées à une reprise.
import type { ReactElement } from 'react';

const C = {
  body: '#7E9A86',
  move: '#E2A793',
  head: '#F1D9D4',
  band: '#A5573F',
  prop: '#E3D8C8',
  floor: '#E3D8C8',
  arrow: '#A5573F',
};

type Shape =
  | { t: 'l'; p: [number, number, number, number]; w?: number; c?: keyof typeof C; dash?: boolean }
  | { t: 'h'; p: [number, number]; r?: number }
  | { t: 'a'; d: string } // flèche (chemin SVG)
  | { t: 'r'; p: [number, number, number, number]; c?: keyof typeof C; rx?: number }
  | { t: 'p'; d: string; w?: number; c?: keyof typeof C; dash?: boolean };

const l = (x1: number, y1: number, x2: number, y2: number, w = 11, c: keyof typeof C = 'body', dash = false): Shape => ({
  t: 'l', p: [x1, y1, x2, y2], w, c, dash,
});
const h = (x: number, y: number, r = 12): Shape => ({ t: 'h', p: [x, y], r });
const a = (d: string): Shape => ({ t: 'a', d });
const r = (x: number, y: number, w: number, hh: number, c: keyof typeof C = 'prop', rx = 4): Shape => ({ t: 'r', p: [x, y, w, hh], c, rx });
const band = (x1: number, y1: number, x2: number, y2: number): Shape => l(x1, y1, x2, y2, 3, 'band', true);
const pth = (d: string, w = 11, c: keyof typeof C = 'body', dash = false): Shape => ({ t: 'p', d, w, c, dash });

const POSES: Record<string, Shape[]> = {
  rowing: [
    l(110, 140, 232, 142, 14), l(110, 140, 110, 84, 16), h(110, 64),
    l(110, 86, 86, 110, 9, 'move'), l(86, 110, 120, 116, 8, 'move'),
    band(120, 116, 234, 138), a('M78 96 l-16 0 m6 -6 l-6 6 l6 6'),
  ],
  pull_apart: [
    h(160, 30), l(160, 46, 160, 106, 16), l(160, 106, 142, 150), l(160, 106, 178, 150),
    l(160, 60, 96, 66, 8, 'move'), l(160, 60, 224, 66, 8, 'move'), band(96, 66, 224, 66),
    a('M84 66 l-16 0 m6 -6 l-6 6 l6 6'), a('M236 66 l16 0 m-6 -6 l6 6 l-6 6'),
  ],
  pallof: [
    r(16, 20, 10, 130), h(170, 30), l(170, 46, 170, 106, 16), l(170, 106, 156, 150), l(170, 106, 184, 150),
    l(170, 60, 228, 64, 8, 'move'), band(26, 62, 228, 64),
    a('M238 64 l18 0 m-6 -6 l6 6 l-6 6'), a('M150 26 q-14 -12 -30 -4 m8 -6 l-8 6 l9 4'),
  ],
  dead_bug: [
    h(34, 128), l(58, 132, 140, 132, 20), l(140, 132, 140, 72, 13), l(140, 72, 196, 72, 11),
    l(140, 132, 246, 118, 12, 'move'), l(66, 126, 66, 64, 9), l(62, 122, 14, 98, 9, 'move'),
    a('M252 100 q14 4 22 16 m-9 -2 l9 2 l-3 -9'),
  ],
  bird_dog: [
    h(60, 92, 11), l(80, 100, 190, 100, 16), l(80, 100, 80, 148, 9), l(190, 100, 190, 148, 12), l(190, 148, 236, 148, 10),
    l(80, 100, 22, 92, 8, 'move'), l(190, 100, 292, 96, 11, 'move'),
    a('M20 76 l-12 0 m5 -5 l-5 5 l5 5'), a('M298 80 l12 0 m-5 -5 l5 5 l-5 5'),
  ],
  planche: [
    h(48, 104, 11), l(70, 112, 182, 126, 16), l(70, 112, 70, 148, 9), l(70, 148, 30, 148, 8),
    l(182, 126, 232, 148, 12), l(232, 148, 284, 140, 10),
    a('M126 86 l0 16 m-6 -6 l6 6 l6 -6'),
  ],
  squat_chaise: [
    r(196, 104, 64, 8), r(250, 50, 8, 100), r(200, 112, 6, 38), r(250, 112, 6, 38),
    h(146, 40), l(150, 56, 190, 100, 16), l(190, 100, 132, 108, 13), l(132, 108, 132, 150, 11),
    l(150, 62, 96, 74, 8), band(122, 104, 142, 104),
    a('M110 34 l0 -16 m-6 6 l6 -6 l6 6'),
  ],
  pont: [
    h(34, 136), l(58, 140, 150, 104, 16, 'move'), l(150, 104, 212, 96, 13), l(212, 96, 222, 148, 11),
    l(64, 140, 120, 144, 8), a('M150 82 l0 -18 m-6 6 l6 -6 l6 6'),
  ],
  marche_laterale: [
    h(160, 30), l(160, 46, 160, 98, 16), l(160, 98, 130, 122, 12), l(130, 122, 118, 150, 10),
    l(160, 98, 192, 122, 12), l(192, 122, 204, 150, 10), l(160, 60, 132, 92, 8), l(160, 60, 188, 92, 8),
    band(134, 116, 188, 116), a('M226 120 l22 0 m-6 -6 l6 6 l-6 6'),
  ],
  ext_hanche: [
    h(60, 92, 11), l(80, 100, 190, 100, 16), l(80, 100, 80, 148, 9), l(190, 100, 190, 148, 12), l(190, 148, 236, 148, 10),
    l(190, 100, 256, 94, 12, 'move'), l(256, 94, 262, 50, 10, 'move'),
    a('M280 70 l0 -18 m-6 6 l6 -6 l6 6'),
  ],
  planche_laterale: [
    h(46, 100, 11), l(70, 112, 170, 120, 16, 'move'), l(170, 120, 244, 148, 12), l(70, 112, 70, 148, 9),
    l(70, 148, 110, 148, 8), l(78, 110, 140, 116, 7),
    a('M170 96 l0 -18 m-6 6 l6 -6 l6 6'),
  ],
  respiration: [
    h(34, 136), l(58, 140, 160, 140, 16), l(160, 140, 210, 104, 13), l(210, 104, 236, 148, 11),
    l(66, 138, 110, 126, 8), pth('M86 112 q14 -12 28 0', 3, 'band'), pth('M80 100 q20 -18 40 0', 3, 'band'),
  ],
  bascule_bassin: [
    h(34, 136), l(58, 140, 160, 140, 16), l(160, 140, 210, 104, 13), l(210, 104, 236, 148, 11),
    l(66, 138, 120, 144, 8), a('M140 118 q14 -14 30 -4 m-8 -6 l8 6 l-9 4'),
  ],
  chat_vache: [
    h(58, 98, 11), pth('M80 100 Q135 66 190 100', 16), pth('M80 100 Q135 122 190 100', 4, 'move', true),
    l(80, 100, 80, 148, 9), l(190, 100, 190, 148, 12), l(190, 148, 236, 148, 10),
    a('M135 50 l0 -14 m-6 6 l6 -6 l6 6'),
  ],
  omoplates: [
    r(180, 100, 60, 8), r(232, 40, 8, 110), r(184, 108, 6, 42),
    h(196, 36), l(198, 54, 200, 104, 16), l(200, 104, 150, 106, 13), l(150, 106, 150, 150, 11),
    l(198, 62, 186, 100, 8, 'move'), a('M214 70 l18 0 m-6 -6 l6 6 l-6 6'),
  ],
  wall_slides: [
    r(60, 6, 200, 8), h(160, 40), l(160, 56, 160, 110, 16), l(160, 110, 142, 150), l(160, 110, 178, 150),
    l(160, 64, 122, 66, 8, 'move'), l(122, 66, 118, 30, 8, 'move'), l(160, 64, 198, 66, 8, 'move'), l(198, 66, 202, 30, 8, 'move'),
    a('M100 40 l0 -18 m-6 6 l6 -6 l6 6'), a('M220 40 l0 -18 m-6 6 l6 -6 l6 6'),
  ],
  ext_thoracique: [
    r(120, 104, 70, 8), r(118, 52, 8, 98), r(182, 112, 6, 38),
    h(118, 32), l(128, 50, 150, 104, 16, 'move'), l(150, 104, 214, 108, 13), l(214, 108, 214, 150, 11),
    l(132, 64, 162, 66, 8), a('M96 50 q-6 -20 12 -30 m-10 0 l10 0 l-2 10'),
  ],
  chin_tuck: [
    h(160, 52, 22), l(160, 76, 160, 140, 18), l(144, 92, 120, 140, 9), l(176, 92, 200, 140, 9),
    a('M222 52 l-26 0 m8 -8 l-8 8 l8 8'),
  ],
  pecs_porte: [
    r(196, 10, 12, 140), h(130, 32), l(132, 48, 140, 108, 16), l(140, 108, 120, 150), l(140, 108, 160, 150),
    l(134, 60, 196, 60, 8, 'move'), l(134, 66, 120, 104, 8), a('M100 74 l18 0 m-6 -6 l6 6 l-6 6'),
  ],
  trapezes: [
    r(110, 112, 100, 8), h(176, 34), l(160, 56, 160, 112, 16), l(160, 62, 134, 104, 8), l(160, 62, 186, 104, 8),
    l(146, 112, 138, 150, 10), l(174, 112, 182, 150, 10), a('M200 20 q16 10 12 28 m-7 -7 l7 7 l6 -8'),
  ],
  enfant: [
    h(98, 140, 11), l(120, 140, 224, 122, 16, 'move'), l(170, 148, 246, 148, 11), l(224, 122, 200, 148, 12),
    l(122, 142, 30, 146, 7), a('M90 112 l-20 0 m6 -6 l-6 6 l6 6'),
  ],
  flechisseurs: [
    r(184, 140, 40, 10, 'prop', 5), h(174, 32), l(174, 48, 170, 104, 16), l(170, 104, 110, 106, 13), l(110, 106, 110, 150, 11),
    l(170, 104, 204, 140, 12, 'move'), l(204, 140, 262, 148, 10), l(174, 60, 150, 96, 8),
    a('M188 86 l18 0 m-6 -6 l6 6 l-6 6'),
  ],
  ischios: [
    h(34, 136), l(58, 140, 160, 140, 16), l(160, 140, 200, 42, 12, 'move'), l(160, 140, 216, 110, 12), l(216, 110, 236, 148, 10),
    l(68, 136, 120, 100, 8), band(120, 100, 202, 38), a('M226 50 q-8 -14 -22 -18 m6 8 l-6 -8 l10 -2'),
  ],
  fessiers_4: [
    h(34, 136), l(58, 140, 160, 140, 16), l(160, 140, 206, 96, 12), l(206, 96, 244, 112, 10),
    l(160, 140, 232, 132, 12, 'move'), l(232, 132, 206, 98, 10, 'move'), l(68, 136, 196, 104, 8),
    a('M244 84 l-16 -12 m8 0 l-8 0 l2 8'),
  ],
  mollets: [
    r(282, 10, 12, 140), h(246, 34), l(240, 50, 190, 104, 16), l(190, 104, 222, 120, 12), l(222, 120, 226, 150, 10),
    l(190, 104, 112, 150, 12, 'move'), l(236, 58, 282, 72, 8), a('M150 112 l-14 10 m2 -9 l-2 9 l9 1'),
  ],
};

function render(s: Shape, i: number): ReactElement {
  switch (s.t) {
    case 'l':
      return (
        <line key={i} x1={s.p[0]} y1={s.p[1]} x2={s.p[2]} y2={s.p[3]} stroke={C[s.c ?? 'body']}
          strokeWidth={s.w ?? 11} strokeLinecap="round" strokeDasharray={s.dash ? '6 6' : undefined} />
      );
    case 'h':
      return <circle key={i} cx={s.p[0]} cy={s.p[1]} r={s.r ?? 12} fill={C.head} />;
    case 'a':
      return <path key={i} d={s.d} fill="none" stroke={C.arrow} strokeWidth={2.5} strokeLinecap="round" strokeLinejoin="round" />;
    case 'r':
      return <rect key={i} x={s.p[0]} y={s.p[1]} width={s.p[2]} height={s.p[3]} rx={s.rx ?? 4} fill={C[s.c ?? 'prop']} />;
    case 'p':
      return (
        <path key={i} d={s.d} fill="none" stroke={C[s.c ?? 'body']} strokeWidth={s.w ?? 11} strokeLinecap="round"
          strokeDasharray={s.dash ? '6 6' : undefined} />
      );
  }
}

export function hasFigure(id: string | null | undefined): boolean {
  return Boolean(id && POSES[id]);
}

export default function Figure({ id, label }: { id: string | null | undefined; label: string }) {
  const shapes = id ? POSES[id] : undefined;
  if (!shapes) return null;
  return (
    <div className="figure-box">
      <svg viewBox="0 0 320 170" role="img" aria-label={`Illustration : ${label}`}>
        <line x1={6} y1={154} x2={314} y2={154} stroke={C.floor} strokeWidth={3} strokeLinecap="round" />
        {shapes.map(render)}
      </svg>
    </div>
  );
}
