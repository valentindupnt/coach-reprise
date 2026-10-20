import { useCallback, useEffect, useMemo, useState } from 'react';
import Player, { type SessionResult } from './Player';
import LibraryBrowser from '../components/LibraryBrowser';
import Feedback, { type FeedbackValue } from './Feedback';
import { FrozenScreen, SafetyCard } from './Safety';
import {
  fetchAthlete,
  fetchLibrary,
  fetchSwapOptions,
  flushPending,
  newClientId,
  pendingWorkouts,
  readCache,
  readLibraryCache,
  submitWorkout,
} from '../lib/athleteApi';
import { suggestSwaps } from '../lib/library';
import { readableError } from '../lib/supabase';
import type { AthleteData, Library, ProgramItem, ProgramSessionKey, SessionKey, SubmitResult, SwapOption } from '../lib/types';
import {
  DAY_NAMES,
  PHASES,
  SESSION_META,
  currentLevel,
  estimateMinutes,
  itemsForSession,
  localDay,
  phaseForWeek,
  planForDate,
  programWeek,
} from '../lib/plan';

type Tab = 'today' | 'week' | 'library' | 'progress';
type Screen =
  | { name: 'tabs' }
  | { name: 'player'; session: ProgramSessionKey }
  | { name: 'cardio' }
  | { name: 'feedback'; session: SessionKey; played: SessionResult | null }
  | { name: 'result'; result: SubmitResult | null; queued: boolean; pain: number; swapNames: string[] };

function startOfWeek(d: Date): Date {
  const x = new Date(d.getFullYear(), d.getMonth(), d.getDate());
  const day = (x.getDay() + 6) % 7; // lundi = 0
  x.setDate(x.getDate() - day);
  return x;
}

export default function AthleteApp({ token }: { token: string }) {
  const [data, setData] = useState<AthleteData | null>(() => readCache(token));
  const [library, setLibrary] = useState<Library | null>(() => readLibraryCache(token));
  const [loadError, setLoadError] = useState<string | null>(null);
  const [offline, setOffline] = useState(false);
  const [tab, setTab] = useState<Tab>('today');
  const [screen, setScreen] = useState<Screen>({ name: 'tabs' });
  const [submitting, setSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [pendingCount, setPendingCount] = useState(() => pendingWorkouts(token).length);

  const refresh = useCallback(async () => {
    try {
      if (pendingWorkouts(token).length) {
        await flushPending(token);
        setPendingCount(pendingWorkouts(token).length);
      }
      const d = await fetchAthlete(token);
      setData(d);
      setLoadError(null);
      setOffline(false);
      // la bibliothèque sert hors ligne (propositions de remplacement) : on la garde à jour, sans bloquer
      void fetchLibrary(token).then(setLibrary).catch(() => undefined);
    } catch (e) {
      const msg = readableError(e);
      if (/connexion/.test(msg)) setOffline(true);
      else setLoadError(msg);
    }
  }, [token]);

  useEffect(() => {
    void refresh();
    const onOnline = () => void refresh();
    const onVisible = () => {
      if (document.visibilityState === 'visible') void refresh();
    };
    window.addEventListener('online', onOnline);
    document.addEventListener('visibilitychange', onVisible);
    return () => {
      window.removeEventListener('online', onOnline);
      document.removeEventListener('visibilitychange', onVisible);
    };
  }, [refresh]);

  useEffect(() => {
    window.scrollTo(0, 0);
  }, [screen.name, tab]);

  const now = new Date();
  const week = data ? programWeek(data.athlete.start_date, now) : 1;
  const phase = phaseForWeek(week);
  const today = planForDate(now, week);

  const doneDays = useMemo(() => {
    const s = new Set<string>();
    data?.workouts.forEach((w) => s.add(localDay(new Date(w.done_at))));
    return s;
  }, [data]);

  if (loadError && !data) {
    return (
      <main className="app">
        <div className="center-screen">
          <h2>Lien non reconnu</h2>
          <p className="muted">{loadError}</p>
        </div>
      </main>
    );
  }
  if (!data) {
    return (
      <main className="app">
        <div className="center-screen">
          {offline ? (
            <>
              <h2>Pas de connexion</h2>
              <p className="muted">Connecte-toi à internet pour charger ton programme la première fois.</p>
              <button className="btn" onClick={() => void refresh()}>Réessayer</button>
            </>
          ) : (
            <>
              <div className="spinner" aria-label="Chargement" />
              <p className="muted">Chargement de ton programme…</p>
            </>
          )}
        </div>
      </main>
    );
  }

  const first = data.athlete.first_name;
  const frozen = data.athlete.frozen;

  async function handleSubmit(session: SessionKey, v: FeedbackValue) {
    setSubmitting(true);
    setSubmitError(null);
    try {
      const { result, queued } = await submitWorkout(token, {
        client_id: newClientId(),
        session,
        pain: v.pain,
        neuro: v.neuro,
        items: v.items,
        comment: v.comment,
        created_at: new Date().toISOString(),
        rpe: v.rpe,
        duration_min: v.duration_min,
        swaps: v.swaps,
      });
      setPendingCount(pendingWorkouts(token).length);
      const nameOf = (id: string) =>
        data?.program.find((p) => p.exercise.id === id)?.exercise.name ?? library?.exercises.find((e) => e.id === id)?.name ?? id;
      const swapNames = v.swaps.map((s) => `${nameOf(s.from)} → ${nameOf(s.to)}`);
      setScreen({ name: 'result', result, queued, pain: v.pain, swapNames });
      if (v.neuro) setData((d) => (d ? { ...d, athlete: { ...d.athlete, frozen: true } } : d));
      if (!queued) void refresh();
    } catch (e) {
      setSubmitError(readableError(e));
    } finally {
      setSubmitting(false);
    }
  }

  /** Propositions de remplacement : la base d'abord, la bibliothèque du téléphone hors ligne. */
  async function loadOptions(session: ProgramSessionKey, item: ProgramItem): Promise<SwapOption[]> {
    try {
      return await fetchSwapOptions(token, session, item.exercise.id, 2);
    } catch {
      return suggestSwaps(library?.exercises ?? [], item.exercise, itemsForSession(data!.program, session), [], 2);
    }
  }

  const goHome = () => {
    setTab('today');
    setScreen({ name: 'tabs' });
  };

  // ---------- Écrans plein écran ----------
  if (screen.name === 'player') {
    const items = itemsForSession(data.program, screen.session);
    return (
      <main className="app">
        <Player
          token={token}
          session={screen.session}
          items={items}
          rounds={phase.rounds}
          library={library?.exercises ?? []}
          allowSwaps={data.athlete.allow_swaps}
          onCancel={() => setScreen({ name: 'tabs' })}
          onFinish={(played) => setScreen({ name: 'feedback', session: screen.session, played })}
        />
      </main>
    );
  }

  if (screen.name === 'cardio') {
    return (
      <main className="app">
        <button className="btn ghost" style={{ alignSelf: 'flex-start' }} onClick={() => setScreen({ name: 'tabs' })}>← Retour</button>
        <div>
          <div className="eyebrow">Sans impact</div>
          <h1 style={{ marginTop: 8 }}>{SESSION_META.C.title}</h1>
        </div>
        <div className="card">
          <p><strong>20 à 30 min</strong> de marche, de vélo tranquille ou de natation douce.</p>
          <p className="small muted">Tu dois pouvoir parler en faisant des phrases complètes. Pas de course ni de sauts pour le moment.</p>
          <p className="small muted">Termine par 5 min de mobilité douce si tu en as envie.</p>
        </div>
        <SafetyCard />
        <button className="btn block" onClick={() => setScreen({ name: 'feedback', session: 'C', played: null })}>
          J'ai terminé
        </button>
      </main>
    );
  }

  if (screen.name === 'feedback') {
    const fbSession = screen.session;
    return (
      <main className="app">
        <Feedback
          session={fbSession}
          entries={screen.played?.entries ?? []}
          durationMin={screen.played?.durationMin ?? null}
          allowSwaps={data.athlete.allow_swaps}
          submitting={submitting}
          error={submitError}
          loadOptions={(item) => loadOptions(item.session_key, item)}
          onSubmit={(v) => void handleSubmit(fbSession, v)}
        />
      </main>
    );
  }

  if (screen.name === 'result') {
    const r = screen.result;
    const isFrozen = r?.frozen || frozen;
    if (isFrozen) {
      return (
        <main className="app">
          <FrozenScreen firstName={first} />
          <button className="btn secondary block" onClick={goHome}>Retour à l'accueil</button>
        </main>
      );
    }
    const regressedNames = (r?.regressed ?? []).map((x) => {
      const it = data.program.find((p) => p.exercise.id === x.exercise_id);
      return `${it?.exercise.name ?? x.exercise_id} (niveau ${x.to_level})`;
    });
    return (
      <main className="app">
        <div className="center-screen" style={{ minHeight: '40dvh' }}>
          <div className="eyebrow">Séance enregistrée</div>
          <h1>Bravo {first} !</h1>
        </div>
        {screen.queued && (
          <div className="banner warn">
            Pas de réseau : ta séance est gardée sur ton téléphone. Elle sera envoyée automatiquement dès que tu seras
            connectée.
          </div>
        )}
        {screen.swapNames.length > 0 && (
          <div className="card sage">
            <h3>Programme adapté</h3>
            <p className="small">{screen.swapNames.join(' · ')}. Ton coach est prévenu et peut revenir en arrière.</p>
          </div>
        )}
        {regressedNames.length > 0 && (
          <div className="card rose">
            <h3>On allège un peu</h3>
            <p className="small">
              Suite à la douleur signalée, on revient d'un niveau sur : {regressedNames.join(', ')}. C'est normal et
              ça fait partie du plan.
            </p>
          </div>
        )}
        {screen.pain > 3 && (
          <div className="card amber">
            <h3>Douleur au-dessus de 3</h3>
            <p className="small">
              À la prochaine séance, réduis l'amplitude et va plus lentement. Si la douleur ne revient pas à la normale
              d'ici demain, parles-en à ton coach ou à ton kiné.
            </p>
          </div>
        )}
        {regressedNames.length === 0 && screen.pain <= 3 && (
          <div className="card sage">
            <p>Une séance de plus. La régularité, c'est ce qui fait la différence.</p>
          </div>
        )}
        <button className="btn block" onClick={goHome}>Retour à l'accueil</button>
      </main>
    );
  }

  // ---------- Onglets ----------
  const weekStart = startOfWeek(now);
  const weekDays = Array.from({ length: 7 }, (_, i) => {
    const d = new Date(weekStart);
    d.setDate(weekStart.getDate() + i);
    return d;
  });
  const todayKey = localDay(now);
  const doneToday = doneDays.has(todayKey);
  const autoChanges = data.recent_changes.filter(
    (c) => c.source === 'auto' && Date.now() - new Date(c.created_at).getTime() < 7 * 86_400_000,
  );
  const coachUps = data.recent_changes.filter(
    (c) => c.source === 'coach' && c.to_level > c.from_level && Date.now() - new Date(c.created_at).getTime() < 7 * 86_400_000,
  );
  const exName = (id: string) =>
    data.program.find((p) => p.exercise.id === id)?.exercise.name ?? library?.exercises.find((e) => e.id === id)?.name ?? id;

  const minutesLabel = (s: SessionKey, fallback: string) =>
    s === 'C' ? fallback : `≈ ${estimateMinutes(data.program, s, phase.rounds)} min`;

  const startSession = (s: SessionKey) => (s === 'C' ? setScreen({ name: 'cardio' }) : setScreen({ name: 'player', session: s }));

  return (
    <>
      <main className="app">
        {offline && <div className="banner warn">Hors connexion : tu vois la dernière version de ton programme.</div>}
        {pendingCount > 0 && (
          <div className="banner warn">
            {pendingCount} séance{pendingCount > 1 ? 's' : ''} en attente d'envoi.{' '}
            <button className="btn ghost" style={{ minHeight: 0, padding: 0 }} onClick={() => void refresh()}>Réessayer</button>
          </div>
        )}

        {tab === 'today' && (
          frozen ? (
            <FrozenScreen firstName={first} />
          ) : (
            <>
              <div>
                <div className="eyebrow">Semaine {week} · {phase.name}</div>
                <h1 style={{ marginTop: 8 }}>Bonjour {first} !</h1>
              </div>

              {data.athlete.coach_message && (
                <div className="card sage">
                  <div className="eyebrow" style={{ color: 'var(--sage-ink)' }}>Le mot de ton coach</div>
                  <p style={{ whiteSpace: 'pre-line' }}>{data.athlete.coach_message}</p>
                </div>
              )}

              {coachUps.length > 0 && (
                <div className="card sage">
                  <h3>Nouveau niveau débloqué</h3>
                  <p className="small">{coachUps.map((c) => `${exName(c.exercise_id)} : niveau ${c.to_level}`).join(' · ')}</p>
                </div>
              )}
              {autoChanges.length > 0 && (
                <div className="banner error">
                  On a allégé : {autoChanges.map((c) => `${exName(c.exercise_id)} (niveau ${c.to_level})`).join(', ')}.
                </div>
              )}

              <div className="card">
                <div className="row between">
                  <span className={`pill ${SESSION_META[today.session].tone === 'rose' ? 'rose' : SESSION_META[today.session].tone === 'sage' ? 'sage' : ''}`}>
                    Aujourd'hui · {minutesLabel(today.session, today.minutes)}
                  </span>
                  {doneToday && <span className="pill sage">Fait ✓</span>}
                </div>
                <h2>{today.title}</h2>
                <p className="muted small">{today.detail}</p>
                {today.session !== 'C' && today.session !== 'M' && (
                  <p className="small muted">{phase.rounds} tours · {phase.detail}</p>
                )}
                <button className="btn block" onClick={() => startSession(today.session)}>
                  {doneToday ? 'Refaire une séance' : 'Commencer'}
                </button>
              </div>

              <div className="card">
                <h3>Ma semaine</h3>
                <div className="week-dots">
                  {weekDays.map((d) => {
                    const k = localDay(d);
                    const done = doneDays.has(k);
                    return (
                      <div key={k} className="week-dot">
                        <span className={`${done ? 'done' : ''} ${k === todayKey ? 'today' : ''}`} aria-label={`${DAY_NAMES[d.getDay()]} ${done ? 'séance faite' : 'pas de séance'}`}>
                          {done ? '✓' : ''}
                        </span>
                        {DAY_NAMES[d.getDay()].slice(0, 1)}
                      </div>
                    );
                  })}
                </div>
              </div>
              <div className="banner info">Une semaine moyenne répétée vaut mieux qu'une semaine parfaite isolée.</div>
            </>
          )
        )}

        {tab === 'week' && (
          <>
            <div>
              <div className="eyebrow">Semaine type</div>
              <h1 style={{ marginTop: 8 }}>Mes séances</h1>
            </div>
            <div className="stack">
              {weekDays.map((d) => {
                const p = planForDate(d, week);
                const tone = SESSION_META[p.session].tone;
                const k = localDay(d);
                return (
                  <button key={k} className={`day-tile ${k === todayKey ? 'today' : ''}`} disabled={frozen} onClick={() => startSession(p.session)}>
                    <span className={`day-badge tone-${tone}`}>{DAY_NAMES[d.getDay()]}</span>
                    <span className="grow">
                      <span style={{ display: 'block', fontWeight: 700 }}>{p.title}</span>
                      <span className="small muted">{p.detail}</span>
                    </span>
                    <span className="tiny muted">{doneDays.has(k) ? '✓' : minutesLabel(p.session, p.minutes)}</span>
                  </button>
                );
              })}
            </div>
            <h2 style={{ marginTop: 8 }}>Faire une autre séance</h2>
            <div className="stack">
              {(['A', 'B', 'M', 'C'] as SessionKey[]).map((s) => (
                <button key={s} className="day-tile" disabled={frozen} onClick={() => startSession(s)}>
                  <span className={`day-badge tone-${SESSION_META[s].tone}`}>{s === 'C' ? '♡' : s}</span>
                  <span className="grow">
                    <span style={{ display: 'block', fontWeight: 700 }}>{SESSION_META[s].title}</span>
                    <span className="small muted">{SESSION_META[s].subtitle}</span>
                  </span>
                </button>
              ))}
            </div>
            <h2 style={{ marginTop: 8 }}>Écoute ton corps</h2>
            <SafetyCard />
          </>
        )}

        {tab === 'library' && (
          <>
            <div>
              <div className="eyebrow">Tous les exercices</div>
              <h1 style={{ marginTop: 8 }}>Bibliothèque</h1>
              <p className="muted" style={{ marginTop: 8 }}>
                Les exercices validés par ton coach, avec les variantes. Pour changer un exercice de ton programme, demande-lui ou
                choisis une proposition pendant ou après la séance.
              </p>
            </div>
            {library ? (
              <LibraryBrowser exercises={library.exercises} inProgram={library.in_program} />
            ) : (
              <p className="small muted">La bibliothèque se charge quand tu es connectée à internet.</p>
            )}
          </>
        )}

        {tab === 'progress' && (
          <>
            <div>
              <div className="eyebrow">8 semaines</div>
              <h1 style={{ marginTop: 8 }}>Ma progression</h1>
              <p className="muted" style={{ marginTop: 8 }}>
                {data.workouts.length} séance{data.workouts.length > 1 ? 's' : ''} enregistrée{data.workouts.length > 1 ? 's' : ''}. On avance par petites marches.
              </p>
            </div>
            <div className="stack">
              {PHASES.map((p, i) => {
                const active = (i === 0 && week <= 2) || (i === 1 && (week === 3 || week === 4)) || (i === 2 && (week === 5 || week === 6)) || (i === 3 && week >= 7);
                return (
                  <div key={p.weeks} className="day-tile" style={active ? { boxShadow: 'inset 0 0 0 2px var(--sage-strong)' } : undefined}>
                    <span style={{ width: 70, fontWeight: 700, fontSize: 13, color: 'var(--sage-ink)' }}>Sem. {p.weeks}</span>
                    <span className="grow">
                      <span style={{ display: 'block', fontWeight: 700 }}>{p.name}</span>
                      <span className="small muted">{p.detail}</span>
                    </span>
                  </div>
                );
              })}
            </div>
            {data.workouts.length > 0 && (
              <div className="card">
                <h3>Mes dernières séances</h3>
                {data.workouts.slice(0, 6).map((w, i) => (
                  <div key={i} className="list-row">
                    <div className="grow">
                      <div style={{ fontWeight: 700 }}>{SESSION_META[w.session_key].title}</div>
                      <div className="small muted">
                        {new Date(w.done_at).toLocaleDateString('fr-FR', { weekday: 'short', day: 'numeric', month: 'short' })}
                        {w.duration_min ? ` · ${w.duration_min} min` : ''}
                        {w.rpe != null ? ` · effort ${w.rpe}/10` : ''}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
            {(['A', 'B', 'M'] as ProgramSessionKey[]).map((s) => (
              <div key={s} className="card">
                <h3>{SESSION_META[s].title}</h3>
                {itemsForSession(data.program, s).map((it) => (
                  <div key={it.exercise.id} className="list-row" style={{ alignItems: 'flex-start' }}>
                    <div className="grow">
                      <div style={{ fontWeight: 700 }}>{it.exercise.name}</div>
                      <div className="small muted">{currentLevel(it).label}</div>
                    </div>
                    <div className="levels" aria-label={`Niveau ${it.level} sur ${it.exercise.levels.length}`}>
                      {it.exercise.levels.map((_, i) => (
                        <span key={i} className={`level-dot ${i < it.level ? 'on' : ''}`}>{i + 1}</span>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            ))}
            <div className="card sage">
              <h3>Prête pour le niveau suivant ?</h3>
              <ul className="small" style={{ margin: 0, paddingLeft: 18 }}>
                <li>Douleur à 3 sur 10 maximum, normale le lendemain</li>
                <li>Aucun fourmillement ni faiblesse</li>
                <li>« Trop facile » sur 2 séances de suite</li>
              </ul>
              <p className="small">Ton coach valide chaque nouveau niveau.</p>
            </div>
          </>
        )}
      </main>

      <nav className="tabbar" aria-label="Navigation">
        <button aria-current={tab === 'today' ? 'page' : undefined} onClick={() => setTab('today')}>Aujourd'hui</button>
        <button aria-current={tab === 'week' ? 'page' : undefined} onClick={() => setTab('week')}>Séances</button>
        <button aria-current={tab === 'library' ? 'page' : undefined} onClick={() => setTab('library')}>Exercices</button>
        <button aria-current={tab === 'progress' ? 'page' : undefined} onClick={() => setTab('progress')}>Progrès</button>
      </nav>
    </>
  );
}
