"""Tableurs de relecture, à partir de content/v5/relecture.json.
   python3 scripts/build-relecture.py   (après node scripts/build-content.mjs)
Produit content/v5/relecture-bloc2.xlsx (contenu V5, bloc 2, déjà relu le 27/10/2026)
et content/v5/relecture-etirements.xlsx (FLEXO, bloc Étirements : 8 nouveaux étirements, étiquettes, 7 sets).
Valentin remplit les colonnes jaunes, puis le renvoie : scripts/build-validation.py génère le SQL qui valide
ce qui est marqué « oui »."""
import json
import unicodedata
from pathlib import Path
from openpyxl import Workbook
from openpyxl.styles import Alignment, Font, PatternFill, Border, Side
from openpyxl.worksheet.datavalidation import DataValidation
from openpyxl.utils import get_column_letter

ROOT = Path(__file__).resolve().parent.parent
full = json.loads((ROOT / 'content/v5/relecture.json').read_text())
OUT = ROOT / 'content/v5/relecture-bloc2.xlsx'
OUT_ETIR = ROOT / 'content/v5/relecture-etirements.xlsx'

# Le tableur du bloc 2 garde exactement son périmètre : sans les étirements FLEXO ni les sets guidés.
etir_names = {e['nom'] for e in full['exercices'] if e['lot'] == 'etirements'}
set_titles = {t['titre'] for t in full['entrainements'] if t['type'] == 'etirement'}
bloc2_names = {e['nom'] for e in full['exercices'] if e['lot'] == 'bloc2'}
bloc2_titles = {t['titre'] for t in full['entrainements'] if t['type'] != 'etirement'}


def bloc2_source(src):
    if not (src['exercices'] or src['entrainements'] or src['programmes']):
        return not src['url'].startswith(('https://www.nhs.uk/live-well/exercise/how-to', 'https://www.nhs.uk/content-widgets',
                                          'https://pubmed.ncbi.nlm.nih.gov/26642915', 'https://www.acsm.org/blog-detail'))
    return bool(set(src['exercices']) & bloc2_names or set(src['entrainements']) & bloc2_titles or src['programmes'])


def strip(src):
    return {**src, 'exercices': [x for x in src['exercices'] if x in bloc2_names],
            'entrainements': [x for x in src['entrainements'] if x in bloc2_titles]}


data = {**full,
        'exercices': [e for e in full['exercices'] if e['lot'] == 'bloc2'],
        'entrainements': [t for t in full['entrainements'] if t['type'] != 'etirement'],
        'sources': [strip(x) for x in full['sources'] if bloc2_source(x)]}
# Même ordre que le générateur (type, puis nombre d'exercices qui la citent) ; tri stable, donc l'ordre
# alphabétique d'origine est gardé à nombre égal.
_types = list(dict.fromkeys(x['type'] for x in data['sources']))
_plain = lambda t: ''.join(c for c in unicodedata.normalize('NFD', t) if not unicodedata.combining(c)).casefold()
data['sources'].sort(key=lambda x: (_types.index(x['type']), -len(x['exercices']), _plain(x['titre'])))

F = 'Arial'
HEAD = PatternFill('solid', fgColor='1F3A5F')
INPUT = PatternFill('solid', fgColor='FFF2A8')
EXAMPLE = PatternFill('solid', fgColor='E8F0E0')
thin = Side(style='thin', color='D0D0D0')
BORDER = Border(left=thin, right=thin, top=thin, bottom=thin)
WRAP = Alignment(wrap_text=True, vertical='top')

wb = Workbook()


def table(ws, headers, rows, widths, inputs):
    for c, (h, w) in enumerate(zip(headers, widths), start=1):
        cell = ws.cell(row=1, column=c, value=h)
        cell.font = Font(name=F, bold=True, color='FFFFFF')
        cell.fill = INPUT if h in inputs else HEAD
        if h in inputs:
            cell.font = Font(name=F, bold=True, color='000000')
        cell.alignment = Alignment(wrap_text=True, vertical='center')
        cell.border = BORDER
        ws.column_dimensions[get_column_letter(c)].width = w
    for r, row in enumerate(rows, start=2):
        for c, v in enumerate(row, start=1):
            cell = ws.cell(row=r, column=c, value=v)
            cell.font = Font(name=F, size=9)
            cell.alignment = WRAP
            cell.border = BORDER
            if headers[c - 1] in inputs:
                cell.fill = INPUT
    ws.freeze_panes = 'C2'
    ws.auto_filter.ref = f'A1:{get_column_letter(len(headers))}{len(rows) + 1}'
    ws.row_dimensions[1].height = 32
    return len(rows) + 1


def yesno(ws, col, last):
    dv = DataValidation(type='list', formula1='"oui,non,à revoir"', allow_blank=True)
    ws.add_data_validation(dv)
    dv.add(f'{col}2:{col}{last}')


# ------------------------------------------------------------------ Exercices
ws = wb.active
ws.title = 'Exercices'
heads = ['Identifiant', 'Nom', 'Statut', 'Validé', 'Vidéo OK', 'Commentaire', 'Sources', 'Discipline', 'Zones',
         'Objectifs', 'Intensité (1 à 5)', 'Sauts', 'Matériel nécessaire', 'Par défaut', 'Niveaux', 'Muscles principaux',
         'Muscles secondaires', 'MET (Compendium 2024)', 'Consignes', 'Précaution', 'Respiration',
         'Erreurs fréquentes', 'Vidéo proposée']
rows = []
for e in data['exercices']:
    v = e['video']
    rows.append([e['id'], e['nom'], e['statut'], None, None, None,
                 '\n'.join(f"{s['label']} : {s['url']}" for s in e['sources']),
                 e['discipline'], e['zones'], e['objectifs'],
                 e['intensite'], e['sauts'], e['materiel'], e['mode'], e['niveaux'], e['muscles_principaux'],
                 e['muscles_secondaires'], e['met'], e['consignes'], e['precaution'], e['respiration'], e['erreurs'],
                 f"{v['title']} ({'français' if v['lang'] == 'fr' else 'anglais'})\n{v['url']}" if v else ''])
last_ex = table(ws, heads, rows,
                [20, 30, 14, 10, 10, 30, 60, 13, 18, 18, 9, 7, 14, 13, 40, 28, 28, 30, 55, 35, 30, 38, 50],
                {'Validé', 'Vidéo OK', 'Commentaire'})
yesno(ws, 'D', last_ex)
yesno(ws, 'E', last_ex)
for r in range(2, last_ex + 1):
    url = ws.cell(row=r, column=23).value.split('\n')[-1] if ws.cell(row=r, column=23).value else None
    if url:
        ws.cell(row=r, column=23).hyperlink = url
        ws.cell(row=r, column=23).font = Font(name=F, size=9, color='0563C1', underline='single')

# ------------------------------------------------------------------ Entraînements
ws2 = wb.create_sheet('Entraînements')
kinds = {'programme': 'Jour de programme', 'rapide': 'Démarrage rapide', 'decouverte': 'Découverte', 'express': 'Express (hors ligne)'}
rows = [[t['id'], t['titre'], kinds[t['type']], None, None, t['niveau'], t['zones'], t['minutes'],
         round(t['metMinutes'] * 60 / 60, 0), t['tours'], t['pause'], 'oui' if t['impact'] else 'non',
         ', '.join(t['equipment']) or 'aucun', t['description'], t['contenu'],
         '\n'.join(f"{x['label']} : {x['url']}" for x in t['reperes']), '\n'.join(f"{x['label']} : {x['url']}" for x in t['sources_exercices'])]
        for t in data['entrainements']]
last_tr = table(ws2, ['Identifiant', 'Titre', 'Type', 'Validé', 'Commentaire', 'Niveau', 'Zones', 'Durée (min)',
                      'Calories pour 60 kg (estimation)', 'Tours', 'Pause (s)', 'Sauts', 'Matériel', 'Description',
                      'Contenu', 'Repères de construction', 'Sources des exercices'], rows,
                [26, 34, 18, 10, 30, 7, 20, 9, 12, 7, 8, 7, 10, 45, 60, 55, 70], {'Validé', 'Commentaire'})
yesno(ws2, 'D', last_tr)
# Calories : MET-minutes x poids / 60 (cadrage V5, section 8). Poids réglable dans « Mode d'emploi ».
WEIGHT = "'Mode d''emploi'!$B$21"
ws2.cell(row=1, column=9, value='Calories (estimation, poids du mode d\'emploi)')
for r, t in enumerate(data['entrainements'], start=2):
    ws2.cell(row=r, column=9, value=f'=ROUND({t["metMinutes"]}*{WEIGHT}/60,0)')

# ------------------------------------------------------------------ Programmes
ws3 = wb.create_sheet('Programmes')
rows = []
for p in data['programmes']:
    for j in p['jours']:
        rows.append([p['titre'], j['jour'], (j['jour'] - 1) // 7 + 1, j['entrainement'], j['titre'], j['minutes']])
last_pr = table(ws3, ['Programme', 'Jour', 'Semaine', 'Entraînement', 'Titre', 'Durée (min)'], rows,
                [24, 7, 9, 22, 38, 40], set())
ws3.freeze_panes = 'A2'
c = len(rows) + 3
ws3.cell(row=c, column=1, value='Programme').font = Font(name=F, bold=True)
ws3.cell(row=c, column=2, value='Validé').font = Font(name=F, bold=True)
ws3.cell(row=c, column=3, value='Commentaire').font = Font(name=F, bold=True)
ws3.cell(row=c, column=4, value='Description').font = Font(name=F, bold=True)
ws3.cell(row=c, column=5, value='Repères de construction').font = Font(name=F, bold=True)
ws3.cell(row=c, column=6, value='Sources des exercices').font = Font(name=F, bold=True)
ws3.column_dimensions['G'].width = 10
dv = DataValidation(type='list', formula1='"oui,non,à revoir"', allow_blank=True)
ws3.add_data_validation(dv)
for i, p in enumerate(data['programmes'], start=1):
    ws3.cell(row=c + i, column=1, value=p['titre']).font = Font(name=F, size=9)
    for col in (2, 3):
        ws3.cell(row=c + i, column=col).fill = INPUT
    dv.add(ws3.cell(row=c + i, column=2))
    d = ws3.cell(row=c + i, column=4, value=p['description'])
    d.font = Font(name=F, size=9)
    d.alignment = WRAP
    for col, val in ((5, '\n'.join(f"{x['label']} : {x['url']}" for x in p['reperes'])),
                     (6, f"{len(p['sources_exercices'])} sources : voir l'onglet Sources, colonne Programmes")):
        x = ws3.cell(row=c + i, column=col, value=val)
        x.font = Font(name=F, size=9)
        x.alignment = WRAP

# ------------------------------------------------------------------ Sources
ws4 = wb.create_sheet('Sources')
prog_urls = {p['titre']: {x['url'] for x in p['sources_exercices']} | {x['url'] for x in p['reperes']} for p in data['programmes']}
rows = []
for src in data['sources']:
    progs = [t for t, urls in prog_urls.items() if src['url'] in urls]
    n_tr = sum(1 for t in data['entrainements']
               if src['url'] in {x['url'] for x in t['reperes'] + t['sources_exercices']})
    rows.append([src['type'], src['titre'], src['url'], src['usages'], None,
                 ', '.join(src['exercices']), n_tr, ', '.join(progs)])
last_src = table(ws4, ['Type', 'Source', 'Lien', 'À quoi elle sert', "Nombre d'exercices", 'Exercices',
                       "Nombre d'entraînements", 'Programmes'], rows,
                 [22, 50, 45, 38, 11, 60, 13, 34], set())
ws4.freeze_panes = 'C2'
for r in range(2, last_src + 1):
    # Nombre d'exercices qui citent cette source : recherche du lien dans la colonne Sources de l'onglet Exercices
    ws4.cell(row=r, column=5, value=f'=SUMPRODUCT(--ISNUMBER(SEARCH(C{r},Exercices!$G$2:$G${last_ex})))')
    link = ws4.cell(row=r, column=3)
    link.hyperlink = link.value
    link.font = Font(name=F, size=9, color='0563C1', underline='single')

# ------------------------------------------------------------------ Mode d'emploi (en premier)
ws0 = wb.create_sheet("Mode d'emploi", 0)
ws0.column_dimensions['A'].width = 46
ws0.column_dimensions['B'].width = 16
ws0.column_dimensions['C'].width = 70
lines = [
    ('Relecture du contenu V5 (bloc 2)', None, None),
    ('Rien de ce tableur n\'apparaît dans l\'app tant que ce n\'est pas validé : tout est importé « à valider ».', None, None),
    (None, None, None),
    ('Ce que tu remplis (cases jaunes)', None, None),
    ('Validé', 'oui / non / à revoir', 'oui : l\'exercice ou l\'entraînement devient visible. non : il reste caché. à revoir : précise dans Commentaire.'),
    ('Vidéo OK', 'oui / non', 'non : je cherche une autre vidéo.'),
    ('Commentaire', 'texte libre', 'Ce qu\'il faut changer (consigne, niveau, intensité, vidéo...).'),
    ('Exemple', 'Validé = oui', 'Vidéo OK = non ; Commentaire = « vidéo trop rapide, en trouver une plus pédagogique »'),
    (None, None, None),
    ('Où en est la relecture', 'Nombre', None),
]
for r, (a, b, cc) in enumerate(lines, start=1):
    for col, v in ((1, a), (2, b), (3, cc)):
        cell = ws0.cell(row=r, column=col, value=v)
        cell.font = Font(name=F, size=10)
        cell.alignment = WRAP
ws0['A1'].font = Font(name=F, size=14, bold=True)
for r in (4, 10):
    ws0.cell(row=r, column=1).font = Font(name=F, bold=True)
for r in range(5, 8):
    ws0.cell(row=r, column=1).fill = INPUT
for col in (1, 2, 3):
    ws0.cell(row=8, column=col).fill = EXAMPLE
counts = [
    ('Exercices au total', f"=COUNTA(Exercices!A2:A{last_ex})"),
    ('Dont nouveaux', f'=COUNTIF(Exercices!C2:C{last_ex},"Nouveau")'),
    ('Exercices validés', f'=COUNTIF(Exercices!D2:D{last_ex},"oui")'),
    ('Exercices à revoir', f'=COUNTIF(Exercices!D2:D{last_ex},"à revoir")'),
    ('Vidéos refusées', f'=COUNTIF(Exercices!E2:E{last_ex},"non")'),
    ('Entraînements au total', f"=COUNTA('Entraînements'!A2:A{last_tr})"),
    ('Entraînements validés', f'=COUNTIF(\'Entraînements\'!D2:D{last_tr},"oui")'),
    ('Exercices restant à relire', f'=COUNTA(Exercices!A2:A{last_ex})-COUNTA(Exercices!D2:D{last_ex})'),
    ('Sources consultées', f'=COUNTA(Sources!C2:C{last_src})'),
]
for i, (lab, f) in enumerate(counts, start=11):
    ws0.cell(row=i, column=1, value=lab).font = Font(name=F, size=10)
    ws0.cell(row=i, column=2, value=f).font = Font(name=F, size=10, bold=True)
ws0.cell(row=21, column=1, value='Poids pour estimer les calories (kg)').font = Font(name=F, size=10)
ws0.cell(row=21, column=2, value=60).font = Font(name=F, size=10, color='0000FF')
ws0.cell(row=21, column=2).fill = INPUT
ws0.cell(row=21, column=3, value='Exemple : 60 kg. Change-le pour voir les calories des entraînements à ton poids.').font = Font(name=F, size=10)
n = 23
notes = [
    'À savoir',
    'Un entraînement validé ne s\'affiche que si tous ses exercices sont validés aussi.',
    'Les 43 exercices existants gardent leur nom, leurs consignes et leurs niveaux : seules les étiquettes, le tutoriel, la source et la vidéo sont nouveaux.',
    'Calories : MET x poids x durée (Compendium 2024). La colonne des entraînements prend 60 kg pour exemple ; l\'app utilisera le poids du profil.',
    'Sources : l\'onglet Sources liste chacune des sources consultées, avec son lien, à quoi elle a servi et qui la cite. Elles restent dans la base et dans ce tableur ; l\'app ne les affiche pas. Aucun texte n\'est copié.',
    'Vidéos : liens YouTube trouvés en ligne, en français quand c\'était possible. Je ne peux pas les regarder : c\'est à toi de vérifier qu\'elles montrent le bon mouvement.',
]
for i, t in enumerate(notes):
    cell = ws0.cell(row=n + i, column=1, value=t)
    cell.font = Font(name=F, size=10, bold=(i == 0))
    ws0.merge_cells(start_row=n + i, start_column=1, end_row=n + i, end_column=3)
    cell.alignment = WRAP
    ws0.row_dimensions[n + i].height = 30 if i else 18

wb.save(OUT)
print(OUT)


# =================================================================== FLEXO, bloc Étirements
# Tableur dédié : les 8 nouveaux étirements à valider, les étiquettes de chaque étirement ou mobilité,
# les 7 sets guidés et leurs sources. Mêmes colonnes « Validé » (D) que le bloc 2, pour build-validation.py.
MOMENT = {'avant': 'avant l\'effort', 'apres': 'après l\'effort', 'hors_seance': 'hors séance'}
SPORT = {'velo': 'vélo', 'course': 'course', 'muscu': 'muscu', 'tous': 'tous'}
MODE = {'statique': 'étirement statique', 'dynamique': 'mobilité dynamique', 'activation': 'activation'}


def fmt_tags(t):
    if not t:
        return ['', '', '', '']
    return [', '.join(MOMENT[m] for m in t['moments']), ', '.join(SPORT[x] for x in t['sports']),
            MODE[t['mode']], f"{t['hold']} s" if t['hold'] else '']


def mmss(sec):
    return f"{sec // 60} min {sec % 60:02d} s" if sec % 60 else f"{sec // 60} min"


def link(cell, url):
    cell.hyperlink = url
    cell.font = Font(name=F, size=9, color='0563C1', underline='single')


sets = [t for t in full['entrainements'] if t['type'] == 'etirement']
by_id = {e['id']: e for e in full['exercices']}
used_in = {}
for t in sets:
    for p in t['postures']:
        used_in.setdefault(p['id'], []).append(t['titre'])

wb = Workbook()
# ------------------------------------------------------------------ Sets guidés
ws = wb.active
ws.title = 'Sets guidés'
rows = []
for t in sets:
    deroule = '\n'.join(
        f"{i}. {p['nom']}{' (' + p['consigne'] + ')' if p['consigne'] else ''} : {p['secondes']} s"
        f"{', ' + MODE[p['etiquettes']['mode']] if p['etiquettes'] else ''}"
        for i, p in enumerate(t['postures'], start=1))
    rows.append([t['id'], t['titre'], mmss(t['seconds']), None, None, len(t['postures']), t['zones'], t['description'],
                 deroule, '\n'.join(f"{x['label']} : {x['url']}" for x in t['reperes'])])
last_set = table(ws, ['Identifiant', 'Titre', 'Durée (postures + pauses de 5 s)', 'Validé', 'Commentaire', 'Postures', 'Zones',
                      'Description', 'Déroulé (dans l\'ordre)', 'Repères de construction'], rows,
                 [20, 26, 14, 10, 34, 9, 18, 45, 80, 60], {'Validé', 'Commentaire'})
yesno(ws, 'D', last_set)
for r in range(2, last_set + 1):
    ws.row_dimensions[r].height = 190

# ------------------------------------------------------------------ Nouveaux étirements (Validé en D, comme « Exercices »)
ws = wb.create_sheet('Nouveaux étirements')
rows = []
for e in [x for x in full['exercices'] if x['lot'] == 'etirements']:
    v = e['video']
    rows.append([e['id'], e['nom'], 'Nouveau', None, None, None, *fmt_tags(e['etiquettes']), 'oui' if e['schema'] else 'non',
                 '\n'.join(f"{s['label']} : {s['url']}" for s in e['sources']),
                 e['zones'], e['mode'], e['niveaux'], e['muscles_principaux'], e['muscles_secondaires'],
                 e['consignes'], e['precaution'], e['respiration'], e['erreurs'],
                 f"{v['title']} ({'français' if v['lang'] == 'fr' else 'anglais'})\n{v['url']}" if v else '',
                 ', '.join(used_in.get(e['id'], []))])
heads = ['Identifiant', 'Nom', 'Statut', 'Validé', 'Vidéo OK', 'Commentaire', 'Moment', 'Sport associé', 'Mode',
         'Maintien (par côté)', 'Schéma dessiné', 'Sources', 'Zones', 'Par défaut', 'Niveaux', 'Muscles principaux',
         'Muscles secondaires', 'Consignes', 'Précaution', 'Respiration', 'Erreurs fréquentes', 'Vidéo proposée', 'Utilisé dans']
last_new = table(ws, heads, rows, [20, 30, 10, 10, 10, 30, 20, 16, 18, 10, 9, 60, 14, 12, 34, 22, 22, 55, 35, 28, 34, 50, 34],
                 {'Validé', 'Vidéo OK', 'Commentaire'})
yesno(ws, 'D', last_new)
yesno(ws, 'E', last_new)
for r in range(2, last_new + 1):
    val = ws.cell(row=r, column=22).value
    if val:
        link(ws.cell(row=r, column=22), val.split('\n')[-1])

# ------------------------------------------------------------------ Étiquettes de tous les étirements et mobilités
ws = wb.create_sheet('Étiquettes')
rows = []
tagged = sorted((e for e in full['exercices'] if e['etiquettes']),
                key=lambda e: (list(MODE).index(e['etiquettes']['mode']), e['nom'] or ''))
for e in tagged:
    v = e['video']
    rows.append([e['id'], e['nom'], *fmt_tags(e['etiquettes']), None, None, ', '.join(used_in.get(e['id'], [])),
                 'oui' if e['schema'] else 'non', v['url'] if v else '',
                 '\n'.join(f"{s['label']} : {s['url']}" for s in e['sources'])])
last_tag = table(ws, ['Identifiant', 'Nom', 'Moment', 'Sport associé', 'Mode', 'Maintien (par côté)', 'Étiquettes OK',
                      'Commentaire', 'Utilisé dans', 'Schéma dessiné', 'Vidéo', 'Sources'], rows,
                 [22, 34, 24, 18, 18, 10, 11, 30, 40, 9, 44, 70], {'Étiquettes OK', 'Commentaire'})
yesno(ws, 'G', last_tag)
for r in range(2, last_tag + 1):
    if ws.cell(row=r, column=11).value:
        link(ws.cell(row=r, column=11), ws.cell(row=r, column=11).value)

# ------------------------------------------------------------------ Sources du bloc
ws = wb.create_sheet('Sources')
set_ex_names = {p['nom'] for t in sets for p in t['postures']}
rows = []
for src in full['sources']:
    ex = [x for x in src['exercices'] if x in set_ex_names]
    st = [x for x in src['entrainements'] if x in set_titles]
    if ex or st:
        rows.append([src['type'], src['titre'], src['url'], len(ex), ', '.join(ex), ', '.join(st)])
rows.sort(key=lambda r: (r[0], -r[3] - 100 * len(r[5])))
last_s = table(ws, ['Type', 'Source', 'Lien', "Nombre d'étirements", 'Étirements', 'Sets'], rows,
               [26, 60, 48, 11, 70, 50], set())
for r in range(2, last_s + 1):
    link(ws.cell(row=r, column=3), ws.cell(row=r, column=3).value)

# ------------------------------------------------------------------ Mode d'emploi (en premier)
ws0 = wb.create_sheet("Mode d'emploi", 0)
for col, w in (('A', 46), ('B', 18), ('C', 74)):
    ws0.column_dimensions[col].width = w
lines = [
    ('Relecture du bloc Étirements (FLEXO)', None, None),
    ('Rien n\'apparaît dans l\'app avant validation : les 8 nouveaux étirements et les 7 sets arrivent « à valider ».', None, None),
    (None, None, None),
    ('Ce que tu remplis (cases jaunes)', None, None),
    ('Sets guidés : Validé', 'oui / non / à revoir', 'oui : le set devient visible, à condition que tous ses étirements soient validés.'),
    ('Nouveaux étirements : Validé, Vidéo OK', 'oui / non / à revoir', 'Comme au bloc 2. Vidéo OK = non : je cherche une autre vidéo.'),
    ('Étiquettes : Étiquettes OK', 'oui / non / à revoir', 'Moment, sport associé, mode, maintien. Les étiquettes s\'appliquent dès l\'import : un « non » me dit quoi corriger.'),
    ('Commentaire', 'texte libre', 'Ce qu\'il faut changer : ordre, durée, consigne, étiquette, schéma, vidéo...'),
    (None, None, None),
    ('Où en est la relecture', 'Nombre', None),
]
for r, (a, b, cc) in enumerate(lines, start=1):
    for col, v in ((1, a), (2, b), (3, cc)):
        cell = ws0.cell(row=r, column=col, value=v)
        cell.font = Font(name=F, size=10)
        cell.alignment = WRAP
ws0['A1'].font = Font(name=F, size=14, bold=True)
for r in (4, 10):
    ws0.cell(row=r, column=1).font = Font(name=F, bold=True)
for r in range(5, 9):
    ws0.cell(row=r, column=1).fill = INPUT
counts = [
    ('Sets validés (sur 7)', f"=COUNTIF('Sets guidés'!D2:D{last_set},\"oui\")"),
    ('Nouveaux étirements validés (sur 8)', f"=COUNTIF('Nouveaux étirements'!D2:D{last_new},\"oui\")"),
    ('Vidéos refusées', f"=COUNTIF('Nouveaux étirements'!E2:E{last_new},\"non\")"),
    ('Étiquettes à corriger', f"=COUNTIF('Étiquettes'!G2:G{last_tag},\"non\")+COUNTIF('Étiquettes'!G2:G{last_tag},\"à revoir\")"),
    ('Exercices étiquetés', f"=COUNTA('Étiquettes'!A2:A{last_tag})"),
]
for i, (lab, f) in enumerate(counts, start=11):
    ws0.cell(row=i, column=1, value=lab).font = Font(name=F, size=10)
    ws0.cell(row=i, column=2, value=f).font = Font(name=F, size=10, bold=True)
notes = [
    'À savoir',
    'Avant l\'effort : mobilité dynamique seulement, pas d\'étirement tenu (NHS ; Behm et al. 2016 : un étirement statique de 60 s ou plus avant l\'effort baisse la performance).',
    'Après l\'effort : étirements tenus 15 à 30 s par côté (NHS : 15 à 20 s ; ACSM : 10 à 30 s). Le maintien indiqué est par côté.',
    'Chaque set dure 10 minutes : temps des postures plus 5 s de transition entre deux postures. Aucun matériel, aucun saut.',
    'Sport associé : choix éditorial selon les muscles sollicités par chaque sport, à vérifier de ton côté.',
    'Schémas : silhouettes au trait dessinées pour l\'app, voir content/v5/schemas-etirements.svg. Vidéos : liens YouTube non visionnés, à vérifier.',
    'Les sources restent dans la base et dans ce tableur ; l\'app ne les affiche pas. Aucun texte n\'est copié.',
]
n = 18
for i, t in enumerate(notes):
    cell = ws0.cell(row=n + i, column=1, value=t)
    cell.font = Font(name=F, size=10, bold=(i == 0))
    ws0.merge_cells(start_row=n + i, start_column=1, end_row=n + i, end_column=3)
    cell.alignment = WRAP
    ws0.row_dimensions[n + i].height = 30 if i else 18
wb.save(OUT_ETIR)
print(OUT_ETIR)
