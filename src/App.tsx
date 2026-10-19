import { Component, lazy, Suspense, type ReactNode } from 'react';
import AthleteApp from './athlete/AthleteApp';
import { isConfigured } from './lib/supabase';

const CoachApp = lazy(() => import('./coach/CoachApp'));

class ErrorBoundary extends Component<{ children: ReactNode }, { failed: boolean }> {
  state = { failed: false };
  static getDerivedStateFromError() {
    return { failed: true };
  }
  render() {
    if (this.state.failed) {
      return (
        <main className="app">
          <div className="center-screen">
            <h2>Oups, un souci d'affichage</h2>
            <p className="muted">Recharge la page. Si ça continue, préviens ton coach.</p>
            <button className="btn" onClick={() => window.location.reload()}>Recharger</button>
          </div>
        </main>
      );
    }
    return this.props.children;
  }
}

function Message({ title, text }: { title: string; text: string }) {
  return (
    <main className="app">
      <div className="center-screen">
        <h2>{title}</h2>
        <p className="muted">{text}</p>
      </div>
    </main>
  );
}

export default function App() {
  const path = window.location.pathname.replace(/\/+$/, '');

  if (!isConfigured) {
    return <Message title="Application non configurée" text="Les clés Supabase manquent (VITE_SUPABASE_URL et VITE_SUPABASE_KEY)." />;
  }

  const athleteMatch = path.match(/^\/a\/([a-f0-9]{32,128})$/i);
  let content: ReactNode;
  if (athleteMatch) {
    content = <AthleteApp token={athleteMatch[1].toLowerCase()} />;
  } else if (path === '/coach') {
    content = (
      <Suspense fallback={<main className="app"><div className="center-screen"><div className="spinner" aria-label="Chargement" /></div></main>}>
        <CoachApp />
      </Suspense>
    );
  } else {
    content = <Message title="Ma reprise" text="Ouvre le lien personnel que ton coach t'a envoyé." />;
  }
  return <ErrorBoundary>{content}</ErrorBoundary>;
}
