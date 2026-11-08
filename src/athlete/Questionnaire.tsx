// NOMA : questionnaire de départ en 8 questions. Une question par écran, rien d'obligatoire sauf le choix à faire.
import { useState } from 'react';
import { saveBodyProfile, saveQuestionnaire } from '../lib/athleteApi';
import { readableError } from '../lib/supabase';
import {
  AVOID_ZONES, DAYS, GOALS, LEVELS, MINUTES, PLACES, REFERENCES, TOTAL_STEPS, UNIT_LABEL, type Answers,
} from '../lib/questionnaire';

const TICK = <svg viewBox="0 0 24 24" aria-hidden="true" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12.5l4.5 4.5L19 7.5" /></svg>;

function Option({ on, label, onClick }: { on: boolean; label: string; onClick: () => void }) {
  return (
    <button className="option" aria-pressed={on} onClick={onClick}>
      <span className={`tick ${on ? 'on' : ''}`}>{on ? TICK : null}</span>
      <span>{label}</span>
    </button>
  );
}

export default function Questionnaire({
  token, initial, onDone, onCancel,
}: { token: string; initial: Answers; onDone: () => void; onCancel: () => void }) {
  const [step, setStep] = useState(1);
  const [a, setA] = useState<Answers>(initial);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [finished, setFinished] = useState(false);
  const set = (patch: Partial<Answers>) => setA((x) => ({ ...x, ...patch }));
  const refs = a.refs ?? {};

  async function next() {
    setError(null);
    if (step < TOTAL_STEPS) {
      setStep(step + 1);
      void saveQuestionnaire(token, { ...a }).catch(() => undefined);
      return;
    }
    setSaving(true);
    try {
      await saveQuestionnaire(token, { ...a }, true);
      await saveBodyProfile(token, {
        height_cm: a.height_cm ?? null,
        weight_kg: a.weight_kg ?? null,
        birth_year: a.birth_year ?? null,
      });
      setFinished(true);
    } catch (e) {
      setError(readableError(e));
    } finally {
      setSaving(false);
    }
  }

  if (finished) {
    const goal = GOALS.find((g) => g.id === a.goal)?.label;
    const place = PLACES.find((p) => p.id === a.place)?.label;
    return (
      <div className="stack" style={{ gap: 16, paddingTop: 24 }}>
        <div>
          <div className="eyebrow">Questionnaire terminé</div>
          <h1 style={{ marginTop: 8 }}>Merci, c'est noté</h1>
        </div>
        <div className="card rose">
          <div className="eyebrow">Ce que tu as indiqué</div>
          <p>{goal ?? 'Objectif non précisé'}</p>
          <div className="row wrap" style={{ gap: 8 }}>
            {a.days && <span className="pill">{a.days} jours par semaine</span>}
            {a.minutes && <span className="pill">{a.minutes} min</span>}
            {place && <span className="pill">{place}</span>}
            {(a.avoid ?? []).length > 0 && <span className="pill">Sans : {(a.avoid ?? []).join(', ')}</span>}
          </div>
        </div>
        <div className="banner info">
          Tes réponses sont enregistrées. Le programme de muscu qui s'en déduit n'est pas encore en ligne : en attendant, les étirements et les séances existantes restent disponibles.
        </div>
        <button className="btn block" onClick={onDone}>Retour au plan</button>
      </div>
    );
  }

  const canNext =
    (step === 1 && !!a.level) || (step === 3 && !!a.goal) || (step === 4 && !!a.days) || (step === 5 && !!a.minutes) ||
    (step === 6 && !!a.place) || step === 2 || step === 7 || step === 8;

  return (
    <div className="stack" style={{ gap: 16, paddingBottom: 140 }}>
      <div className="row">
        <button className="btn ghost" style={{ minHeight: 44 }} onClick={step === 1 ? onCancel : () => setStep(step - 1)} aria-label="Retour">←</button>
        <p className="tiny muted">Question {step} sur {TOTAL_STEPS}</p>
      </div>
      <div className="seg-bar" aria-hidden="true">
        {Array.from({ length: TOTAL_STEPS }, (_, i) => <span key={i} className={i < step ? 'on' : ''} />)}
      </div>

      {step === 1 && (
        <>
          <h1>Ton niveau en musculation ?</h1>
          <p className="muted small">Il sert par défaut si tu ne donnes pas de repères.</p>
          <div className="stack">{LEVELS.map((l) => <Option key={l.id} on={a.level === l.id} label={l.label} onClick={() => set({ level: l.id })} />)}</div>
        </>
      )}

      {step === 2 && (
        <>
          <h1>Tes repères aujourd'hui</h1>
          <p className="muted small">Ton maximum d'affilée, ou la charge que tu soulèves 10 fois. Remplis seulement ce que tu connais.</p>
          <div className="ref-list">
            {REFERENCES.filter((r) => refs[r.id] !== undefined).map((r) => (
              <div className="ref-row" key={r.id}>
                <div className="grow"><b>{r.name}</b><div className="tiny muted">{r.hint}</div></div>
                <button className="mini" aria-label={`Moins ${r.name}`} onClick={() => set({ refs: { ...refs, [r.id]: Math.max(0, refs[r.id] - r.step) } })}>−</button>
                <span className="ref-val">{refs[r.id]}<small>{UNIT_LABEL[r.unit]}</small></span>
                <button className="mini" aria-label={`Plus ${r.name}`} onClick={() => set({ refs: { ...refs, [r.id]: refs[r.id] + r.step } })}>+</button>
                <button className="rm" aria-label={`Retirer ${r.name}`} onClick={() => { const n = { ...refs }; delete n[r.id]; set({ refs: n }); }}>×</button>
              </div>
            ))}
          </div>
          <div className="eyebrow">Ajouter un repère</div>
          <div className="row wrap" style={{ gap: 8 }}>
            {REFERENCES.filter((r) => refs[r.id] === undefined).map((r) => (
              <button key={r.id} className="chip" onClick={() => set({ refs: { ...refs, [r.id]: r.start } })}>+ {r.name}</button>
            ))}
          </div>
        </>
      )}

      {step === 3 && (
        <>
          <h1>Ton objectif principal ?</h1>
          <p className="muted small">Tu pourras le changer plus tard.</p>
          <div className="stack">{GOALS.map((g) => <Option key={g.id} on={a.goal === g.id} label={g.label} onClick={() => set({ goal: g.id })} />)}</div>
        </>
      )}

      {step === 4 && (
        <>
          <h1>Combien de jours par semaine ?</h1>
          <div className="stack">{DAYS.map((d) => <Option key={d} on={a.days === d} label={`${d} jours`} onClick={() => set({ days: d })} />)}</div>
        </>
      )}

      {step === 5 && (
        <>
          <h1>Combien de temps par séance ?</h1>
          <div className="stack">{MINUTES.map((m) => <Option key={m.id} on={a.minutes === m.id} label={m.label} onClick={() => set({ minutes: m.id })} />)}</div>
        </>
      )}

      {step === 6 && (
        <>
          <h1>Où t'entraînes-tu ?</h1>
          <div className="stack">{PLACES.map((p) => <Option key={p.id} on={a.place === p.id} label={p.label} onClick={() => set({ place: p.id })} />)}</div>
        </>
      )}

      {step === 7 && (
        <>
          <h1>Une zone à ne pas travailler ?</h1>
          <p className="muted small">Plusieurs choix possibles. Les exercices qui la sollicitent sortent de ton plan.</p>
          <div className="stack">
            {AVOID_ZONES.map((z) => {
              const on = (a.avoid ?? []).includes(z.id);
              return <Option key={z.id} on={on} label={z.label} onClick={() => set({ avoid: on ? (a.avoid ?? []).filter((x) => x !== z.id) : [...(a.avoid ?? []), z.id] })} />;
            })}
          </div>
        </>
      )}

      {step === 8 && (
        <>
          <h1>Ton profil</h1>
          <p className="muted small">Pour estimer les calories. Modifiable ensuite.</p>
          <label className="field">Taille (cm)
            <input className="input" inputMode="numeric" value={a.height_cm ?? ''} onChange={(e) => set({ height_cm: e.target.value ? Number(e.target.value) : undefined })} />
          </label>
          <label className="field">Poids (kg)
            <input className="input" inputMode="decimal" value={a.weight_kg ?? ''} onChange={(e) => set({ weight_kg: e.target.value ? Number(e.target.value.replace(',', '.')) : undefined })} />
          </label>
          <label className="field">Année de naissance
            <input className="input" inputMode="numeric" value={a.birth_year ?? ''} onChange={(e) => set({ birth_year: e.target.value ? Number(e.target.value) : undefined })} />
          </label>
        </>
      )}

      {error && <div className="banner error">{error}</div>}
      <div className="q-bottom">
        <button className="btn block" onClick={() => void next()} disabled={!canNext || saving}>
          {step === TOTAL_STEPS ? (saving ? 'Enregistrement...' : 'Terminer') : 'Continuer'}
        </button>
        {(step === 2 || step === 7 || step === 8) && step < TOTAL_STEPS && (
          <button className="btn ghost block" onClick={() => setStep(step + 1)}>Passer cette question</button>
        )}
      </div>
    </div>
  );
}
