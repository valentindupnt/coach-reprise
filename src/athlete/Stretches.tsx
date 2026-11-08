// FLEXO, bloc Étirements : liste des sets guidés, détail d'un set, lecteur posture par posture.
// Contenu identique pour tous : aucune règle par profil. Les sets viennent de athlete_catalog (kind = 'etirement').
import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import Figure from '../components/Figure';
import { fetchCatalog, fetchTraining } from '../lib/athleteApi';
import {
  MODE_LABEL,
  MOMENT_LABEL,
  SPORT_LABEL,
  buildSegments,
  levelLabel,
  postureSeconds,
  totalSeconds,
  type Segment,
} from '../lib/stretch';
import { formatSeconds } from '../lib/plan';
import type { Training, TrainingItem, TrainingSummary } from '../lib/types';

type View = { name: 'list' } | { name: 'detail'; training: Training } | { name: 'play'; training: Training };

const minutesLabel = (s: number) => `${Math.round(s / 60)} min`;

function Chips({ item }: { item: TrainingItem }) {
  const ex = item.exercise;
  return (
    <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
      {ex.stretch_mode && <span className="pill sage">{MODE_LABEL[ex.stretch_mode]}</span>}
      {(ex.moments ?? []).map((m) => <span key={m} className="pill">{MOMENT_LABEL[m]}</span>)}
      {(ex.sports ?? []).map((s) => <span key={s} className="pill rose">{SPORT_LABEL[s]}</span>)}
      {ex.hold_seconds ? <span className="pill">Maintien {ex.hold_seconds} s par côté</span> : null}
    </div>
  );
}

export default function Stretches({ token }: { token: string }) {
  const [sets, setSets] = useState<TrainingSummary[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState<string | null>(null);
  const [view, setView] = useState<View>({ name: 'list' });

  useEffect(() => {
    let alive = true;
    fetchCatalog(token)
      .then((c) => alive && setSets(c.trainings.filter((t) => t.kind === 'etirement')))
      .catch(() => alive && setError('Les sets ne se chargent pas : connecte-toi à internet, ou le contenu n\'est pas encore en ligne.'));
    return () => { alive = false; };
  }, [token]);

  const open = useCallback(async (id: string) => {
    setLoading(id);
    setError(null);
    try {
      setView({ name: 'detail', training: await fetchTraining(token, id) });
    } catch {
      setError('Ce set ne se charge pas pour le moment.');
    } finally {
      setLoading(null);
    }
  }, [token]);

  if (view.name === 'play') {
    return <StretchPlayer training={view.training} onExit={() => setView({ name: 'detail', training: view.training })} />;
  }

  if (view.name === 'detail') {
    const t = view.training;
    const items = [...t.items].sort((a, b) => a.position - b.position);
    const segs = buildSegments(t);
    return (
      <>
        <button className="btn ghost" style={{ alignSelf: 'flex-start' }} onClick={() => setView({ name: 'list' })}>← Les sets</button>
        <div>
          <div className="eyebrow">Set guidé de {minutesLabel(totalSeconds(segs))}</div>
          <h1 style={{ marginTop: 8 }}>{t.title}</h1>
          {t.description && <p className="muted" style={{ marginTop: 8 }}>{t.description}</p>}
        </div>
        <button className="btn block" onClick={() => setView({ name: 'play', training: t })}>Commencer</button>
        {items.map((item, i) => (
          <div className="card" key={item.exercise.id} style={{ flexDirection: 'row', gap: 14, alignItems: 'flex-start' }}>
            <div style={{ width: 112, flex: '0 0 112px' }}>
              <Figure id={item.exercise.illustration} label={item.exercise.name} />
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8, minWidth: 0 }}>
              <div className="small muted">{i + 1} sur {items.length} · {formatSeconds(postureSeconds(item))} s</div>
              <h3 style={{ fontSize: 17 }}>{item.exercise.name}</h3>
              <div className="small muted">{levelLabel(item)}</div>
              <Chips item={item} />
              {item.exercise.video_url && (
                <a className="small" href={item.exercise.video_url} target="_blank" rel="noopener noreferrer">Voir la vidéo</a>
              )}
            </div>
          </div>
        ))}
      </>
    );
  }

  return (
    <>
      <div>
        <div className="eyebrow">Étirements et mobilité</div>
        <h1 style={{ marginTop: 8 }}>Sets guidés</h1>
        <p className="muted" style={{ marginTop: 8 }}>
          Dix minutes, sans matériel. Avant l'effort, de la mobilité en mouvement ; après, des étirements tenus.
        </p>
      </div>
      {error && <div className="banner warn">{error}</div>}
      {!sets && !error && <p className="small muted">Chargement...</p>}
      {sets && sets.length === 0 && (
        <p className="small muted">Aucun set pour le moment : le contenu doit encore être validé.</p>
      )}
      {sets?.map((s) => (
        <button key={s.id} className="day-tile" onClick={() => void open(s.id)} disabled={loading !== null}>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontWeight: 600 }}>{s.title}</div>
            <div className="small muted">{s.exercise_count} postures · {s.duration_min} min</div>
          </div>
          <span className="small muted">{loading === s.id ? '...' : 'Ouvrir'}</span>
        </button>
      ))}
    </>
  );
}

// ---------------------------------------------------------------- lecteur

function useBeep() {
  const ctx = useRef<AudioContext | null>(null);
  const unlock = useCallback(() => {
    try {
      if (!ctx.current) {
        const AC = window.AudioContext || (window as unknown as { webkitAudioContext?: typeof AudioContext }).webkitAudioContext;
        if (AC) ctx.current = new AC();
      }
      void ctx.current?.resume();
    } catch { /* pas de son, pas grave */ }
  }, []);
  const beep = useCallback((freq = 880, ms = 160) => {
    try {
      const c = ctx.current;
      if (!c) return;
      const o = c.createOscillator();
      const g = c.createGain();
      o.frequency.value = freq;
      g.gain.value = 0.08;
      o.connect(g);
      g.connect(c.destination);
      o.start();
      o.stop(c.currentTime + ms / 1000);
    } catch { /* idem */ }
  }, []);
  return { unlock, beep };
}

function StretchPlayer({ training, onExit }: { training: Training; onExit: () => void }) {
  const segments: Segment[] = useMemo(() => buildSegments(training), [training]);
  const items = useMemo(() => new Map(training.items.map((it) => [it.exercise.id, it])), [training]);
  const total = totalSeconds(segments);
  const { unlock, beep } = useBeep();

  const [i, setI] = useState(0);
  const [ms, setMs] = useState(segments[0].seconds * 1000);
  const [paused, setPaused] = useState(false);
  const [done, setDone] = useState(false);
  const last = useRef(Date.now());

  // Écran allumé pendant la séance (ignoré si le navigateur ne sait pas)
  useEffect(() => {
    type Lock = { release: () => Promise<void> };
    const wl = (navigator as unknown as { wakeLock?: { request: (t: 'screen') => Promise<Lock> } }).wakeLock;
    let lock: Lock | null = null;
    wl?.request('screen').then((l) => { lock = l; }).catch(() => undefined);
    return () => { void lock?.release().catch(() => undefined); };
  }, []);

  useEffect(() => {
    last.current = Date.now();
    const id = setInterval(() => {
      const now = Date.now();
      const dt = now - last.current;
      last.current = now;
      if (!paused && !done) setMs((m) => m - dt);
    }, 200);
    return () => clearInterval(id);
  }, [paused, done]);

  const go = useCallback((j: number) => {
    if (j >= segments.length) {
      setDone(true);
      beep(660, 400);
      return;
    }
    const k = Math.max(0, j);
    setI(k);
    setMs(segments[k].seconds * 1000);
  }, [segments, beep]);

  useEffect(() => {
    if (ms > 0 || done) return;
    beep(segments[i + 1] && !segments[i + 1].prepare ? 880 : 660, 180);
    go(i + 1);
  }, [ms, done, i, segments, go, beep]);

  if (done) {
    return (
      <div className="stretch-full">
        <div className="eyebrow">Set terminé</div>
        <h1>{training.title}</h1>
        <p className="muted">{minutesLabel(total)} d'étirements. Bien joué.</p>
        <button className="btn block" onClick={onExit}>Retour au set</button>
      </div>
    );
  }

  const seg = segments[i];
  // Pendant une transition, on montre la posture à venir
  const item = items.get(seg.exerciseId)!;
  const ex = item.exercise;
  const left = Math.max(0, Math.ceil(ms / 1000));
  const elapsed = segments.slice(0, i).reduce((a, s) => a + s.seconds, 0) + (seg.seconds - ms / 1000);
  const postureNo = seg.index + 1;
  const postureCount = training.items.length;

  return (
    <div className="stretch-full">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <button className="btn ghost" onClick={onExit}>Quitter</button>
        <span className="small muted">{training.title} · {formatSeconds(Math.round(elapsed))} sur {formatSeconds(total)}</span>
      </div>
      <div className="stretch-bar" role="progressbar" aria-valuemin={0} aria-valuemax={total} aria-valuenow={Math.round(elapsed)}>
        <span style={{ width: `${Math.min(100, (elapsed / total) * 100)}%` }} />
      </div>

      <div>
        <div className="eyebrow">
          {seg.prepare ? `Prépare-toi, posture ${postureNo} sur ${postureCount}` : `Posture ${postureNo} sur ${postureCount}`}
        </div>
        <h1 style={{ marginTop: 8 }}>{ex.name}</h1>
      </div>

      <Figure id={ex.illustration} label={ex.name} />

      <div className={`timer${seg.prepare ? ' rest' : ''}`} aria-live="off">{left}</div>
      {seg.side && <div className="stretch-side">{seg.side === 'droit' ? 'Côté droit' : 'Côté gauche'}</div>}
      {seg.prepare && <div className="stretch-side">Installe-toi</div>}

      <div className="card">
        <div className="small muted">{levelLabel(item)}</div>
        <ol style={{ margin: 0, paddingLeft: 20, display: 'flex', flexDirection: 'column', gap: 6 }}>
          {ex.cues.map((c) => <li key={c}>{c}</li>)}
        </ol>
        {ex.caution && <p className="small muted" style={{ margin: 0 }}>{ex.caution}</p>}
        {ex.video_url && <a className="small" href={ex.video_url} target="_blank" rel="noopener noreferrer">Voir la vidéo</a>}
      </div>

      <div style={{ display: 'flex', gap: 10 }}>
        <button className="btn secondary" onClick={() => { unlock(); go(i - 1); }} disabled={i === 0} aria-label="Étape précédente">Précédent</button>
        <button className="btn" style={{ flex: 1 }} onClick={() => { unlock(); setPaused((p) => !p); }}>{paused ? 'Reprendre' : 'Pause'}</button>
        <button className="btn secondary" onClick={() => { unlock(); go(i + 1); }} aria-label="Étape suivante">Suivant</button>
      </div>
    </div>
  );
}
