// Faux Supabase pour les tests de bout en bout : un PostgreSQL embarqué
// (PGlite) avec le vrai schema.sql + seed.sql, derrière une imitation des
// routes HTTP utilisées par l'app (auth mot de passe, RPC, quelques
// lectures/écritures de tables). Les droits (anon / coach) sont appliqués
// par la vraie sécurité de la base, pas par ce serveur.
import http from 'node:http';
import { readFileSync } from 'node:fs';
import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';

export const COACH_ID = '11111111-1111-1111-1111-111111111111';
export const COACH_EMAIL = 'coach@test.fr';
export const COACH_PASSWORD = 'motdepasse-test';
export const ANON_KEY = 'anon-test-key';

const b64 = (o) => Buffer.from(JSON.stringify(o)).toString('base64url');
function fakeJwt(sub) {
  const now = Math.floor(Date.now() / 1000);
  return `${b64({ alg: 'HS256', typ: 'JWT' })}.${b64({ sub, role: 'authenticated', aud: 'authenticated', exp: now + 3600, iat: now, email: COACH_EMAIL })}.sig`;
}
const USER = { id: COACH_ID, aud: 'authenticated', role: 'authenticated', email: COACH_EMAIL, app_metadata: {}, user_metadata: {}, created_at: new Date().toISOString() };

export async function startMock(port = 54321) {
  const db = new PGlite({ extensions: { pgcrypto } });
  await db.exec(`
    create role anon nologin; create role authenticated nologin;
    grant usage on schema public to anon, authenticated;
    create schema auth; grant usage on schema auth to anon, authenticated;
    create table auth.users (id uuid primary key);
    create function auth.uid() returns uuid language sql stable as $$
      select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
    grant execute on function auth.uid() to anon, authenticated;
    insert into auth.users values ('${COACH_ID}');
  `);
  await db.exec(readFileSync(new URL('../supabase/schema.sql', import.meta.url), 'utf8'));
  await db.exec(readFileSync(new URL('../supabase/seed.sql', import.meta.url), 'utf8'));
  await db.exec(`insert into public.coaches values ('${COACH_ID}')`);
  const token = (await db.query(`select access_token from public.athletes limit 1`)).rows[0].access_token;

  let queue = Promise.resolve();
  const run = (role, sub, fn) => {
    const p = queue.then(async () => {
      await db.exec(`set role ${role}`);
      await db.query(`select set_config('request.jwt.claim.sub', $1, false)`, [sub ?? '']);
      try {
        return await fn();
      } finally {
        await db.exec('reset role');
      }
    });
    queue = p.catch(() => undefined);
    return p;
  };

  const RPC_ARGS = {
    athlete_get: ['p_token'],
    athlete_submit_workout: ['p_token', 'p_client_id', 'p_session', 'p_pain', 'p_neuro', 'p_items', 'p_comment'],
    is_coach: [],
    coach_set_level: ['p_athlete', 'p_exercise', 'p_level', 'p_reason'],
    coach_rotate_token: ['p_athlete'],
  };

  function filters(url, allowed) {
    const where = [];
    const params = [];
    for (const [k, v] of url.searchParams) {
      if (!allowed.includes(k)) continue;
      if (v.startsWith('eq.')) {
        params.push(v.slice(3));
        where.push(`${k} = $${params.length}`);
      } else if (v.startsWith('in.(')) {
        const list = v.slice(4, -1).split(',').map((x) => x.replace(/"/g, ''));
        params.push(list);
        where.push(`${k}::text = any($${params.length})`);
      }
    }
    return { where: where.length ? 'where ' + where.join(' and ') : '', params };
  }

  async function handle(req, res, body) {
    const url = new URL(req.url, 'http://x');
    const auth = req.headers.authorization || '';
    const bearer = auth.replace(/^Bearer /, '');
    const isCoach = bearer.split('.').length === 3 && bearer !== ANON_KEY;
    const role = isCoach ? 'authenticated' : 'anon';
    const sub = isCoach ? COACH_ID : null;
    const send = (status, data) => {
      res.writeHead(status, { 'content-type': 'application/json' });
      res.end(data === undefined ? '' : JSON.stringify(data));
    };

    if (url.pathname === '/auth/v1/token') {
      const b = JSON.parse(body || '{}');
      if (url.searchParams.get('grant_type') === 'password' && b.email === COACH_EMAIL && b.password === COACH_PASSWORD) {
        return send(200, { access_token: fakeJwt(COACH_ID), token_type: 'bearer', expires_in: 3600, expires_at: Math.floor(Date.now() / 1000) + 3600, refresh_token: 'refresh', user: USER });
      }
      if (url.searchParams.get('grant_type') === 'refresh_token') {
        return send(200, { access_token: fakeJwt(COACH_ID), token_type: 'bearer', expires_in: 3600, expires_at: Math.floor(Date.now() / 1000) + 3600, refresh_token: 'refresh', user: USER });
      }
      return send(400, { code: 400, error_code: 'invalid_credentials', msg: 'Invalid login credentials', error: 'invalid_grant', error_description: 'Invalid login credentials' });
    }
    if (url.pathname === '/auth/v1/user') return isCoach ? send(200, USER) : send(401, { msg: 'no' });
    if (url.pathname === '/auth/v1/logout') return send(204);

    const rpc = url.pathname.match(/^\/rest\/v1\/rpc\/(\w+)$/);
    if (rpc) {
      const fn = rpc[1];
      const args = JSON.parse(body || '{}');
      if (fn === 'coach_proposals') {
        const rows = await run(role, sub, async () => (await db.query('select * from public.coach_proposals()')).rows);
        return send(200, rows);
      }
      const names = RPC_ARGS[fn];
      if (!names) return send(404, { message: 'unknown rpc' });
      const vals = names.map((n) => (n === 'p_items' ? JSON.stringify(args[n] ?? []) : args[n] ?? null));
      const sql = `select public.${fn}(${names.map((n, i) => `${n} => $${i + 1}${n === 'p_items' ? '::jsonb' : ''}`).join(', ')}) as r`;
      const r = await run(role, sub, async () => (await db.query(sql, vals)).rows[0].r);
      return send(200, r);
    }

    const table = url.pathname.match(/^\/rest\/v1\/(\w+)$/)?.[1];
    if (table && req.method === 'GET') {
      let sql;
      let f;
      if (table === 'athletes') {
        f = filters(url, ['id']);
        sql = `select id, first_name, access_token, start_date, coach_message, frozen, frozen_at from public.athletes ${f.where} order by created_at`;
      } else if (table === 'program_items') {
        f = filters(url, ['athlete_id', 'active']);
        sql = `select pi.athlete_id, pi.session_key, pi.position, pi.level, pi.exercise_id,
                 (select json_build_object('name', e.name, 'levels', e.levels) from public.exercises e where e.id = pi.exercise_id) as exercises
               from public.program_items pi ${f.where.replace(/(\w+) =/g, 'pi.$1 =')} order by pi.session_key, pi.position`;
      } else if (table === 'workouts') {
        f = filters(url, ['athlete_id', 'reviewed']);
        const limit = Number(url.searchParams.get('limit') || 100);
        sql = `select w.id, w.athlete_id, w.session_key, w.done_at, w.pain, w.neuro, w.comment, w.reviewed,
                 coalesce((select json_agg(json_build_object('exercise_id', wi.exercise_id, 'level', wi.level, 'feeling', wi.feeling))
                   from public.workout_items wi where wi.workout_id = w.id), '[]') as workout_items
               from public.workouts w ${f.where.replace(/(\w+) =/g, 'w.$1 =')} order by w.done_at desc limit ${limit}`;
      } else if (table === 'level_changes') {
        f = filters(url, ['athlete_id']);
        sql = `select * from public.level_changes ${f.where} order by created_at desc limit 30`;
      } else return send(404, { message: 'table inconnue du faux serveur' });
      const rows = await run(role, sub, async () => (await db.query(sql, f.params)).rows);
      return send(200, rows);
    }
    if (table && req.method === 'PATCH') {
      const f = filters(url, ['id']);
      const patch = JSON.parse(body || '{}');
      const cols = Object.keys(patch);
      const sets = cols.map((c, i) => `${c} = $${f.params.length + i + 1}`).join(', ');
      await run(role, sub, () => db.query(`update public.${table} set ${sets} ${f.where}`, [...f.params, ...cols.map((c) => patch[c])]));
      return send(204);
    }
    return send(404, { message: 'route inconnue du faux serveur' });
  }

  const server = http.createServer((req, res) => {
    res.setHeader('access-control-allow-origin', '*');
    res.setHeader('access-control-allow-headers', '*');
    res.setHeader('access-control-allow-methods', 'GET,POST,PATCH,DELETE,OPTIONS');
    if (req.method === 'OPTIONS') {
      res.writeHead(204);
      return res.end();
    }
    let body = '';
    req.on('data', (c) => (body += c));
    req.on('end', () => {
      handle(req, res, body).catch((e) => {
        res.writeHead(400, { 'content-type': 'application/json' });
        res.end(JSON.stringify({ message: e.message, code: e.code }));
      });
    });
  });
  await new Promise((r) => server.listen(port, r));
  return { server, db, token, close: () => new Promise((r) => server.close(r)) };
}
