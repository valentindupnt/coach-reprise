import { useState } from 'react';
import type { Feeling, ProgramItem, SessionKey } from '../lib/types';
import { SESSION_META } from '../lib/plan';

const FEELINGS: { value: Feeling; label: string }[] = [
  { value: 'facile', label: 'Trop facile' },
  { value: 'bien', label: 'Bien' },
  { value: 'dur', label: 'Dur' },
  { value: 'douleur', label: 'Douleur' },
];

function painColor(n: number): string {
  if (n <= 3) return 'var(--sage)';
  if (n <= 5) return 'var(--amber)';
  return 'var(--rose-fig)';
}

export interface FeedbackValue {
  pain: number;
  neuro: boolean;
  items: { exercise_id: string; feeling: Feeling }[];
  comment: string | null;
}

interface Props {
  session: SessionKey;
  items: ProgramItem[];
  painfulExerciseId: string | null;
  submitting: boolean;
  error: string | null;
  onSubmit: (v: FeedbackValue) => void;
}

export default function Feedback({ session, items, painfulExerciseId, submitting, error, onSubmit }: Props) {
  const [feelings, setFeelings] = useState<Record<string, Feeling>>(() => {
    const init: Record<string, Feeling> = {};
    for (const it of items) init[it.exercise.id] = it.exercise.id === painfulExerciseId ? 'douleur' : 'bien';
    return init;
  });
  const [pain, setPain] = useState<number | null>(null);
  const [neuro, setNeuro] = useState<boolean | null>(null);
  const [comment, setComment] = useState('');

  const ready = pain !== null && neuro !== null && !submitting;

  return (
    <div className="stack" style={{ gap: 16 }}>
      <div>
        <div className="eyebrow">{SESSION_META[session].title}</div>
        <h1 style={{ marginTop: 8 }}>Comment ça s'est passé ?</h1>
        <p className="muted" style={{ marginTop: 8 }}>30 secondes pour aider ton coach à ajuster ton programme.</p>
      </div>

      <fieldset className="card" style={{ border: 0, margin: 0 }}>
        <legend className="sr-only">Douleur pendant la séance</legend>
        <h3>Douleur la plus forte pendant la séance</h3>
        <div className="scale">
          {Array.from({ length: 11 }, (_, n) => (
            <button
              key={n}
              type="button"
              aria-pressed={pain === n}
              aria-label={`Douleur ${n} sur 10`}
              style={{ background: painColor(n) }}
              onClick={() => setPain(n)}
            >
              {n}
            </button>
          ))}
        </div>
        <div className="row between tiny muted">
          <span>Aucune</span>
          <span>Très forte</span>
        </div>
      </fieldset>

      <fieldset className="card" style={{ border: 0, margin: 0 }}>
        <legend className="sr-only">Symptômes</legend>
        <h3>As-tu ressenti des fourmillements, un engourdissement ou une faiblesse ?</h3>
        <div className="choice-grid">
          <button type="button" className="choice" aria-pressed={neuro === false} onClick={() => setNeuro(false)}>
            Non
          </button>
          <button type="button" className="choice warn" aria-pressed={neuro === true} onClick={() => setNeuro(true)}>
            Oui
          </button>
        </div>
        {neuro === true && (
          <p className="small" style={{ color: 'var(--rose-ink)' }}>
            Merci de l'avoir signalé. Ton programme sera mis en pause et on te dira quoi faire juste après.
          </p>
        )}
      </fieldset>

      {items.length > 0 && (
        <div className="card">
          <h3>Ton ressenti par exercice</h3>
          <p className="small muted">« Trop facile » deux séances de suite : ton coach pourra te faire passer au niveau suivant.</p>
          {items.map((it) => (
            <fieldset key={it.exercise.id} style={{ border: 0, margin: 0, padding: '8px 0 0', borderTop: '1px solid var(--sand)' }}>
              <legend style={{ fontWeight: 700, padding: 0, marginBottom: 8 }}>{it.exercise.name}</legend>
              <div className="choice-grid">
                {FEELINGS.map((f) => (
                  <button
                    key={f.value}
                    type="button"
                    className={`choice ${f.value === 'douleur' ? 'warn' : ''}`}
                    aria-pressed={feelings[it.exercise.id] === f.value}
                    onClick={() => setFeelings((s) => ({ ...s, [it.exercise.id]: f.value }))}
                  >
                    {f.label}
                  </button>
                ))}
              </div>
            </fieldset>
          ))}
        </div>
      )}

      <label className="field card">
        Un mot pour ton coach (facultatif)
        <textarea className="input" maxLength={500} value={comment} onChange={(e) => setComment(e.target.value)} />
      </label>

      {error && <div className="banner error" role="alert">{error}</div>}

      <button
        className="btn block"
        disabled={!ready}
        onClick={() =>
          ready &&
          onSubmit({
            pain: pain!,
            neuro: neuro!,
            items: items.map((it) => ({ exercise_id: it.exercise.id, feeling: feelings[it.exercise.id] ?? 'bien' })),
            comment: comment.trim() || null,
          })
        }
      >
        {submitting ? 'Enregistrement…' : 'Enregistrer ma séance'}
      </button>
      {!ready && !submitting && <p className="tiny muted" style={{ textAlign: 'center' }}>Indique ta douleur et réponds à la question sur les symptômes.</p>}
    </div>
  );
}
