import { useEffect, useState } from 'react';
import { DEFAULT_WEEK, SLOT_LABEL, currentWeekPlan } from '../lib/plan';
import type { WeekSlot } from '../lib/types';
import { setAllowSwaps, setCoachWeekPlan, setLevelupMode, type CoachAthlete } from './api';

interface Props {
  athlete: CoachAthlete;
  busy: string | null;
  act: (key: string, fn: () => Promise<void>) => Promise<void>;
}

const DAYS = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

/** Réglages d'autonomie : changer d'exercice, monter de niveau, organiser la semaine. */
export default function AutonomyCard({ athlete, busy, act }: Props) {
  const saved = currentWeekPlan(athlete.week_plan);
  const [plan, setPlan] = useState<WeekSlot[]>(saved);
  useEffect(() => setPlan(currentWeekPlan(athlete.week_plan)), [athlete.week_plan]);
  const dirty = plan.some((p, i) => p !== saved[i]);
  const self = athlete.levelup_mode === 'self';
  const name = athlete.first_name;

  return (
    <div className="card">
      <h3>Autonomie de {name}</h3>

      <label className="row" style={{ gap: 10 }}>
        <input
          type="checkbox"
          checked={athlete.allow_swaps}
          disabled={busy === 'allow'}
          onChange={(e) => void act('allow', () => setAllowSwaps(athlete.id, e.target.checked))}
        />
        <span className="small">
          <strong>{name} peut changer un exercice elle-même</strong> (propositions pendant et après la séance).
          Décoche pour garder la main : elle pourra seulement passer l'exercice.
        </span>
      </label>

      <fieldset style={{ border: 0, margin: 0, padding: 0 }}>
        <legend className="small" style={{ fontWeight: 700, marginBottom: 6 }}>Qui choisit le niveau des exercices ?</legend>
        <label className="row" style={{ gap: 10, alignItems: 'flex-start' }}>
          <input
            type="radio"
            name={`levelup-${athlete.id}`}
            checked={self}
            disabled={busy === 'levelup'}
            onChange={() => void act('levelup', () => setLevelupMode(athlete.id, 'self'))}
          />
          <span className="small">
            <strong>{name} choisit librement</strong> (par défaut). Elle monte ou redescend quand elle veut, sans condition :
            depuis l'écran Progrès ou pendant la séance avec « Plus dur » / « Plus facile ». Après deux séances « trop
            facile », l'app monte aussi toute seule. Seules protections qui restent : une douleur sur un exercice le fait
            redescendre d'un niveau, et un symptôme (fourmillements, faiblesse) met le programme en pause. Tout est noté au
            journal des niveaux.
          </span>
        </label>
        <label className="row" style={{ gap: 10, alignItems: 'flex-start', marginTop: 6 }}>
          <input
            type="radio"
            name={`levelup-${athlete.id}`}
            checked={!self}
            disabled={busy === 'levelup'}
            onChange={() => void act('levelup', () => setLevelupMode(athlete.id, 'coach'))}
          />
          <span className="small">
            <strong>Moi, après proposition.</strong> {name} ne peut pas changer de niveau ; les propositions apparaissent
            dans « À valider ».
          </span>
        </label>
      </fieldset>

      <div>
        <div className="small" style={{ fontWeight: 700, marginBottom: 6 }}>Semaine type</div>
        <p className="tiny muted">
          {name} peut aussi la modifier elle-même (4 jours de renforcement au maximum). Ici tu n'as pas de limite.
        </p>
        <div className="filter-row">
          {DAYS.map((d, i) => (
            <label key={d} className="field">
              {d}
              <select
                className="input"
                value={plan[i]}
                onChange={(e) => setPlan((p) => p.map((x, j) => (j === i ? (e.target.value as WeekSlot) : x)))}
              >
                {(['A', 'B', 'AB', 'M', 'C', 'R'] as WeekSlot[]).map((o) => (
                  <option key={o} value={o}>{SLOT_LABEL[o]}</option>
                ))}
              </select>
            </label>
          ))}
        </div>
        <div className="row wrap">
          <button className="btn small" disabled={!dirty || busy === 'plan'} onClick={() => void act('plan', () => setCoachWeekPlan(athlete.id, plan))}>
            Enregistrer la semaine
          </button>
          <button
            className="btn secondary small"
            disabled={busy === 'plan' || (athlete.week_plan === null && !dirty)}
            onClick={() => void act('plan', async () => { await setCoachWeekPlan(athlete.id, null); setPlan(DEFAULT_WEEK); })}
          >
            Semaine par défaut
          </button>
        </div>
      </div>
    </div>
  );
}
