// NOMA : « Démarrage rapide » : les séances mises en favori (cœur), à lancer en un geste.
import { useEffect, useState } from 'react';
import { fetchCatalog, fetchFavorites } from '../lib/athleteApi';
import type { TrainingSummary } from '../lib/types';

export default function QuickStart({ token, onOpen }: { token: string; onOpen: () => void }) {
  const [favs, setFavs] = useState<TrainingSummary[] | null>(null);
  useEffect(() => {
    let alive = true;
    Promise.all([fetchFavorites(token), fetchCatalog(token)])
      .then(([ids, cat]) => alive && setFavs(ids.map((id) => cat.trainings.find((t) => t.id === id)).filter((t): t is TrainingSummary => !!t)))
      .catch(() => alive && setFavs([]));
    return () => { alive = false; };
  }, [token]);
  if (!favs || favs.length === 0) return null;
  return (
    <div className="card lavender">
      <div className="eyebrow">Démarrage rapide</div>
      {favs.map((t) => (
        <button key={t.id} className="swap-option" style={{ border: 0, textAlign: 'left', width: '100%' }} onClick={onOpen}>
          <div className="grow">
            <div style={{ fontWeight: 500 }}>{t.title}</div>
            <div className="tiny muted">{t.duration_min} min</div>
          </div>
          <span className="small">Ouvrir</span>
        </button>
      ))}
    </div>
  );
}
