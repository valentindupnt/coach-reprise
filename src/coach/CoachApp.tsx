import { useCallback, useEffect, useState } from 'react';
import type { Session } from '@supabase/supabase-js';
import { readableError, supabase } from '../lib/supabase';
import {
  isCoach,
  loadAthletes,
  loadProposals,
  loadUnreviewedAlerts,
  markReviewed,
  setLevel,
  type CoachAthlete,
  type CoachWorkout,
  type Proposal,
} from './api';
import AthleteDetail, { describeWorkout, Dot } from './AthleteDetail';
import { SESSION_META } from '../lib/plan';

function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  return (
    <main className="app">
      <div className="center-screen" style={{ alignItems: 'stretch', textAlign: 'left' }}>
        <div>
          <div className="eyebrow">Espace coach</div>
          <h1 style={{ marginTop: 8 }}>Connexion</h1>
        </div>
        <form
          className="card"
          onSubmit={async (e) => {
            e.preventDefault();
            if (!supabase) return;
            setBusy(true);
            setError(null);
            const { error: err } = await supabase.auth.signInWithPassword({ email: email.trim(), password });
            if (err) setError(readableError(err));
            setBusy(false);
          }}
        >
          <label className="field">
            E-mail
            <input className="input" type="email" autoComplete="username" required value={email} onChange={(e) => setEmail(e.target.value)} />
          </label>
          <label className="field">
            Mot de passe
            <input className="input" type="password" autoComplete="current-password" required value={password} onChange={(e) => setPassword(e.target.value)} />
          </label>
          {error && <div className="banner error" role="alert">{error}</div>}
          <button className="btn block" type="submit" disabled={busy}>{busy ? 'Connexion…' : 'Se connecter'}</button>
        </form>
      </div>
    </main>
  );
}

function hideKey(p: Proposal) {
  return `cr-hide-${p.athlete_id}-${p.exercise_id}-${p.level}`;
}
function isHidden(p: Proposal): boolean {
  try {
    const t = Number(localStorage.getItem(hideKey(p)) || 0);
    return Date.now() - t < 7 * 86_400_000;
  } catch {
    return false;
  }
}

function Dashboard({ onSignOut }: { onSignOut: () => void }) {
  const [athletes, setAthletes] = useState<CoachAthlete[] | null>(null);
  const [alerts, setAlerts] = useState<CoachWorkout[]>([]);
  const [proposals, setProposals] = useState<Proposal[]>([]);
  const [selected, setSelected] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState<string | null>(null);
  const [version, setVersion] = useState(0);

  const reload = useCallback(async () => {
    try {
      const [a, al, pr] = await Promise.all([loadAthletes(), loadUnreviewedAlerts(), loadProposals()]);
      setAthletes(a);
      setAlerts(al);
      setProposals(pr.filter((p) => !isHidden(p)));
      setSelected((s) => s ?? a[0]?.id ?? null);
      setError(null);
      setVersion((v) => v + 1);
    } catch (e) {
      setError(readableError(e));
    }
  }, []);

  useEffect(() => {
    void reload();
  }, [reload]);

  const name = (id: string) => athletes?.find((a) => a.id === id)?.first_name ?? '';

  async function act(key: string, fn: () => Promise<void>) {
    setBusy(key);
    try {
      await fn();
      await reload();
    } catch (e) {
      setError(readableError(e));
    } finally {
      setBusy(null);
    }
  }

  const frozenAthletes = (athletes ?? []).filter((a) => a.frozen);

  return (
    <main className="app wide">
      <div className="row between wrap">
        <div>
          <div className="eyebrow">Espace coach</div>
          <h1 style={{ marginTop: 8 }}>Tableau de bord</h1>
        </div>
        <div className="row">
          <button className="btn secondary small" onClick={() => void reload()}>Actualiser</button>
          <button className="btn ghost" onClick={onSignOut}>Déconnexion</button>
        </div>
      </div>

      {error && <div className="banner error" role="alert">{error}</div>}
      {!athletes && !error && <div className="spinner" aria-label="Chargement" />}

      {frozenAthletes.map((a) => (
        <div key={a.id} className="card rose">
          <h3>Programme en pause : {a.first_name}</h3>
          <p className="small">
            {a.first_name} a signalé des fourmillements, un engourdissement ou une faiblesse
            {a.frozen_at ? ` le ${new Date(a.frozen_at).toLocaleDateString('fr-FR')}` : ''}. Contacte-la avant de réactiver
            son programme (bouton dans sa fiche ci-dessous).
          </p>
        </div>
      ))}

      <div className="coach-grid">
        <section className="card" aria-labelledby="alerts-title">
          <div className="row between">
            <h2 id="alerts-title">Alertes</h2>
            <span className={`pill ${alerts.length ? 'red' : 'sage'}`}>{alerts.length}</span>
          </div>
          {alerts.length === 0 && <p className="small muted">Rien à signaler.</p>}
          {alerts.map((w) => (
            <div key={w.id} className="list-row" style={{ alignItems: 'flex-start' }}>
              <div className="grow">
                <div style={{ fontWeight: 700 }}>
                  <Dot color={w.neuro ? 'var(--clay)' : w.pain > 3 || w.workout_items.some((i) => i.feeling === 'douleur') ? 'var(--rose-fig)' : 'var(--sage-mid)'} />
                  {name(w.athlete_id)} · {SESSION_META[w.session_key].title}
                </div>
                <div className="small muted">{describeWorkout(w)}</div>
                {w.comment && <div className="small" style={{ marginTop: 4 }}>« {w.comment} »</div>}
              </div>
              <button className="btn secondary small" disabled={busy === w.id} onClick={() => void act(w.id, () => markReviewed([w.id]))}>
                Vu
              </button>
            </div>
          ))}
        </section>

        <section className="card" aria-labelledby="prop-title">
          <div className="row between">
            <h2 id="prop-title">À valider</h2>
            <span className="pill sage">{proposals.length}</span>
          </div>
          {proposals.length === 0 && <p className="small muted">Aucune proposition de montée de niveau.</p>}
          {proposals.map((p) => (
            <div key={`${p.athlete_id}-${p.exercise_id}`} className="list-row" style={{ alignItems: 'flex-start' }}>
              <div className="grow">
                <div style={{ fontWeight: 700 }}>{p.first_name} · {p.exercise_name}</div>
                <div className="small muted">
                  « Trop facile » 2 fois de suite, sans douleur. Niveau {p.level} → {p.level + 1}
                </div>
              </div>
              <div className="stack">
                <button
                  className="btn small"
                  disabled={busy === p.exercise_id}
                  onClick={() => void act(p.exercise_id, () => setLevel(p.athlete_id, p.exercise_id, p.level + 1, 'Validé : trop facile 2 fois'))}
                >
                  Valider
                </button>
                <button
                  className="btn ghost"
                  onClick={() => {
                    try {
                      localStorage.setItem(hideKey(p), String(Date.now()));
                    } catch {
                      /* ignoré */
                    }
                    setProposals((ps) => ps.filter((x) => x !== p));
                  }}
                >
                  Plus tard
                </button>
              </div>
            </div>
          ))}
        </section>
      </div>

      {athletes && athletes.length > 1 && (
        <div className="row wrap">
          {athletes.map((a) => (
            <button key={a.id} className={`btn small ${selected === a.id ? '' : 'secondary'}`} onClick={() => setSelected(a.id)}>
              {a.first_name}
            </button>
          ))}
        </div>
      )}
      {athletes && athletes.length === 0 && (
        <div className="card">
          <p>Aucune athlète pour le moment. Lance le script <code>supabase/seed.sql</code> pour créer Alice.</p>
        </div>
      )}

      {selected && athletes?.find((a) => a.id === selected) && (
        <AthleteDetail key={selected} refreshKey={version} athlete={athletes.find((a) => a.id === selected)!} onChanged={reload} />
      )}
    </main>
  );
}

export default function CoachApp() {
  const [session, setSession] = useState<Session | null | undefined>(undefined);
  const [allowed, setAllowed] = useState<boolean | null>(null);
  const [checkError, setCheckError] = useState<string | null>(null);

  useEffect(() => {
    if (!supabase) return;
    void supabase.auth.getSession().then(({ data }) => setSession(data.session));
    const { data: sub } = supabase.auth.onAuthStateChange((_e, s) => setSession(s));
    return () => sub.subscription.unsubscribe();
  }, []);

  useEffect(() => {
    if (!session) {
      setAllowed(null);
      return;
    }
    setCheckError(null);
    isCoach()
      .then(setAllowed)
      .catch((e: unknown) => {
        const msg = e && typeof e === 'object' && 'message' in e ? String((e as { message: unknown }).message) : String(e);
        setCheckError(msg);
        setAllowed(false);
      });
  }, [session]);

  const signOut = () => void supabase?.auth.signOut();

  if (session === undefined) {
    return <main className="app"><div className="center-screen"><div className="spinner" aria-label="Chargement" /></div></main>;
  }
  if (!session) return <Login />;
  if (allowed === null) {
    return <main className="app"><div className="center-screen"><div className="spinner" aria-label="Vérification" /></div></main>;
  }
  if (!allowed) {
    return (
      <main className="app">
        <div className="center-screen">
          <h2>Accès refusé</h2>
          {checkError ? (
            <>
              <p className="muted">La vérification du compte a échoué. Message technique à transmettre :</p>
              <code style={{ background: 'var(--sand)', padding: '8px 12px', borderRadius: 8, fontSize: 13, wordBreak: 'break-word' }}>{checkError}</code>
            </>
          ) : (
            <p className="muted">
              Connecté en tant que <strong>{session.user.email}</strong>, mais ce compte n'est pas enregistré comme coach.
              Voir l'étape « Te déclarer coach » du guide de mise en ligne.
            </p>
          )}
          <button className="btn secondary" onClick={signOut}>Déconnexion</button>
        </div>
      </main>
    );
  }
  return <Dashboard onSignOut={signOut} />;
}
