import { useEffect, useState } from 'react';
import type { Feeling, Preference, ProgramItem, ProgramSessionKey, SessionKey, SwapOption } from '../lib/types';
import { SESSION_META } from '../lib/plan';
import { WHY_LABEL, ZONE_LABEL, label } from '../lib/library';
import type { SessionEntry } from './Player';

const FEELINGS: { value: Feeling; label: string }[] = [
  { value: 'facile', label: 'Trop facile' },
  { value: 'bien', label: 'Bien' },
  { value: 'dur', label: 'Dur' },
  { value: 'douleur', label: 'Douleur' },
];

/** Échelle d'effort perçu de la séance, 0 à 10 (CR10 de Foster). */
const RPE_LABELS = [
  'Repos',
  'Très très facile',
  'Facile',
  'Modéré',
  'Un peu dur',
  'Dur',
  'Dur +',
  'Très dur',
  'Très très dur',
  'Presque maximal',
  'Maximal',
];

function painColor(n: number): string {
  if (n <= 3) return 'var(--sage)';
  if (n <= 5) return 'var(--amber)';
  return 'var(--rose-fig)';
}

function rpeColor(n: number): string {
  if (n <= 3) return 'var(--sage)';
  if (n <= 6) return 'var(--amber)';
  return 'var(--rose)';
}

export interface FeedbackValue {
  pain: number;
  /** V5 : plus de question sur les symptômes (le gel est supprimé) ; toujours false. */
  neuro: boolean;
  rpe: number;
  duration_min: number;
  items: { exercise_id: string; feeling: Feeling | null; preference: Preference | null }[];
  swaps: { session: ProgramSessionKey; from: string; to: string }[];
  comment: string | null;
}

interface Props {
  session: SessionKey;
  entries: SessionEntry[];
  /** Durée mesurée par le lecteur ; null pour une séance libre (cardio). */
  durationMin: number | null;
  allowSwaps: boolean;
  submitting: boolean;
  error: string | null;
  loadOptions: (item: ProgramItem) => Promise<SwapOption[]>;
  onSubmit: (v: FeedbackValue) => void;
}

export default function Feedback({ session, entries, durationMin, allowSwaps, submitting, error, loadOptions, onSubmit }: Props) {
  const worked = entries.filter((e) => e.status !== 'skipped');
  const skipped = entries.filter((e) => e.status === 'skipped');
  // un exercice douloureux déjà remplacé pendant la séance n'a pas besoin de nouvelles propositions
  const replacementOf = (e: SessionEntry) => entries.find((x) => x.replacedFrom === e.item.exercise.id && x.status !== 'skipped');

  // Aucune pré-coche : un exercice non noté n'est pas envoyé.
  const [feelings, setFeelings] = useState<Record<string, Feeling>>({});
  const [prefs, setPrefs] = useState<Record<string, Preference | null>>({});
  const [options, setOptions] = useState<Record<string, SwapOption[] | 'loading'>>({});
  const [chosen, setChosen] = useState<Record<string, string | null>>(() => {
    // remplacement fait pendant la séance : on propose de le garder, décoché par défaut
    const init: Record<string, string | null> = {};
    for (const e of entries) if (e.replacedFrom) init[e.replacedFrom] = null;
    return init;
  });
  const [pain, setPain] = useState<number | null>(null);
  const [rpe, setRpe] = useState<number | null>(null);
  const [minutes, setMinutes] = useState<number>(durationMin ?? 30);
  const [comment, setComment] = useState('');

  const isProgram = session !== 'C';
  const ready = pain !== null && rpe !== null && !submitting;

  function ensureOptions(item: ProgramItem) {
    const id = item.exercise.id;
    if (!allowSwaps || options[id]) return;
    setOptions((o) => ({ ...o, [id]: 'loading' }));
    loadOptions(item)
      .then((list) => setOptions((o) => ({ ...o, [id]: list })))
      .catch(() => setOptions((o) => ({ ...o, [id]: [] })));
  }

  function setPreference(item: ProgramItem, p: Preference) {
    const id = item.exercise.id;
    const next = prefs[id] === p ? null : p;
    setPrefs((s) => ({ ...s, [id]: next }));
    if (next === 'a_changer') ensureOptions(item);
    else setChosen((c) => ({ ...c, [id]: null }));
  }

  function pickSwap(fromId: string, toId: string) {
    setChosen((c) => ({ ...c, [fromId]: c[fromId] === toId ? null : toId }));
  }

  // Les exercices douloureux sans remplacement font directement apparaître les propositions.
  useEffect(() => {
    if (!allowSwaps) return;
    for (const e of entries) {
      if (e.status === 'painful' && !e.replacedFrom && !entries.some((x) => x.replacedFrom === e.item.exercise.id && x.status !== 'skipped')) {
        ensureOptions(e.item);
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  function submit() {
    if (!ready) return;
    const items: FeedbackValue['items'] = [];
    for (const e of worked) {
      const id = e.item.exercise.id;
      const feeling: Feeling | null = e.status === 'painful' ? 'douleur' : feelings[id] ?? null;
      const preference = e.status === 'painful' && !e.replacedFrom ? 'a_changer' : prefs[id] ?? null;
      // un exercice non noté n'est pas envoyé ; sans ressenti, seule la préférence l'est
      if (!feeling && !preference) continue;
      items.push({ exercise_id: id, feeling, preference });
    }
    // Un exercice douloureux remplacé en séance a son retour « douleur » même si l'autre n'a pas été noté
    const swaps: FeedbackValue['swaps'] = [];
    if (isProgram && allowSwaps) {
      for (const [from, to] of Object.entries(chosen)) if (to) swaps.push({ session: session as ProgramSessionKey, from, to });
    }
    onSubmit({
      pain: pain!,
      neuro: false,
      rpe: rpe!,
      duration_min: minutes,
      items,
      swaps,
      comment: comment.trim() || null,
    });
  }

  function swapChoices(fromId: string, item: ProgramItem) {
    const list = options[item.exercise.id];
    if (!allowSwaps) return null;
    if (list === 'loading' || !list) return <div className="spinner" aria-label="Chargement des propositions" />;
    if (list.length === 0) return <p className="tiny muted">Pas d'exercice équivalent pour le moment : ton coach en sera informé.</p>;
    return (
      <div className="stack" style={{ gap: 8 }}>
        <p className="small">Remplacer pour les prochaines séances ?</p>
        {list.map((o) => (
          <div key={o.exercise.id} className="swap-option">
            <div className="grow">
              <div style={{ fontWeight: 700 }}>{o.exercise.name}</div>
              <div className="tiny muted">
                {WHY_LABEL[o.why]} · {o.exercise.zones.map((z) => label(ZONE_LABEL, z)).join(', ')}
              </div>
            </div>
            <button
              type="button"
              className={`btn small ${chosen[fromId] === o.exercise.id ? '' : 'secondary'}`}
              aria-pressed={chosen[fromId] === o.exercise.id}
              onClick={() => pickSwap(fromId, o.exercise.id)}
            >
              {chosen[fromId] === o.exercise.id ? 'Choisi ✓' : 'Choisir'}
            </button>
          </div>
        ))}
        <p className="tiny muted">Sans choix, l'exercice reste dans ton programme.</p>
      </div>
    );
  }

  return (
    <div className="stack" style={{ gap: 16 }}>
      <div>
        <div className="eyebrow">{SESSION_META[session].title}</div>
        <h1 style={{ marginTop: 8 }}>Comment ça s'est passé ?</h1>
        <p className="muted" style={{ marginTop: 8 }}>
          {new Date().toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' })}
        </p>
      </div>

      <fieldset className="card" style={{ border: 0, margin: 0 }}>
        <legend className="sr-only">Effort de la séance</legend>
        <h3>Effort de la séance</h3>
        <p className="small muted">De 0 (repos) à 10 (maximal) : à quel point la séance entière était-elle difficile ?</p>
        <div className="scale">
          {Array.from({ length: 11 }, (_, n) => (
            <button
              key={n}
              type="button"
              aria-pressed={rpe === n}
              aria-label={`Effort ${n} sur 10 : ${RPE_LABELS[n]}`}
              style={{ background: rpeColor(n) }}
              onClick={() => setRpe(n)}
            >
              {n}
            </button>
          ))}
        </div>
        <div className="row between tiny muted">
          <span>Repos</span>
          <span>Maximal</span>
        </div>
        {rpe !== null && (
          <p className="small" style={{ fontWeight: 700 }} aria-live="polite">
            {rpe} · {RPE_LABELS[rpe]}
          </p>
        )}
        <div className="row between" style={{ marginTop: 4 }}>
          <span className="small">Durée : <strong>{minutes} min</strong></span>
          <span className="row" style={{ gap: 6 }}>
            <button type="button" className="btn secondary small" aria-label="Moins une minute" onClick={() => setMinutes((m) => Math.max(1, m - (durationMin == null ? 5 : 1)))}>
              −
            </button>
            <button type="button" className="btn secondary small" aria-label="Plus une minute" onClick={() => setMinutes((m) => Math.min(240, m + (durationMin == null ? 5 : 1)))}>
              +
            </button>
          </span>
        </div>
      </fieldset>

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

      {isProgram && (
        <div className="card">
          <h3>Tes exercices</h3>
          {worked.length === 0 ? (
            <p className="small muted">Aucun exercice n'a été fait pendant cette séance.</p>
          ) : (
            <p className="small muted">
              Seuls les exercices que tu as faits sont listés. Note-les si tu veux : « Trop facile » deux séances de suite, et ton
              coach pourra te faire passer au niveau suivant.
            </p>
          )}

          {worked.map((e) => {
            const id = e.item.exercise.id;
            const painful = e.status === 'painful';
            const replacement = replacementOf(e);
            return (
              <fieldset key={id} style={{ border: 0, margin: 0, padding: '10px 0 0', borderTop: '1px solid var(--sand)' }}>
                <legend style={{ fontWeight: 700, padding: 0, marginBottom: 8 }}>
                  {e.item.exercise.name}
                  {painful && <span className="pill red" style={{ marginLeft: 8 }}>Douleur signalée</span>}
                </legend>
                {e.replacedFrom && (
                  <p className="tiny muted" style={{ marginTop: -4 }}>
                    Pris à la place de « {entries.find((x) => x.item.exercise.id === e.replacedFrom)?.item.exercise.name ?? e.replacedFrom} »
                  </p>
                )}

                {!painful && (
                  <>
                    <div className="choice-grid">
                      {FEELINGS.map((f) => (
                        <button
                          key={f.value}
                          type="button"
                          className={`choice ${f.value === 'douleur' ? 'warn' : ''}`}
                          aria-pressed={feelings[id] === f.value}
                          onClick={() =>
                            setFeelings((s) => {
                              const { [id]: current, ...rest } = s;
                              return current === f.value ? rest : { ...rest, [id]: f.value };
                            })
                          }
                        >
                          {f.label}
                        </button>
                      ))}
                    </div>
                    {!e.replacedFrom && (
                      <div className="row" style={{ gap: 8, marginTop: 8 }}>
                        <button type="button" className="chip" aria-pressed={prefs[id] === 'aime'} onClick={() => setPreference(e.item, 'aime')}>
                          J'aime
                        </button>
                        {allowSwaps && (
                          <button type="button" className="chip" aria-pressed={prefs[id] === 'a_changer'} onClick={() => setPreference(e.item, 'a_changer')}>
                            À changer
                          </button>
                        )}
                      </div>
                    )}
                  </>
                )}

                {/* exercice douloureux : propositions, sauf s'il a déjà été remplacé en séance */}
                {painful && !replacement && !e.replacedFrom && swapChoices(id, e.item)}

                {/* remplacement fait en séance : le garder pour la suite ? */}
                {painful && replacement && allowSwaps && (
                  <label className="row" style={{ gap: 10, marginTop: 4 }}>
                    <input
                      type="checkbox"
                      checked={chosen[id] === replacement.item.exercise.id}
                      onChange={(ev) => setChosen((c) => ({ ...c, [id]: ev.target.checked ? replacement.item.exercise.id : null }))}
                    />
                    <span className="small">Garder « {replacement.item.exercise.name} » à la place pour les prochaines séances</span>
                  </label>
                )}

                {!painful && prefs[id] === 'a_changer' && !e.replacedFrom && swapChoices(id, e.item)}
              </fieldset>
            );
          })}

          {skipped.length > 0 && (
            <div style={{ borderTop: '1px solid var(--sand)', paddingTop: 10 }}>
              <p className="small muted">
                Passés, donc pas notés : {skipped.map((s) => s.item.exercise.name).join(', ')}.
              </p>
            </div>
          )}
        </div>
      )}

      <label className="field card">
        Un mot pour ton coach (facultatif)
        <textarea className="input" maxLength={500} value={comment} onChange={(e) => setComment(e.target.value)} />
      </label>

      {error && <div className="banner error" role="alert">{error}</div>}

      <button className="btn block" disabled={!ready} onClick={submit}>
        {submitting ? 'Enregistrement…' : 'Enregistrer ma séance'}
      </button>
      {!ready && !submitting && (
        <p className="tiny muted" style={{ textAlign: 'center' }}>
          Indique l'effort, la douleur et réponds à la question sur les symptômes.
        </p>
      )}
    </div>
  );
}
