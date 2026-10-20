import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import Figure from '../components/Figure';
import { fetchSwapOptions } from '../lib/athleteApi';
import { WHY_LABEL, ZONE_LABEL, label, suggestSwaps } from '../lib/library';
import type { Exercise, ProgramItem, ProgramSessionKey, SwapOption } from '../lib/types';
import { BLOCK_LABEL, buildSteps, currentLevel, formatSeconds, SESSION_META, totalMinutes } from '../lib/plan';

export type EntryStatus = 'done' | 'skipped' | 'painful';

/** Ce qui s'est réellement passé pour un exercice pendant la séance. */
export interface SessionEntry {
  item: ProgramItem;
  status: EntryStatus;
  /** Exercice du programme que celui-ci remplace pendant la séance. */
  replacedFrom?: string;
}

export interface SessionResult {
  durationMin: number;
  entries: SessionEntry[];
  /** Vrai si la séance est allée jusqu'à la dernière étape. */
  completed: boolean;
}

interface Props {
  token: string;
  session: ProgramSessionKey;
  items: ProgramItem[];
  rounds: number;
  library: Exercise[];
  allowSwaps: boolean;
  onFinish: (result: SessionResult) => void;
  onCancel: () => void;
}

/** Petit bip de fin d'intervalle (silencieux si le navigateur refuse). */
function useBeep() {
  const ctx = useRef<AudioContext | null>(null);
  const unlock = useCallback(() => {
    try {
      if (!ctx.current) {
        const AC = window.AudioContext || (window as unknown as { webkitAudioContext?: typeof AudioContext }).webkitAudioContext;
        if (AC) ctx.current = new AC();
      }
      void ctx.current?.resume();
    } catch {
      /* pas de son, pas grave */
    }
  }, []);
  const beep = useCallback((freq = 880, ms = 180) => {
    try {
      const c = ctx.current;
      if (!c) return;
      const o = c.createOscillator();
      const g = c.createGain();
      o.frequency.value = freq;
      g.gain.setValueAtTime(0.0001, c.currentTime);
      g.gain.exponentialRampToValueAtTime(0.25, c.currentTime + 0.02);
      g.gain.exponentialRampToValueAtTime(0.0001, c.currentTime + ms / 1000);
      o.connect(g).connect(c.destination);
      o.start();
      o.stop(c.currentTime + ms / 1000 + 0.05);
    } catch {
      /* ignoré */
    }
  }, []);
  return { unlock, beep };
}

/** Garde l'écran allumé pendant la séance quand c'est possible. */
function useWakeLock(active: boolean) {
  useEffect(() => {
    if (!active) return;
    let lock: { release: () => Promise<void> } | null = null;
    let cancelled = false;
    const request = async () => {
      try {
        const nav = navigator as unknown as { wakeLock?: { request: (t: 'screen') => Promise<{ release: () => Promise<void> }> } };
        if (nav.wakeLock) {
          const l = await nav.wakeLock.request('screen');
          if (cancelled) void l.release();
          else lock = l;
        }
      } catch {
        /* non supporté */
      }
    };
    void request();
    const onVis = () => {
      if (document.visibilityState === 'visible') void request();
    };
    document.addEventListener('visibilitychange', onVis);
    return () => {
      cancelled = true;
      document.removeEventListener('visibilitychange', onVis);
      void lock?.release().catch(() => undefined);
    };
  }, [active]);
}

type ChooserMode = 'pain' | 'unsuited';
interface Chooser {
  mode: ChooserMode;
  item: ProgramItem;
  options: SwapOption[] | null; // null = chargement
}

export default function Player({ token, session, items, rounds, library, allowSwaps, onFinish, onCancel }: Props) {
  // exercices remplacés pendant la séance : identifiant d'origine -> exercice choisi
  const [replaced, setReplaced] = useState<Record<string, ProgramItem>>({});
  const [skipped, setSkipped] = useState<string[]>([]);
  const [painful, setPainful] = useState<string[]>([]);
  const effective = useMemo(() => items.map((it) => replaced[it.exercise.id] ?? it), [items, replaced]);
  const steps = useMemo(() => buildSteps(effective, session, rounds), [effective, session, rounds]);

  const [started, setStarted] = useState(false);
  const [index, setIndex] = useState(0);
  const [running, setRunning] = useState(false);
  const [remainingMs, setRemainingMs] = useState(() => (steps[0]?.seconds ?? 0) * 1000);
  const [confirmStop, setConfirmStop] = useState(false);
  const [chooser, setChooser] = useState<Chooser | null>(null);
  const endsAt = useRef<number | null>(null);
  const startedAt = useRef<number>(Date.now());
  const { unlock, beep } = useBeep();
  useWakeLock(started);

  const step = steps[index];
  const isSkipped = useCallback((i: number) => skipped.includes(steps[i]?.item.exercise.id ?? ''), [skipped, steps]);

  /** Résumé de la séance à l'instant où elle se termine, à l'étape `at`. */
  const finish = useCallback(
    (at: number, skippedNow = skipped, painfulNow = painful) => {
      setRunning(false);
      endsAt.current = null;
      const doneCount = (id: string) =>
        steps.slice(0, Math.min(at, steps.length)).filter((s) => s.kind === 'work' && s.item.exercise.id === id).length;
      const entries: SessionEntry[] = [];
      for (const orig of items) {
        const origId = orig.exercise.id;
        const swapped = replaced[origId];
        if (swapped) {
          entries.push({ item: orig, status: painfulNow.includes(origId) ? 'painful' : 'skipped' });
          if (doneCount(swapped.exercise.id) > 0 && !skippedNow.includes(swapped.exercise.id)) {
            entries.push({ item: swapped, status: painfulNow.includes(swapped.exercise.id) ? 'painful' : 'done', replacedFrom: origId });
          }
        } else if (painfulNow.includes(origId)) {
          entries.push({ item: orig, status: 'painful' });
        } else if (skippedNow.includes(origId)) {
          if (orig.block === 'main') entries.push({ item: orig, status: 'skipped' });
        } else if (doneCount(origId) > 0 && orig.block === 'main') {
          entries.push({ item: orig, status: 'done' });
        }
      }
      onFinish({
        durationMin: Math.max(1, Math.round((Date.now() - startedAt.current) / 60_000)),
        entries,
        completed: at >= steps.length,
      });
    },
    [items, replaced, skipped, painful, steps, onFinish],
  );

  const goTo = useCallback(
    (i: number, autoRun: boolean, dir: 1 | -1 = 1, skippedNow = skipped) => {
      let j = Math.max(0, i);
      while (j >= 0 && j < steps.length && skippedNow.includes(steps[j].item.exercise.id)) j += dir;
      if (j < 0) j = 0;
      if (j >= steps.length) {
        finish(steps.length, skippedNow);
        return;
      }
      const next = steps[j];
      setIndex(j);
      setRemainingMs(next.seconds * 1000);
      if (autoRun) {
        endsAt.current = Date.now() + next.seconds * 1000;
        setRunning(true);
      } else {
        endsAt.current = null;
        setRunning(false);
      }
    },
    [steps, skipped, finish],
  );

  // Minuteur basé sur l'heure réelle : reste juste même si l'écran se met en veille.
  useEffect(() => {
    if (!running) return;
    const id = window.setInterval(() => {
      if (endsAt.current == null) return;
      const left = endsAt.current - Date.now();
      if (left <= 0) {
        beep(step?.kind === 'work' ? 660 : 990, 260);
        goTo(index + 1, true);
      } else {
        setRemainingMs(left);
      }
    }, 200);
    return () => window.clearInterval(id);
  }, [running, index, goTo, beep, step?.kind]);

  const pauseTimer = () => {
    setRunning(false);
    endsAt.current = null;
  };

  /** Ouvre la fenêtre de remplacement ; le minuteur se met en pause. */
  async function openChooser(mode: ChooserMode) {
    if (!step) return;
    pauseTimer();
    const item = step.item;
    setChooser({ mode, item, options: allowSwaps ? null : [] });
    if (!allowSwaps) return;
    let options: SwapOption[];
    try {
      options = await fetchSwapOptions(token, session, item.exercise.id, 2);
    } catch {
      // hors ligne : mêmes règles, calculées sur la bibliothèque gardée sur le téléphone
      options = suggestSwaps(library, item.exercise, effective, painful, 2);
    }
    setChooser((c) => (c && c.item.exercise.id === item.exercise.id ? { ...c, options } : c));
  }

  function pickOption(opt: SwapOption) {
    if (!chooser) return;
    const orig = chooser.item;
    const origKey = items.find((it) => (replaced[it.exercise.id] ?? it).exercise.id === orig.exercise.id)?.exercise.id ?? orig.exercise.id;
    const replacement: ProgramItem = { ...orig, exercise: opt.exercise, level: 1 };
    if (chooser.mode === 'pain') setPainful((p) => (p.includes(origKey) ? p : [...p, origKey]));
    setReplaced((r) => ({ ...r, [origKey]: replacement }));
    setChooser(null);
    // l'étape en cours repart sur le nouvel exercice, en pause le temps de se mettre en place
    setRemainingMs((step?.seconds ?? 45) * 1000);
    endsAt.current = null;
    setRunning(false);
  }

  function skipCurrent(markPainful: boolean) {
    if (!step) return;
    const id = step.item.exercise.id;
    const next = skipped.includes(id) ? skipped : [...skipped, id];
    const nextPainful = markPainful && !painful.includes(id) ? [...painful, id] : painful;
    setSkipped(next);
    setPainful(nextPainful);
    setChooser(null);
    // on avance au premier pas qui n'est pas celui de l'exercice passé
    let j = index;
    while (j < steps.length && next.includes(steps[j].item.exercise.id)) j++;
    if (j >= steps.length) {
      finish(steps.length, next, nextPainful);
      return;
    }
    goTo(j, false, 1, next);
  }

  function stopSession(markPainful: boolean) {
    const id = step?.item.exercise.id;
    const nextPainful = markPainful && id && !painful.includes(id) ? [...painful, id] : painful;
    setPainful(nextPainful);
    setChooser(null);
    finish(index, skipped, nextPainful);
  }

  if (!steps.length) {
    return (
      <div className="center-screen">
        <h2>Aucun exercice dans cette séance</h2>
        <p className="muted">Ton coach doit encore la préparer.</p>
        <button className="btn secondary" onClick={onCancel}>Retour</button>
      </div>
    );
  }

  const meta = SESSION_META[session];

  if (!started) {
    const blocks = (['warmup', 'main', 'cooldown'] as const)
      .map((b) => ({ block: b, list: effective.filter((it) => it.block === b) }))
      .filter((g) => g.list.length > 0);
    return (
      <div className="stack" style={{ gap: 16 }}>
        <button className="btn ghost" style={{ alignSelf: 'flex-start' }} onClick={onCancel}>← Retour</button>
        <div>
          <div className="eyebrow">{meta.subtitle}</div>
          <h1 style={{ marginTop: 8 }}>{meta.title}</h1>
          <p className="muted" style={{ marginTop: 8 }}>
            Environ {totalMinutes(steps)} min
            {steps.some((s) => s.rounds > 1) ? ` · ${Math.max(...steps.map((s) => s.rounds))} tours · 45 s d'effort, 30 s de repos` : ''}
          </p>
        </div>
        {blocks.map((g) => (
          <div key={g.block} className="card">
            {(g.block !== 'main' || blocks.length > 1) && <div className="eyebrow">{BLOCK_LABEL[g.block]}</div>}
            {g.list.map((it, i) => (
              <div key={it.exercise.id} className="row" style={{ alignItems: 'flex-start' }}>
                <div className="cue-n">{i + 1}</div>
                <div className="grow">
                  <div style={{ fontWeight: 700 }}>{it.exercise.name}</div>
                  <div className="small muted">
                    Niveau {it.level} : {currentLevel(it).label}
                  </div>
                </div>
              </div>
            ))}
          </div>
        ))}
        <div className="banner info">
          Douleur à 3 sur 10 maximum. Si ça fait mal, appuie sur « Ça fait mal » : on te propose un autre exercice et la séance continue.
        </div>
        <button
          className="btn block"
          onClick={() => {
            unlock();
            startedAt.current = Date.now();
            setStarted(true);
            goTo(0, true);
          }}
        >
          C'est parti
        </button>
      </div>
    );
  }

  const isWork = step.kind === 'work';
  const nextWork = steps.slice(index + 1).find((s, k) => s.kind === 'work' && !isSkipped(index + 1 + k));
  const shown = isWork ? step.item : nextWork?.item ?? step.item;
  const lv = currentLevel(shown);
  const pct = Math.min(100, Math.max(0, 100 - (remainingMs / (step.seconds * 1000)) * 100));
  const liveWork = steps.filter((s, i) => s.kind === 'work' && !isSkipped(i));
  const doneWork = steps.slice(0, index).filter((s, i) => s.kind === 'work' && !isSkipped(i)).length;
  const totalWork = Math.max(1, liveWork.length);
  const replacesName = items.find((it) => replaced[it.exercise.id]?.exercise.id === shown.exercise.id)?.exercise.name;

  const where =
    step.block === 'main'
      ? `${step.rounds > 1 ? `Tour ${step.round} sur ${step.rounds} · ` : ''}Exercice ${step.index + 1} sur ${step.total}`
      : `${BLOCK_LABEL[step.block]} · ${step.index + 1} sur ${step.total}`;

  return (
    <div className="stack" style={{ gap: 14 }}>
      <div className="row between">
        <div className="eyebrow">{where}</div>
        <span className="tiny muted">{doneWork}/{totalWork}</span>
      </div>
      <div className="progress-bar" aria-hidden="true">
        <div style={{ width: `${(doneWork / totalWork) * 100}%` }} />
      </div>

      {isWork ? (
        <h1>{shown.exercise.name}</h1>
      ) : (
        <div>
          <div className="eyebrow" style={{ color: 'var(--clay)' }}>Récupère</div>
          <h2 style={{ marginTop: 4 }}>À suivre : {shown.exercise.name}</h2>
        </div>
      )}
      <p className="small muted" style={{ marginTop: -6 }}>
        Niveau {shown.level} : {lv.label}
        {replacesName ? ` · remplace « ${replacesName} »` : ''}
      </p>

      <Figure id={shown.exercise.illustration} label={shown.exercise.name} />

      <div className={`timer ${isWork ? '' : 'rest'}`} role="timer" aria-live="off">
        {formatSeconds(Math.ceil(remainingMs / 1000))}
      </div>
      <div className="progress-bar" aria-hidden="true">
        <div style={{ width: `${pct}%`, background: isWork ? 'var(--sage-strong)' : 'var(--clay)' }} />
      </div>

      <div className="row" style={{ gap: 8 }}>
        <button className="btn secondary small" onClick={() => goTo(index - 1, false, -1)} disabled={index === 0} aria-label="Étape précédente">
          ←
        </button>
        {running ? (
          <button className="btn grow" onClick={pauseTimer}>
            Pause
          </button>
        ) : (
          <button
            className="btn grow"
            onClick={() => {
              unlock();
              endsAt.current = Date.now() + remainingMs;
              setRunning(true);
            }}
          >
            Reprendre
          </button>
        )}
        <button className="btn secondary small" onClick={() => goTo(index + 1, running)} aria-label="Étape suivante">
          →
        </button>
      </div>

      {isWork && !chooser && (
        <>
          <div className="row" style={{ gap: 8 }}>
            <button className="btn secondary small grow" onClick={() => skipCurrent(false)}>
              Passer l'exercice
            </button>
            {allowSwaps && (
              <button className="btn secondary small grow" onClick={() => void openChooser('unsuited')}>
                Ne me convient pas
              </button>
            )}
          </div>
          <button className="btn danger block" onClick={() => void openChooser('pain')}>
            Ça fait mal
          </button>
        </>
      )}

      {chooser && (
        <div className="card amber" role="dialog" aria-label="Changer d'exercice">
          <h3>{chooser.mode === 'pain' ? 'Ça fait mal : on change d\'exercice ?' : 'On change d\'exercice ?'}</h3>
          <p className="small">
            {chooser.mode === 'pain'
              ? 'Pas de souci, ton coach le saura. Choisis un exercice du même effort et la séance continue.'
              : 'Choisis un exercice de même intensité pour la suite de la séance.'}
          </p>
          {chooser.options === null && <div className="spinner" aria-label="Chargement des propositions" />}
          {chooser.options?.length === 0 && (
            <p className="small muted">
              {allowSwaps
                ? "Pas d'exercice équivalent disponible pour le moment."
                : 'Ton coach préfère garder la main sur ton programme : passe cet exercice, il sera prévenu.'}
            </p>
          )}
          {chooser.options?.map((o) => (
            <div key={o.exercise.id} className="swap-option">
              <div className="grow">
                <div style={{ fontWeight: 700 }}>{o.exercise.name}</div>
                <div className="tiny muted">
                  {WHY_LABEL[o.why]} · {o.exercise.zones.map((z) => label(ZONE_LABEL, z)).join(', ')}
                </div>
                <div className="small">{o.exercise.levels[0]?.label}</div>
              </div>
              <button className="btn small" onClick={() => pickOption(o)}>
                Choisir
              </button>
            </div>
          ))}
          <div className="row wrap">
            <button className="btn secondary small" onClick={() => skipCurrent(chooser.mode === 'pain')}>
              Passer l'exercice
            </button>
            {chooser.mode === 'pain' && (
              <button className="btn secondary small" onClick={() => stopSession(true)}>
                Arrêter la séance
              </button>
            )}
            <button className="btn ghost" onClick={() => setChooser(null)}>
              Annuler
            </button>
          </div>
        </div>
      )}

      <div className="card">
        {shown.exercise.cues.map((c, i) => (
          <div key={i} className="cue">
            <div className="cue-n">{i + 1}</div>
            <div className="small">{c}</div>
          </div>
        ))}
        {shown.exercise.video_url && (
          <a className="small" href={shown.exercise.video_url} target="_blank" rel="noopener noreferrer">
            Voir une vidéo de démonstration ↗
          </a>
        )}
      </div>
      {shown.exercise.caution && <div className="banner warn">{shown.exercise.caution}</div>}

      {confirmStop ? (
        <div className="card amber">
          <p className="small">Terminer la séance maintenant ? Tu pourras quand même donner ton ressenti.</p>
          <div className="row">
            <button className="btn small grow" onClick={() => stopSession(false)}>Oui, terminer</button>
            <button className="btn secondary small grow" onClick={() => setConfirmStop(false)}>Continuer</button>
          </div>
        </div>
      ) : (
        <button className="btn ghost" onClick={() => setConfirmStop(true)}>Terminer la séance</button>
      )}
    </div>
  );
}
