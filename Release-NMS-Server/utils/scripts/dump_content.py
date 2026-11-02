"""Dump Voidforged's world content (no accounts, characters or other player data) to a zip.

    python utils/scripts/dump_content.py [--config Build/bin/Release/eqemu_config.json] [--out database/voidforged-content.zip]
    python utils/scripts/dump_content.py --box user@host [--identity key_file] [--box-dir voidforged/src/docker]

--box reads a server running from docker/ over SSH instead of a local one, and needs only ssh here.

Tables: EQEmu's content and server tables (common/database_schema.h) plus the custom content tables
below. Player, login, state, query-server and *_backup_* tables are never included. Locally, the database
password is read from eqemu_config.json and handed to mysqldump in a temporary options file.
The zip also holds spells_us.txt, written by export_client_files on the same server.
Without --box, needs mysqldump (MariaDB's bin folder) on PATH.
"""
import argparse
import json
import os
import re
import shlex
import subprocess
import tempfile
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))

# Custom content tables EQEmu's schema lists don't know about
CUSTOM_CONTENT = [
    'armor_set_bonuses', 'armor_set_items',                              # set bonuses (zone/client.cpp)
    'dynamic_items', 'dynamic_affix_pool', 'dynamic_affix_suffixes',     # dynamic items (zone/dynamic_items.cpp)
    'progression_atlas', 'progression_flags', 'progression_stages',      # NMS progression
    'rank_ability_mapping',
]

CLIENT_SPELL_ID_LIMIT = 45000

# Published rule values that differ from the dumping server's own: appended to the snapshot only, never written to
# the database being dumped
PUBLISHED_RULES = {
    'Custom:AutoScribeSpells': 'false',
    'Custom:AutoLearnDisciplines': 'false',
    'Custom:NmsLootEmptySoloCorpse': 'true',
}

DUMP_OPTIONS = ['--single-transaction', '--skip-comments', '--no-tablespaces', '--default-character-set=utf8mb4']


def schema_tables(func):
    src = open(os.path.join(ROOT, 'common', 'database_schema.h'), encoding='utf-8', errors='ignore').read()
    body = re.search(r'std::vector<std::string> ' + func + r'\(\)\s*\{(.*?)\n\t\}', src, re.S).group(1)
    return re.findall(r'"([a-z0-9_]+)"', body)


class LocalServer:
    def __init__(self, config, tmp):
        self.bin_dir = os.path.dirname(os.path.abspath(config))
        self.db = json.load(open(config))['server']['database']
        self.opts = os.path.join(tmp, 'my.cnf')
        with open(self.opts, 'w') as f:
            f.write(f"[client]\nhost={self.db['host']}\nport={self.db['port']}\nuser={self.db['username']}\npassword={self.db['password']}\n")

    def tables(self):
        return subprocess.run(['mysql', f'--defaults-extra-file={self.opts}', '-N', '-e', 'SHOW TABLES', self.db['db']],
                              capture_output=True, text=True, check=True).stdout.split()

    def dump(self, tables, out):
        subprocess.run(['mysqldump', f'--defaults-extra-file={self.opts}', *DUMP_OPTIONS, self.db['db']] + tables,
                       stdout=out, check=True)

    def spell_file(self):
        subprocess.run([os.path.join(self.bin_dir, 'export_client_files'), 'spells'], cwd=self.bin_dir, check=True,
                       stdout=subprocess.DEVNULL)
        with open(os.path.join(self.bin_dir, 'export', 'spells_us.txt'), 'rb') as f:
            return f.read()


class BoxServer:
    """A server started from docker/docker-compose.yml, reached over SSH. Its secrets stay in the containers."""

    def __init__(self, host, identity, box_dir):
        self.ssh = ['ssh', '-o', 'BatchMode=yes'] + (['-i', identity] if identity else []) + [host]
        self.box_dir = box_dir

    def _exec(self, service, command, **kwargs):
        remote = f'cd {shlex.quote(self.box_dir)} && docker compose exec -T {service} sh -c {shlex.quote(command)}'
        return subprocess.run(self.ssh + [remote], check=True, **kwargs)

    def tables(self):
        return self._exec('db', 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -N -e "SHOW TABLES" "$MARIADB_DATABASE"',
                          capture_output=True, text=True).stdout.split()

    def dump(self, tables, out):
        options = ' '.join(DUMP_OPTIONS)
        names = ' '.join(tables)
        self._exec('db', f'mariadb-dump -uroot -p"$MARIADB_ROOT_PASSWORD" {options} "$MARIADB_DATABASE" {names}', stdout=out)

    def spell_file(self):
        self._exec('server', 'cd /data && mkdir -p export && /opt/vf/bin/export_client_files spells >/dev/null',
                   stdout=subprocess.DEVNULL)
        data = self._exec('server', 'cat /data/export/spells_us.txt', stdout=subprocess.PIPE).stdout
        # Same line endings as the Windows exporter, the form tested on the client
        return data.replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--config', default=os.path.join(ROOT, 'Build', 'bin', 'Release', 'eqemu_config.json'))
    ap.add_argument('--out', default=os.path.join(ROOT, 'database', 'voidforged-content.zip'))
    ap.add_argument('--box', help='user@host of a server running from docker/')
    ap.add_argument('--identity', help='SSH key for --box')
    ap.add_argument('--box-dir', default='voidforged/src/docker', help='docker/ folder on the box, from the home folder')
    args = ap.parse_args()

    wanted = schema_tables('GetContentTables') + schema_tables('GetServerTables') + CUSTOM_CONTENT

    with tempfile.TemporaryDirectory() as tmp:
        server = BoxServer(args.box, args.identity, args.box_dir) if args.box else LocalServer(args.config, tmp)

        present = server.tables()
        tables = [t for t in dict.fromkeys(wanted) if t in present]
        missing = [t for t in dict.fromkeys(wanted) if t not in present]
        if missing:
            print('not in this database, skipped:', ' '.join(missing))

        sql = os.path.join(tmp, 'voidforged-content.sql')
        with open(sql, 'wb') as f:
            server.dump(tables, f)
            for rule, value in PUBLISHED_RULES.items():
                f.write(f"REPLACE INTO rule_values (ruleset_id, rule_name, rule_value, notes) "
                        f"VALUES (1, '{rule}', '{value}', '');\n".encode())

        os.makedirs(os.path.dirname(args.out), exist_ok=True)
        # The client spell file, from the server's own exporter (it rewrites rows; a raw spells_new dump won't match)
        spells = server.spell_file()

        with zipfile.ZipFile(args.out, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as z:
            z.write(sql, 'voidforged-content.sql')
            # IDs in the 50000s stop spell animations on the client (common/repositories/spells_new_repository.h);
            # filtered here too so an exporter built before that limit can't put them in the snapshot
            z.writestr('spells_us.txt', b''.join(line for line in spells.splitlines(keepends=True)
                                                 if int(line.split(b'^', 1)[0]) < CLIENT_SPELL_ID_LIMIT))
        print(f'{len(tables)} tables, {os.path.getsize(sql) / 1e6:.1f} MB SQL -> {args.out} '
              f'({os.path.getsize(args.out) / 1e6:.1f} MB)')


if __name__ == '__main__':
    main()
