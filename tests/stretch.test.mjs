// Déroulé d'un set guidé : côtés, transitions, durée totale.
import test from 'node:test';
import assert from 'node:assert/strict';
import { splitSides, buildSegments, totalSeconds } from '../src/lib/stretch.ts';

test('« 20 s par côté » : droit puis gauche', () => {
  assert.deepEqual(splitSides('20 s par côté', 40), [
    { side: 'droit', seconds: 20 }, { side: 'gauche', seconds: 20 },
  ]);
});

test('« 2 × 20 s par côté » : deux tours alternés', () => {
  const r = splitSides('2 × 20 s par côté', 80);
  assert.equal(r.length, 4);
  assert.deepEqual(r.map((x) => x.side), ['droit', 'gauche', 'droit', 'gauche']);
  assert.equal(r.reduce((a, x) => a + x.seconds, 0), 80);
});

test('« par côté » sans durée : le temps est partagé en deux', () => {
  const r = splitSides('8 répétitions par côté', 31);
  assert.equal(r.reduce((a, x) => a + x.seconds, 0), 31);
  assert.deepEqual(r.map((x) => x.side), ['droit', 'gauche']);
});

test('sans « par côté » : un seul bloc', () => {
  assert.deepEqual(splitSides('45 s', 45), [{ side: null, seconds: 45 }]);
});

test('buildSegments : transitions entre postures, durée totale conservée', () => {
  const mk = (id, position, label, value) => ({
    position, level: 1, value,
    exercise: { id, levels: [{ label, seconds: value }], default_value: value },
  });
  const t = { rest_seconds: 5, items: [mk('a', 1, '20 s par côté', 40), mk('b', 2, '30 s', 30)] };
  const s = buildSegments(t);
  assert.deepEqual(s.map((x) => [x.exerciseId, x.side, x.prepare]), [
    ['a', 'droit', false], ['a', 'gauche', false], ['b', null, true], ['b', null, false],
  ]);
  assert.equal(totalSeconds(s), 40 + 5 + 30);
});
