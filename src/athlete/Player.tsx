import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import Figure from '../components/Figure';
import type { ProgramItem, ProgramSessionKey } from '../lib/types';
import { buildSteps, currentLevel, formatSeconds, SESSION_META, totalMinutes } from '../lib/plan';

interface Props {
  session: ProgramSessionKey;
  items: ProgramItem[];
  rounds: number;
  onFinish: (painfulExerciseId: string | null) => void;
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

export default function Player({ session, items, rounds, onFinish, onCancel }: Props) {
  const steps = useMemo(() => buildSteps(items, session, rounds), [items, session, rounds]);
  const [started, setStarted] = useState(false);
  const [index, setIndex] = useState(0);
  const [running, setRunning] = useState(false);
  const [remainingMs, setRemainingMs] = useState(() => (steps[0]?.seconds ?? 0) * 1000);
  const [confirmStop, setConfirmStop] = useState(false);
  const endsAt = useRef<number | null>(null);
  const { unlock, beep } = useBeep();
  useWakeLock(started);

  const step = steps[index];

  const goTo = useCallback(
    (i: number, autoRun: boolean) => {
      if (i >= steps.length) {
        setRunning(false);
        endsAt.current = null;
        onFinish(null);
        return;
      }
      const next = steps[Math.max(0, i)];
      setIndex(Math.max(0, i));
      setRemainingMs(next.seconds * 1000);
      if (autoRun) {
        endsAt.current = Date.now() + next.seconds * 1000;
        setRunning(true);
      } else {
        endsAt.current = null;
        setRunning(false);
      }
    },
    [steps, onFinish],
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
    return (
      <div className="stack" style={{ gap: 16 }}>
        <button className="btn ghost" style={{ alignSelf: 'flex-start' }} onClick={onCancel}>← Retour</button>
        <div>
          <div className="eyebrow">{meta.subtitle}</div>
          <h1 style={{ marginTop: 8 }}>{meta.title}</h1>
          <p className="muted" style={{ marginTop: 8 }}>
            Environ {totalMinutes(steps)} min
            {steps[0].rounds > 1 ? ` · ${steps[0].rounds} tours · 45 s d'effort, 30 s de repos` : ''}
          </p>
        </div>
        <div className="card">
          {items.map((it, i) => (
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
        <div className="banner info">
          Douleur à 3 sur 10 maximum. Si ça fait mal, appuie sur « Ça fait mal » : l'exercice sera allégé.
        </div>
        <button
          className="btn block"
          onClick={() => {
            unlock();
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
  const nextWork = steps.slice(index + 1).find((s) => s.kind === 'work');
  const shown = isWork ? step.item : nextWork?.item ?? step.item;
  const lv = currentLevel(shown);
  const pct = Math.min(100, Math.max(0, 100 - (remainingMs / (step.seconds * 1000)) * 100));
  const doneWork = steps.slice(0, index).filter((s) => s.kind === 'work').length;
  const totalWork = steps.filter((s) => s.kind === 'work').length;

  return (
    <div className="stack" style={{ gap: 14 }}>
      <div className="row between">
        <div className="eyebrow">
          {step.rounds > 1 ? `Tour ${step.round} sur ${step.rounds} · ` : ''}
          Exercice {step.index + 1} sur {step.total}
        </div>
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
      </p>

      <Figure id={shown.exercise.illustration} label={shown.exercise.name} />

      <div className={`timer ${isWork ? '' : 'rest'}`} role="timer" aria-live="off">
        {formatSeconds(Math.ceil(remainingMs / 1000))}
      </div>
      <div className="progress-bar" aria-hidden="true">
        <div style={{ width: `${pct}%`, background: isWork ? 'var(--sage-strong)' : 'var(--clay)' }} />
      </div>

      <div className="row" style={{ gap: 8 }}>
        <button className="btn secondary small" onClick={() => goTo(index - 1, false)} disabled={index === 0} aria-label="Étape précédente">
          ←
        </button>
        {running ? (
          <button
            className="btn grow"
            onClick={() => {
              setRunning(false);
              endsAt.current = null;
            }}
          >
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

      {isWork && (
        <button className="btn danger block" onClick={() => onFinish(shown.exercise.id)}>
          Ça fait mal
        </button>
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
            <button className="btn small grow" onClick={() => onFinish(null)}>Oui, terminer</button>
            <button className="btn secondary small grow" onClick={() => setConfirmStop(false)}>Continuer</button>
          </div>
        </div>
      ) : (
        <button className="btn ghost" onClick={() => setConfirmStop(true)}>Terminer la séance</button>
      )}
    </div>
  );
}
