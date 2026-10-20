import { useMemo, useState } from 'react';
import LibraryBrowser from '../components/LibraryBrowser';
import { BLOCK_LABEL, BLOCK_ORDER, SESSION_META } from '../lib/plan';
import type { Block, ProgramSessionKey } from '../lib/types';
import {
  addExercise,
  moveExercise,
  removeExercise,
  setLevel,
  setSets,
  swapExercise,
  type CoachAthlete,
  type CoachExercise,
  type CoachProgramItem,
} from './api';

const FEELING_LABEL: Record<string, string> = { facile: 'trop facile', bien: 'bien', dur: 'dur', douleur: 'douleur' };

type Picker = { mode: 'swap'; session: ProgramSessionKey; from: CoachProgramItem } | { mode: 'add'; session: ProgramSessionKey };

interface Props {
  athlete: CoachAthlete;
  program: CoachProgramItem[] | null;
  library: CoachExercise[];
  lastFeeling: Map<string, string>;
  reason: string;
  setReason: (r: string) => void;
  busy: string | null;
  act: (key: string, fn: () => Promise<void>) => Promise<void>;
}

export default function ProgramEditor({ athlete, program, library, lastFeeling, reason, setReason, busy, act }: Props) {
  const [picker, setPicker] = useState<Picker | null>(null);
  const [addBlock, setAddBlock] = useState<Block>('main');

  const bySession = useMemo(() => {
    const m: Record<ProgramSessionKey, CoachProgramItem[]> = { A: [], B: [], M: [] };
    for (const p of program ?? []) m[p.session_key]?.push(p);
    for (const k of Object.keys(m) as ProgramSessionKey[]) {
      m[k].sort((a, b) => BLOCK_ORDER[a.block] - BLOCK_ORDER[b.block] || a.position - b.position);
    }
    return m;
  }, [program]);

  const reasonOrNull = () => reason.trim() || null;

  function renderPicker(session: ProgramSessionKey) {
    if (!picker || picker.session !== session) return null;
    const inSession = new Set(bySession[session].map((p) => p.exercise_id));
    const pool = library.filter(
      (e) => e.approved && !inSession.has(e.id) && (picker.mode === 'add' || e.kind === picker.from.exercises?.kind),
    );
    return (
      <div className="card amber" role="dialog" aria-label={picker.mode === 'swap' ? 'Remplacer un exercice' : 'Ajouter un exercice'}>
        <div className="row between wrap">
          <h3>
            {picker.mode === 'swap'
              ? `Remplacer « ${picker.from.exercises?.name ?? picker.from.exercise_id} »`
              : `Ajouter à ${SESSION_META[session].title}`}
          </h3>
          <button className="btn ghost" onClick={() => setPicker(null)}>Fermer</button>
        </div>
        {picker.mode === 'swap' && (
          <p className="small">Seuls les exercices validés du même type sont proposés. Le niveau repart de celui déjà atteint ailleurs, sinon du niveau 1.</p>
        )}
        {picker.mode === 'add' && (
          <label className="field" style={{ maxWidth: 260 }}>
            Dans quelle partie ?
            <select className="input" value={addBlock} onChange={(e) => setAddBlock(e.target.value as Block)}>
              {session === 'M' ? (
                <option value="main">Séance</option>
              ) : (
                (['warmup', 'main', 'cooldown'] as Block[]).map((b) => (
                  <option key={b} value={b}>{BLOCK_LABEL[b]}</option>
                ))
              )}
            </select>
          </label>
        )}
        <LibraryBrowser
          exercises={pool}
          empty="Aucun exercice validé disponible. Valide-en dans la bibliothèque."
          actions={(e) => (
            <button
              className="btn small"
              style={{ alignSelf: 'flex-start' }}
              disabled={busy !== null}
              onClick={() =>
                void act(`pick-${e.id}`, async () => {
                  if (picker.mode === 'swap') await swapExercise(athlete.id, session, picker.from.exercise_id, e.id, reasonOrNull());
                  else await addExercise(athlete.id, session, e.id, session === 'M' ? 'main' : addBlock);
                  setReason('');
                  setPicker(null);
                })
              }
            >
              {picker.mode === 'swap' ? 'Remplacer par celui-ci' : 'Ajouter'}
            </button>
          )}
        />
      </div>
    );
  }

  return (
    <div className="card">
      <div className="row between wrap">
        <h3>Programme de {athlete.first_name}</h3>
        <label className="field" style={{ minWidth: 240, flex: 1, maxWidth: 420 }}>
          <span className="tiny muted">Raison du prochain changement (facultatif)</span>
          <input className="input" maxLength={300} value={reason} onChange={(e) => setReason(e.target.value)} placeholder="Ex. : validé avec son kiné" />
        </label>
      </div>
      {!program && <div className="spinner" aria-label="Chargement" />}

      <div className="coach-grid">
        {(['A', 'B', 'M'] as ProgramSessionKey[]).map((s) => {
          let lastBlock: Block | null = null;
          return (
            <div key={s} className="stack" style={{ gap: 4 }}>
              <div className="row between">
                <div className="eyebrow">{SESSION_META[s].title}</div>
                <button className="btn ghost" style={{ minHeight: 36, padding: '4px 10px' }} onClick={() => { setAddBlock('main'); setPicker({ mode: 'add', session: s }); }}>
                  + Ajouter
                </button>
              </div>
              {bySession[s].map((p, idx) => {
                const max = p.exercises?.levels.length ?? 1;
                const maxSets = p.exercises?.max_sets ?? 3;
                const label = p.exercises?.levels[p.level - 1]?.label ?? '';
                const key = `${s}-${p.exercise_id}`;
                const lf = lastFeeling.get(p.exercise_id);
                const header = p.block !== lastBlock && s !== 'M' ? BLOCK_LABEL[p.block] : null;
                lastBlock = p.block;
                const prev = bySession[s][idx - 1];
                const next = bySession[s][idx + 1];
                return (
                  <div key={key}>
                    {header && <div className="tiny muted" style={{ marginTop: 8, fontWeight: 700 }}>{header}</div>}
                    <div className="list-row" style={{ alignItems: 'flex-start' }}>
                      <div className="grow">
                        <div style={{ fontWeight: 700, fontSize: 15 }}>{p.exercises?.name ?? p.exercise_id}</div>
                        <div className="tiny muted">{label}</div>
                        {lf && <div className="tiny" style={{ color: lf === 'douleur' ? 'var(--clay)' : 'var(--muted)' }}>Dernier ressenti : {FEELING_LABEL[lf]}</div>}
                        <div className="row wrap" style={{ gap: 6, marginTop: 6 }}>
                          <button className="chip" style={{ minHeight: 34 }} aria-pressed={false} onClick={() => setPicker({ mode: 'swap', session: s, from: p })}>
                            Changer
                          </button>
                          <button
                            className="chip"
                            style={{ minHeight: 34 }}
                            aria-pressed={false}
                            aria-label={`Déplacer vers le haut : ${p.exercises?.name}`}
                            disabled={!prev || prev.block !== p.block || busy === key}
                            onClick={() => void act(key, () => moveExercise(athlete.id, s, p.exercise_id, -1))}
                          >
                            ↑
                          </button>
                          <button
                            className="chip"
                            style={{ minHeight: 34 }}
                            aria-pressed={false}
                            aria-label={`Déplacer vers le bas : ${p.exercises?.name}`}
                            disabled={!next || next.block !== p.block || busy === key}
                            onClick={() => void act(key, () => moveExercise(athlete.id, s, p.exercise_id, 1))}
                          >
                            ↓
                          </button>
                          <button
                            className="chip"
                            style={{ minHeight: 34 }}
                            aria-pressed={false}
                            aria-label={`Retirer ${p.exercises?.name}`}
                            disabled={busy === key}
                            onClick={() => void act(key, () => removeExercise(athlete.id, s, p.exercise_id))}
                          >
                            Retirer
                          </button>
                        </div>
                      </div>
                      <div className="stack" style={{ gap: 6, alignItems: 'flex-end' }}>
                        <div className="stepper" title="Niveau">
                          <button
                            aria-label={`Baisser ${p.exercises?.name}`}
                            disabled={p.level <= 1 || busy === key}
                            onClick={() => void act(key, async () => {
                              await setLevel(athlete.id, p.exercise_id, p.level - 1, reasonOrNull());
                              setReason('');
                            })}
                          >
                            −
                          </button>
                          <output aria-live="polite">{p.level}/{max}</output>
                          <button
                            aria-label={`Monter ${p.exercises?.name}`}
                            disabled={p.level >= max || busy === key || athlete.frozen}
                            onClick={() => void act(key, async () => {
                              await setLevel(athlete.id, p.exercise_id, p.level + 1, reasonOrNull());
                              setReason('');
                            })}
                          >
                            +
                          </button>
                        </div>
                        {p.block === 'main' && s !== 'M' && (
                          <label className="tiny muted" style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                            Tours
                            <select
                              aria-label={`Nombre de tours pour ${p.exercises?.name}`}
                              className="input"
                              style={{ minHeight: 36, width: 'auto', padding: '2px 8px', fontSize: 14 }}
                              value={p.sets ?? ''}
                              disabled={busy === key}
                              onChange={(e) => void act(key, () => setSets(athlete.id, s, p.exercise_id, e.target.value === '' ? null : Number(e.target.value)))}
                            >
                              <option value="">Auto</option>
                              {Array.from({ length: maxSets }, (_, i) => i + 1).map((n) => (
                                <option key={n} value={n}>{n}</option>
                              ))}
                            </select>
                          </label>
                        )}
                      </div>
                    </div>
                  </div>
                );
              })}
              {renderPicker(s)}
            </div>
          );
        })}
      </div>
    </div>
  );
}
