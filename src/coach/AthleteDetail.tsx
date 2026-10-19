import { useEffect, useMemo, useState } from 'react';
import { readableError } from '../lib/supabase';
import { SESSION_META, localDay, programWeek, phaseForWeek } from '../lib/plan';
import type { ProgramSessionKey } from '../lib/types';
import {
  loadChanges,
  loadProgram,
  loadWorkouts,
  markReviewed,
  rotateToken,
  saveMessage,
  setLevel,
  unfreeze,
  type CoachAthlete,
  type CoachProgramItem,
  type CoachWorkout,
  type LevelChange,
} from './api';

const FEELING_LABEL: Record<string, string> = { facile: 'trop facile', bien: 'bien', dur: 'dur', douleur: 'douleur' };

export function describeWorkout(w: CoachWorkout): string {
  const d = new Date(w.done_at);
  const parts = [
    d.toLocaleDateString('fr-FR', { weekday: 'short', day: 'numeric', month: 'short' }) +
      ' ' + d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }),
    `douleur ${w.pain}/10`,
  ];
  if (w.neuro) parts.push('fourmillements / faiblesse');
  const painful = w.workout_items.filter((i) => i.feeling === 'douleur').length;
  if (painful) parts.push(`${painful} exercice${painful > 1 ? 's' : ''} douloureux`);
  return parts.join(' · ');
}

function Dot({ color }: { color: string }) {
  return <span aria-hidden="true" style={{ display: 'inline-block', width: 10, height: 10, borderRadius: 999, background: color, marginRight: 6 }} />;
}
export { Dot };

interface Props {
  athlete: CoachAthlete;
  refreshKey: number;
  onChanged: () => Promise<void>;
}

export default function AthleteDetail({ athlete, refreshKey, onChanged }: Props) {
  const [program, setProgram] = useState<CoachProgramItem[] | null>(null);
  const [workouts, setWorkouts] = useState<CoachWorkout[]>([]);
  const [changes, setChanges] = useState<LevelChange[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState<string | null>(null);
  const [message, setMessage] = useState(athlete.coach_message ?? '');
  const [savedMsg, setSavedMsg] = useState(false);
  const [reason, setReason] = useState('');
  const [copied, setCopied] = useState(false);
  const [confirmRotate, setConfirmRotate] = useState(false);
  const [confirmUnfreeze, setConfirmUnfreeze] = useState(false);

  useEffect(() => {
    let alive = true;
    Promise.all([loadProgram(athlete.id), loadWorkouts(athlete.id), loadChanges(athlete.id)])
      .then(([p, w, c]) => {
        if (!alive) return;
        setProgram(p);
        setWorkouts(w);
        setChanges(c);
      })
      .catch((e) => alive && setError(readableError(e)));
    return () => {
      alive = false;
    };
  }, [athlete.id, refreshKey]);

  async function act(key: string, fn: () => Promise<void>) {
    setBusy(key);
    setError(null);
    try {
      await fn();
      await onChanged();
    } catch (e) {
      setError(readableError(e));
    } finally {
      setBusy(null);
    }
  }

  const link = `${window.location.origin}/a/${athlete.access_token}`;
  const week = programWeek(athlete.start_date);
  const phase = phaseForWeek(week);

  // Assiduité : 4 dernières semaines, du lundi au dimanche
  const heat = useMemo(() => {
    const byDay = new Map<string, { n: number; alert: boolean }>();
    for (const w of workouts) {
      const k = localDay(new Date(w.done_at));
      const cur = byDay.get(k) ?? { n: 0, alert: false };
      cur.n++;
      cur.alert = cur.alert || w.neuro || w.pain > 3;
      byDay.set(k, cur);
    }
    const now = new Date();
    const monday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    monday.setDate(monday.getDate() - ((monday.getDay() + 6) % 7) - 21);
    const days = Array.from({ length: 28 }, (_, i) => {
      const d = new Date(monday);
      d.setDate(monday.getDate() + i);
      const k = localDay(d);
      return { k, d, future: d > now, ...(byDay.get(k) ?? { n: 0, alert: false }) };
    });
    const thisWeek = days.slice(21).filter((d) => d.n > 0).length;
    return { days, thisWeek };
  }, [workouts]);

  const exName = (id: string) => program?.find((p) => p.exercise_id === id)?.exercises?.name ?? id;

  const bySession = (s: ProgramSessionKey) => (program ?? []).filter((p) => p.session_key === s);

  // Dernier ressenti par exercice
  const lastFeeling = useMemo(() => {
    const m = new Map<string, string>();
    for (const w of workouts) for (const i of w.workout_items) if (!m.has(i.exercise_id)) m.set(i.exercise_id, i.feeling);
    return m;
  }, [workouts]);

  return (
    <section className="stack" style={{ gap: 16 }} aria-labelledby="athlete-title">
      <div className="row between wrap">
        <div>
          <div className="eyebrow">Fiche athlète</div>
          <h2 id="athlete-title" style={{ fontSize: 30, marginTop: 6 }}>{athlete.first_name}</h2>
          <p className="small muted">Semaine {week} · {phase.name} · {phase.rounds} tours</p>
        </div>
        {athlete.frozen ? <span className="pill red">Programme en pause</span> : <span className="pill sage">Actif</span>}
      </div>

      {error && <div className="banner error" role="alert">{error}</div>}

      {athlete.frozen && (
        <div className="card rose">
          <h3>Réactiver le programme</h3>
          <p className="small">À faire seulement après avoir parlé avec {athlete.first_name} et, idéalement, après l'avis de son médecin ou kiné.</p>
          {confirmUnfreeze ? (
            <div className="row wrap">
              <button className="btn small" disabled={busy === 'unfreeze'} onClick={() => void act('unfreeze', () => unfreeze(athlete.id))}>
                Oui, réactiver
              </button>
              <button className="btn secondary small" onClick={() => setConfirmUnfreeze(false)}>Annuler</button>
            </div>
          ) : (
            <button className="btn small" style={{ alignSelf: 'flex-start' }} onClick={() => setConfirmUnfreeze(true)}>Réactiver…</button>
          )}
        </div>
      )}

      <div className="coach-grid">
        <div className="card">
          <h3>Message affiché à {athlete.first_name}</h3>
          <textarea
            className="input"
            maxLength={1000}
            value={message}
            placeholder="Ex. : Super semaine ! On garde le même rythme."
            onChange={(e) => {
              setMessage(e.target.value);
              setSavedMsg(false);
            }}
          />
          <div className="row">
            <button
              className="btn small"
              disabled={busy === 'msg'}
              onClick={() => void act('msg', async () => {
                await saveMessage(athlete.id, message.trim() || null);
                setSavedMsg(true);
              })}
            >
              Enregistrer
            </button>
            {message && (
              <button className="btn ghost" onClick={() => void act('msg', async () => {
                await saveMessage(athlete.id, null);
                setMessage('');
                setSavedMsg(true);
              })}>
                Effacer
              </button>
            )}
            {savedMsg && <span className="small muted" role="status">Enregistré</span>}
          </div>
        </div>

        <div className="card">
          <h3>Régularité (4 semaines)</h3>
          <p className="small muted">{heat.thisWeek} jour{heat.thisWeek > 1 ? 's' : ''} d'entraînement cette semaine</p>
          <div className="heat" role="img" aria-label="Calendrier des séances des 4 dernières semaines">
            {['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((d, i) => (
              <div key={`h${i}`} className="future" style={{ fontWeight: 700 }}>{d}</div>
            ))}
            {heat.days.map((d) => (
              <div key={d.k} className={d.future ? 'future' : d.alert ? 'alert' : d.n ? 'done' : ''} title={d.k}>
                {d.d.getDate()}
              </div>
            ))}
          </div>
          <p className="tiny muted"><Dot color="var(--sage-strong)" />séance <Dot color="var(--clay)" />douleur &gt; 3 ou symptôme</p>
        </div>

        <div className="card">
          <h3>Lien personnel</h3>
          <p className="small muted">À ouvrir sur son iPhone dans Safari, puis Partager → Sur l'écran d'accueil.</p>
          <input className="input" readOnly value={link} onFocus={(e) => e.currentTarget.select()} aria-label="Lien personnel" />
          <div className="row wrap">
            <button
              className="btn small"
              onClick={async () => {
                try {
                  await navigator.clipboard.writeText(link);
                  setCopied(true);
                  setTimeout(() => setCopied(false), 2000);
                } catch {
                  setError('Copie impossible : sélectionne le lien et copie-le à la main.');
                }
              }}
            >
              {copied ? 'Copié' : 'Copier'}
            </button>
            {confirmRotate ? (
              <>
                <button className="btn danger small" disabled={busy === 'rotate'} onClick={() => void act('rotate', async () => {
                  await rotateToken(athlete.id);
                  setConfirmRotate(false);
                })}>
                  Confirmer
                </button>
                <button className="btn secondary small" onClick={() => setConfirmRotate(false)}>Annuler</button>
              </>
            ) : (
              <button className="btn secondary small" onClick={() => setConfirmRotate(true)}>Changer le lien…</button>
            )}
          </div>
          {confirmRotate && <p className="tiny muted">L'ancien lien cessera de fonctionner. Il faudra lui envoyer le nouveau.</p>}
        </div>
      </div>

      <div className="card">
        <div className="row between wrap">
          <h3>Niveaux par exercice</h3>
          <label className="field" style={{ minWidth: 240, flex: 1, maxWidth: 420 }}>
            <span className="tiny muted">Raison du prochain changement (facultatif)</span>
            <input className="input" maxLength={300} value={reason} onChange={(e) => setReason(e.target.value)} placeholder="Ex. : validé avec son kiné" />
          </label>
        </div>
        {!program && <div className="spinner" aria-label="Chargement" />}
        <div className="coach-grid">
          {(['A', 'B', 'M'] as ProgramSessionKey[]).map((s) => (
            <div key={s}>
              <div className="eyebrow" style={{ marginBottom: 4 }}>{SESSION_META[s].title}</div>
              {bySession(s).map((p) => {
                const max = p.exercises?.levels.length ?? 1;
                const label = p.exercises?.levels[p.level - 1]?.label ?? '';
                const key = `${s}-${p.exercise_id}`;
                const lf = lastFeeling.get(p.exercise_id);
                return (
                  <div key={key} className="list-row" style={{ alignItems: 'flex-start' }}>
                    <div className="grow">
                      <div style={{ fontWeight: 700, fontSize: 15 }}>{p.exercises?.name ?? p.exercise_id}</div>
                      <div className="tiny muted">{label}</div>
                      {lf && <div className="tiny" style={{ color: lf === 'douleur' ? 'var(--clay)' : 'var(--muted)' }}>Dernier ressenti : {FEELING_LABEL[lf]}</div>}
                    </div>
                    <div className="stepper">
                      <button
                        aria-label={`Baisser ${p.exercises?.name}`}
                        disabled={p.level <= 1 || busy === key}
                        onClick={() => void act(key, async () => {
                          await setLevel(athlete.id, p.exercise_id, p.level - 1, reason.trim() || null);
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
                          await setLevel(athlete.id, p.exercise_id, p.level + 1, reason.trim() || null);
                          setReason('');
                        })}
                      >
                        +
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          ))}
        </div>
      </div>

      <div className="card">
        <div className="row between wrap">
          <h3>Historique des séances</h3>
          {workouts.some((w) => !w.reviewed) && (
            <button className="btn secondary small" disabled={busy === 'all'} onClick={() => void act('all', () => markReviewed(workouts.filter((w) => !w.reviewed).map((w) => w.id)))}>
              Tout marquer comme vu
            </button>
          )}
        </div>
        {workouts.length === 0 && <p className="small muted">Aucune séance pour l'instant.</p>}
        {workouts.length > 0 && (
          <div className="table-wrap">
            <table className="history">
              <thead>
                <tr><th>Date</th><th>Séance</th><th>Douleur</th><th>Ressentis</th><th>Commentaire</th></tr>
              </thead>
              <tbody>
                {workouts.slice(0, 40).map((w) => {
                  const counts = { facile: 0, bien: 0, dur: 0, douleur: 0 } as Record<string, number>;
                  w.workout_items.forEach((i) => counts[i.feeling]++);
                  const painfulNames = w.workout_items.filter((i) => i.feeling === 'douleur').map((i) => exName(i.exercise_id));
                  const easyNames = w.workout_items.filter((i) => i.feeling === 'facile').map((i) => exName(i.exercise_id));
                  return (
                    <tr key={w.id} style={!w.reviewed ? { background: '#fcf8f2' } : undefined}>
                      <td style={{ whiteSpace: 'nowrap' }}>
                        {new Date(w.done_at).toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })}
                      </td>
                      <td>{w.session_key === 'C' ? 'Cardio' : w.session_key}</td>
                      <td style={{ whiteSpace: 'nowrap' }}>
                        <Dot color={w.neuro ? 'var(--clay)' : w.pain > 3 ? 'var(--rose-fig)' : 'var(--sage-mid)'} />
                        {w.pain}/10{w.neuro ? ' · symptôme' : ''}
                      </td>
                      <td>
                        {painfulNames.length > 0 && <div style={{ color: 'var(--clay)' }}>Douleur : {painfulNames.join(', ')}</div>}
                        {easyNames.length > 0 && <div>Trop facile : {easyNames.join(', ')}</div>}
                        {!painfulNames.length && !easyNames.length && w.workout_items.length > 0 && <span className="muted">{counts.dur ? `${counts.dur} dur, ` : ''}reste bien</span>}
                      </td>
                      <td>{w.comment ?? ''}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <div className="card">
        <h3>Journal des niveaux</h3>
        {changes.length === 0 && <p className="small muted">Aucun changement de niveau.</p>}
        {changes.map((c) => (
          <div key={c.id} className="list-row small">
            <span style={{ width: 90, flex: 'none' }} className="muted">{new Date(c.created_at).toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })}</span>
            <span className="grow">
              <strong>{exName(c.exercise_id)}</strong> : {c.from_level} → {c.to_level}
              {c.reason ? ` · ${c.reason}` : ''}
            </span>
            <span className={`pill ${c.source === 'auto' ? 'rose' : 'sage'}`}>{c.source === 'auto' ? 'auto' : 'coach'}</span>
          </div>
        ))}
      </div>
    </section>
  );
}
