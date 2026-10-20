import { useMemo, useState, type ReactNode } from 'react';
import Figure from './Figure';
import type { Exercise } from '../lib/types';
import {
  EMPTY_FILTER,
  EQUIPMENT_LABEL,
  INTENSITY_LABEL,
  KIND_LABEL,
  ZONE_LABEL,
  facets,
  filterExercises,
  label,
  variantsOf,
  type LibraryFilter,
} from '../lib/library';

interface Props<T extends Exercise> {
  exercises: T[];
  /** Exercices présents dans le programme de la personne (repère « dans ton programme »). */
  inProgram?: string[];
  /** Mot affiché à la place de « dans ton programme » (côté coach : « dans le programme »). */
  inProgramLabel?: string;
  /** Contenu ajouté sous chaque fiche ouverte (actions du coach). */
  actions?: (e: T) => ReactNode;
  /** Pastille supplémentaire à côté du nom (ex. « À valider »). */
  badge?: (e: T) => ReactNode;
  /** Filtre en plus de ceux de l'écran (ex. « à valider »). */
  extraFilter?: ReactNode;
  predicate?: (e: T) => boolean;
  empty?: string;
}

export default function LibraryBrowser<T extends Exercise>({
  exercises,
  inProgram = [],
  inProgramLabel = 'Dans ton programme',
  actions,
  badge,
  extraFilter,
  predicate,
  empty = 'Aucun exercice ne correspond.',
}: Props<T>) {
  const [filter, setFilter] = useState<LibraryFilter>(EMPTY_FILTER);
  const [open, setOpen] = useState<string | null>(null);
  const f = useMemo(() => facets(exercises), [exercises]);
  const shown = useMemo(
    () => filterExercises(exercises, filter).filter((e) => (predicate ? predicate(e) : true)),
    [exercises, filter, predicate],
  );
  const set = (patch: Partial<LibraryFilter>) => setFilter((x) => ({ ...x, ...patch }));

  return (
    <div className="stack" style={{ gap: 12 }}>
      <div className="card">
        <label className="field">
          <span className="sr-only">Chercher un exercice</span>
          <input
            className="input"
            type="search"
            placeholder="Chercher un exercice ou une zone"
            value={filter.text}
            onChange={(e) => set({ text: e.target.value })}
          />
        </label>
        <div className="filter-row">
          <label className="field">
            Type
            <select className="input" value={filter.kind} onChange={(e) => set({ kind: e.target.value as LibraryFilter['kind'] })}>
              <option value="">Tous</option>
              {f.kinds.map((k) => (
                <option key={k} value={k}>{label(KIND_LABEL, k)}</option>
              ))}
            </select>
          </label>
          <label className="field">
            Zone
            <select className="input" value={filter.zone} onChange={(e) => set({ zone: e.target.value })}>
              <option value="">Toutes</option>
              {f.zones.map((z) => (
                <option key={z} value={z}>{label(ZONE_LABEL, z)}</option>
              ))}
            </select>
          </label>
          <label className="field">
            Matériel
            <select className="input" value={filter.equipment} onChange={(e) => set({ equipment: e.target.value })}>
              <option value="">Tout</option>
              {f.equipment.map((q) => (
                <option key={q} value={q}>{label(EQUIPMENT_LABEL, q)}</option>
              ))}
            </select>
          </label>
        </div>
        {extraFilter}
        <p className="tiny muted" aria-live="polite">{shown.length} exercice{shown.length > 1 ? 's' : ''}</p>
      </div>

      {shown.length === 0 && <p className="small muted">{empty}</p>}

      {shown.map((e) => {
        const isOpen = open === e.id;
        const variants = variantsOf(exercises, e);
        return (
          <div key={e.id} className="card lib-card">
            <button
              type="button"
              className="lib-head"
              aria-expanded={isOpen}
              onClick={() => setOpen(isOpen ? null : e.id)}
            >
              <span className="grow">
                <span style={{ display: 'block', fontWeight: 700 }}>
                  {e.name} {badge?.(e)}
                </span>
                <span className="small muted">
                  {label(KIND_LABEL, e.kind)} · {e.zones.map((z) => label(ZONE_LABEL, z)).join(', ') || 'zone non précisée'}
                </span>
              </span>
              <span className="pill">{INTENSITY_LABEL[e.intensity] ?? e.intensity}</span>
            </button>
            {inProgram.includes(e.id) && <span className="pill sage" style={{ alignSelf: 'flex-start' }}>{inProgramLabel}</span>}

            {isOpen && (
              <div className="stack" style={{ gap: 12 }}>
                {e.illustration && <Figure id={e.illustration} label={e.name} />}
                <div className="row wrap" style={{ gap: 6 }}>
                  {e.equipment.map((q) => (
                    <span key={q} className="pill">{label(EQUIPMENT_LABEL, q)}</span>
                  ))}
                  <span className="pill">Jusqu'à {e.max_sets} tour{e.max_sets > 1 ? 's' : ''}</span>
                </div>
                {e.cues.length > 0 && (
                  <div>
                    <div className="eyebrow">Comment faire</div>
                    {e.cues.map((c, i) => (
                      <div key={i} className="cue">
                        <div className="cue-n">{i + 1}</div>
                        <div className="small">{c}</div>
                      </div>
                    ))}
                  </div>
                )}
                {e.caution && <div className="banner warn">{e.caution}</div>}
                <div>
                  <div className="eyebrow">Niveaux</div>
                  {e.levels.map((l, i) => (
                    <div key={i} className="small" style={{ padding: '2px 0' }}>
                      <strong>{i + 1}.</strong> {l.label}
                      {l.seconds ? ` (${l.seconds} s)` : ''}
                    </div>
                  ))}
                </div>
                {variants.length > 0 && (
                  <div>
                    <div className="eyebrow">Variantes</div>
                    <div className="row wrap" style={{ gap: 6 }}>
                      {variants.map((v) => (
                        <button key={v.id} type="button" className="chip" aria-pressed={false} onClick={() => setOpen(v.id)}>
                          {v.name}
                        </button>
                      ))}
                    </div>
                  </div>
                )}
                {e.video_url && (
                  <a className="small" href={e.video_url} target="_blank" rel="noopener noreferrer">
                    Voir une vidéo de démonstration ↗
                  </a>
                )}
                {actions?.(e)}
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}
