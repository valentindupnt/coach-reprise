import { useState } from 'react';
import LibraryBrowser from '../components/LibraryBrowser';
import { EQUIPMENT_LABEL, INTENSITY_LABEL, KIND_LABEL, ZONE_LABEL } from '../lib/library';
import { readableError } from '../lib/supabase';
import type { ExerciseKind, Level } from '../lib/types';
import { saveExercise, setApproved, type CoachExercise } from './api';

interface Props {
  library: CoachExercise[];
  onChanged: () => Promise<void>;
}

interface Draft {
  id: string;
  isNew: boolean;
  name: string;
  kind: ExerciseKind;
  zones: string[];
  equipment: string[];
  intensity: number;
  family: string;
  pattern: string;
  max_sets: number;
  cues: string;
  caution: string;
  levels: string;
  illustration: string;
  video_url: string;
  source: string;
  approved: boolean;
}

const slug = (s: string) =>
  s
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '')
    .slice(0, 40);

const levelsToText = (levels: Level[]) => levels.map((l) => (l.seconds ? `${l.label} | ${l.seconds}` : l.label)).join('\n');

function textToLevels(text: string): Level[] {
  return text
    .split('\n')
    .map((l) => l.trim())
    .filter(Boolean)
    .map((line) => {
      const [label, sec] = line.split('|').map((x) => x.trim());
      const seconds = Number(sec);
      return Number.isFinite(seconds) && seconds > 0 ? { label, seconds } : { label };
    });
}

function toDraft(e: CoachExercise): Draft {
  return {
    id: e.id,
    isNew: false,
    name: e.name,
    kind: e.kind,
    zones: e.zones,
    equipment: e.equipment,
    intensity: e.intensity,
    family: e.family ?? '',
    pattern: e.pattern ?? '',
    max_sets: e.max_sets,
    cues: e.cues.join('\n'),
    caution: e.caution ?? '',
    levels: levelsToText(e.levels),
    illustration: e.illustration ?? '',
    video_url: e.video_url ?? '',
    source: e.source ?? '',
    approved: e.approved,
  };
}

const EMPTY: Draft = {
  id: '',
  isNew: true,
  name: '',
  kind: 'force',
  zones: [],
  equipment: [],
  intensity: 2,
  family: '',
  pattern: '',
  max_sets: 3,
  cues: '',
  caution: '',
  levels: '',
  illustration: '',
  video_url: '',
  source: '',
  approved: false,
};

function toggle(list: string[], v: string): string[] {
  return list.includes(v) ? list.filter((x) => x !== v) : [...list, v];
}

export default function LibraryAdmin({ library, onChanged }: Props) {
  const [draft, setDraft] = useState<Draft | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState<string | null>(null);
  const [onlyPending, setOnlyPending] = useState(false);
  const pending = library.filter((e) => !e.approved).length;
  const set = (patch: Partial<Draft>) => setDraft((d) => (d ? { ...d, ...patch } : d));

  async function run(key: string, fn: () => Promise<void>) {
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

  async function save() {
    if (!draft) return;
    const levels = textToLevels(draft.levels);
    if (!draft.name.trim()) return setError('Donne un nom à l\'exercice.');
    if (levels.length === 0) return setError('Ajoute au moins un niveau (une ligne par niveau).');
    const id = draft.isNew ? slug(draft.name) : draft.id;
    if (id.length < 2) return setError('Le nom est trop court.');
    await run('save', async () => {
      await saveExercise({
        id,
        name: draft.name.trim(),
        kind: draft.kind,
        zones: draft.zones,
        equipment: draft.equipment,
        intensity: draft.intensity,
        family: draft.family.trim() || null,
        pattern: draft.pattern.trim() || null,
        max_sets: draft.max_sets,
        cues: draft.cues.split('\n').map((c) => c.trim()).filter(Boolean),
        caution: draft.caution.trim() || null,
        levels,
        illustration: draft.illustration.trim() || null,
        video_url: draft.video_url.trim() || null,
        source: draft.source.trim() || null,
        approved: draft.approved,
      });
      setDraft(null);
    });
  }

  if (draft) {
    return (
      <section className="stack" style={{ gap: 12 }} aria-label="Fiche exercice">
        <div className="row between wrap">
          <h2>{draft.isNew ? 'Nouvel exercice' : draft.name}</h2>
          <button className="btn ghost" onClick={() => setDraft(null)}>← Retour à la bibliothèque</button>
        </div>
        {error && <div className="banner error" role="alert">{error}</div>}
        <div className="card">
          <label className="field">
            Nom
            <input className="input" maxLength={80} value={draft.name} onChange={(e) => set({ name: e.target.value })} />
          </label>
          <div className="filter-row">
            <label className="field">
              Type
              <select className="input" value={draft.kind} onChange={(e) => set({ kind: e.target.value as ExerciseKind })}>
                {Object.entries(KIND_LABEL).map(([k, v]) => (
                  <option key={k} value={k}>{v}</option>
                ))}
              </select>
            </label>
            <label className="field">
              Intensité
              <select className="input" value={draft.intensity} onChange={(e) => set({ intensity: Number(e.target.value) })}>
                {[1, 2, 3, 4, 5].map((n) => (
                  <option key={n} value={n}>{n} · {INTENSITY_LABEL[n]}</option>
                ))}
              </select>
            </label>
            <label className="field">
              Tours max conseillés
              <select className="input" value={draft.max_sets} onChange={(e) => set({ max_sets: Number(e.target.value) })}>
                {[1, 2, 3, 4].map((n) => (
                  <option key={n} value={n}>{n}</option>
                ))}
              </select>
            </label>
          </div>
          <fieldset style={{ border: 0, margin: 0, padding: 0 }}>
            <legend className="small" style={{ fontWeight: 500, marginBottom: 6 }}>Zones travaillées</legend>
            <div className="row wrap" style={{ gap: 6 }}>
              {Object.entries(ZONE_LABEL).map(([k, v]) => (
                <button key={k} type="button" className="chip" aria-pressed={draft.zones.includes(k)} onClick={() => set({ zones: toggle(draft.zones, k) })}>
                  {v}
                </button>
              ))}
            </div>
          </fieldset>
          <fieldset style={{ border: 0, margin: 0, padding: 0 }}>
            <legend className="small" style={{ fontWeight: 500, marginBottom: 6 }}>Matériel</legend>
            <div className="row wrap" style={{ gap: 6 }}>
              {Object.entries(EQUIPMENT_LABEL).map(([k, v]) => (
                <button key={k} type="button" className="chip" aria-pressed={draft.equipment.includes(k)} onClick={() => set({ equipment: toggle(draft.equipment, k) })}>
                  {v}
                </button>
              ))}
            </div>
          </fieldset>
          <div className="filter-row" style={{ gridTemplateColumns: 'repeat(2, minmax(0, 1fr))' }}>
            <label className="field">
              Famille (variantes d'un même exercice)
              <input className="input" value={draft.family} placeholder="ex. : pont" onChange={(e) => set({ family: e.target.value })} />
            </label>
            <label className="field">
              Schéma de mouvement
              <input className="input" value={draft.pattern} placeholder="ex. : tirage, pont, rotation" onChange={(e) => set({ pattern: e.target.value })} />
            </label>
          </div>
        </div>

        <div className="card">
          <label className="field">
            Niveaux (une ligne par niveau, « description | secondes » ; du plus facile au plus dur)
            <textarea className="input" value={draft.levels} onChange={(e) => set({ levels: e.target.value })} placeholder={'Version facile | 30\nVersion normale | 45'} />
          </label>
          <label className="field">
            Consignes (une par ligne)
            <textarea className="input" value={draft.cues} onChange={(e) => set({ cues: e.target.value })} />
          </label>
          <label className="field">
            Précaution (facultatif)
            <input className="input" value={draft.caution} onChange={(e) => set({ caution: e.target.value })} />
          </label>
          <div className="filter-row" style={{ gridTemplateColumns: 'repeat(2, minmax(0, 1fr))' }}>
            <label className="field">
              Illustration (identifiant, facultatif)
              <input className="input" value={draft.illustration} onChange={(e) => set({ illustration: e.target.value })} />
            </label>
            <label className="field">
              Vidéo (lien, facultatif)
              <input className="input" type="url" value={draft.video_url} onChange={(e) => set({ video_url: e.target.value })} />
            </label>
          </div>
          <label className="field">
            Source (facultatif)
            <input className="input" value={draft.source} placeholder="ex. : Mass General Brigham" onChange={(e) => set({ source: e.target.value })} />
          </label>
          <label className="row" style={{ gap: 10 }}>
            <input type="checkbox" checked={draft.approved} onChange={(e) => set({ approved: e.target.checked })} />
            <span className="small">Validé : visible par les athlètes et proposé en remplacement</span>
          </label>
          <div className="row">
            <button className="btn" disabled={busy === 'save'} onClick={() => void save()}>Enregistrer</button>
            <button className="btn secondary" onClick={() => setDraft(null)}>Annuler</button>
          </div>
        </div>
      </section>
    );
  }

  return (
    <section className="stack" style={{ gap: 12 }} aria-label="Bibliothèque d'exercices">
      <div className="row between wrap">
        <div>
          <div className="eyebrow">Catalogue</div>
          <h1 style={{ marginTop: 8 }}>Bibliothèque</h1>
          <p className="small muted">
            {library.length} exercices · {pending} à valider. Un exercice non validé n'est ni visible ni proposé aux athlètes.
          </p>
        </div>
        <button className="btn" onClick={() => { setError(null); setDraft({ ...EMPTY }); }}>+ Nouvel exercice</button>
      </div>
      {error && <div className="banner error" role="alert">{error}</div>}
      <LibraryBrowser
        exercises={library}
        predicate={onlyPending ? (e) => !e.approved : undefined}
        extraFilter={
          <label className="row" style={{ gap: 10 }}>
            <input type="checkbox" checked={onlyPending} onChange={(e) => setOnlyPending(e.target.checked)} />
            <span className="small">Seulement ceux à valider ({pending})</span>
          </label>
        }
        badge={(e) => (e.approved ? null : <span className="pill rose">À valider</span>)}
        actions={(e) => (
          <div className="stack" style={{ gap: 8 }}>
            {e.source && <p className="tiny muted">Source : {e.source}</p>}
            <div className="row wrap">
              <button
                className="btn small"
                disabled={busy === e.id}
                onClick={() => void run(e.id, () => setApproved(e.id, !e.approved))}
              >
                {e.approved ? 'Retirer la validation' : 'Valider'}
              </button>
              <button className="btn secondary small" onClick={() => { setError(null); setDraft(toDraft(e)); }}>
                Modifier
              </button>
            </div>
          </div>
        )}
      />
    </section>
  );
}
