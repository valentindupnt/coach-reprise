export function SafetyCard() {
  return (
    <div className="stack">
      <div className="card">
        <h3>Ton échelle de douleur</h3>
        <div style={{ display: 'flex', height: 14, borderRadius: 999, overflow: 'hidden' }} aria-hidden="true">
          <div style={{ flex: 3, background: 'var(--sage-mid)' }} />
          <div style={{ flex: 2, background: 'var(--amber)' }} />
          <div style={{ flex: 5, background: 'var(--rose-fig)' }} />
        </div>
        <div className="row between tiny muted" aria-hidden="true">
          <span>0</span><span>3</span><span>5</span><span>10</span>
        </div>
        <p className="small muted">
          Reste à <strong style={{ color: 'var(--sage-ink)' }}>3 sur 10 maximum</strong> pendant l'effort. Au-delà, réduis
          l'amplitude ou passe à l'exercice suivant.
        </p>
      </div>
      <div className="card sage">
        <h3>Tu peux continuer si</h3>
        <ul className="small" style={{ margin: 0, paddingLeft: 18 }}>
          <li>la douleur reste à 3 sur 10 ou moins ;</li>
          <li>elle est revenue à la normale dans les 24 h ;</li>
          <li>tu n'as ni fourmillement ni engourdissement.</li>
        </ul>
      </div>
      <div className="card rose">
        <h3>Stop et appelle ton médecin si</h3>
        <ul className="small" style={{ margin: 0, paddingLeft: 18 }}>
          <li>faiblesse ou lourdeur dans les jambes ;</li>
          <li>engourdissement qui s'étend ;</li>
          <li>douleur en ceinture autour du thorax ;</li>
          <li>troubles urinaires ou digestifs.</li>
        </ul>
        <p className="small">En cas d'urgence, appelle le 15.</p>
      </div>
    </div>
  );
}

export function FrozenScreen({ firstName }: { firstName: string }) {
  return (
    <div className="stack" style={{ gap: 16 }}>
      <div>
        <div className="eyebrow">Programme en pause</div>
        <h1 style={{ marginTop: 8 }}>On fait une pause, {firstName}.</h1>
      </div>
      <div className="card rose">
        <p>
          Tu as signalé des <strong>fourmillements, un engourdissement ou une faiblesse</strong>. Par prudence, ton
          programme est en pause.
        </p>
        <p>
          <strong>Contacte ton médecin ou ton kiné</strong> pour en parler avant de reprendre. Si les symptômes
          s'aggravent vite, appelle le 15.
        </p>
      </div>
      <div className="card">
        <p className="small muted">
          Ton coach voit cette pause dans son tableau de bord. Il réactivera ton programme après en avoir parlé avec
          toi.
        </p>
      </div>
      <SafetyCard />
    </div>
  );
}
