#!/usr/bin/env bash
set -euo pipefail

script=$(cd -- "$(dirname -- "$0")" && pwd)/organize_files.sh
sandbox=$(mktemp -d "${TMPDIR:-/tmp}/ak2-variant2.XXXXXXXX")
trap 'rm -rf -- "$sandbox"' EXIT

mkdir -p "$sandbox/input/nested"
printf 'one\n' > "$sandbox/input/report.txt"
printf 'two\n' > "$sandbox/input/file with spaces.txt"
printf 'three\n' > "$sandbox/input/.hidden"
printf 'four\n' > "$sandbox/input/-leading-dash"
printf 'nested\n' > "$sandbox/input/nested/stays.txt"
ln -s report.txt "$sandbox/input/link"

bash "$script" "$sandbox/input"
for name in report.txt 'file with spaces.txt' .hidden -leading-dash; do
    [[ ! -f "$sandbox/input/$name" ]]
    [[ -f "$sandbox/input/${name}_dir/$name" ]]
done
[[ $(cat "$sandbox/input/report.txt_dir/report.txt") == one ]]
[[ $(cat "$sandbox/input/file with spaces.txt_dir/file with spaces.txt") == two ]]
[[ $(cat "$sandbox/input/.hidden_dir/.hidden") == three ]]
[[ $(cat "$sandbox/input/-leading-dash_dir/-leading-dash") == four ]]
[[ -f "$sandbox/input/nested/stays.txt" && -L "$sandbox/input/link" ]]
printf 'PASS: файли, пробіли, приховані імена, початковий дефіс; вкладені файли й посилання збережено\n'

bash "$script" "$sandbox/input"
[[ ! -e "$sandbox/input/report.txt_dir_dir" ]]
printf 'PASS: повторний запуск не створює вкладених каталогів для вже розкладених файлів\n'

mkdir -p "$sandbox/collision/item_dir"
printf 'source\n' > "$sandbox/collision/item"
printf 'destination\n' > "$sandbox/collision/item_dir/item"
if bash "$script" "$sandbox/collision"; then
    printf 'FAIL: очікувалася помилка колізії\n' >&2
    exit 1
fi
[[ $(cat "$sandbox/collision/item") == source ]]
[[ $(cat "$sandbox/collision/item_dir/item") == destination ]]
printf 'PASS: наявний файл не перезаписано, джерело збережено\n'

mkdir "$sandbox/empty"
bash "$script" "$sandbox/empty"
if bash "$script" "$sandbox/missing"; then
    printf 'FAIL: відсутній каталог прийнято\n' >&2
    exit 1
fi
printf 'PASS: порожній каталог і помилковий аргумент\n'
