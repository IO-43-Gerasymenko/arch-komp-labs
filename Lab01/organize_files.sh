#!/usr/bin/env bash

# Варіант 2: розкласти файли одного каталогу по окремих підкаталогах.
if (( $# != 1 )) || [[ ! -d $1 ]]; then
    printf 'Використання: %s КАТАЛОГ\n' "${0##*/}" >&2
    exit 2
fi

# Абсолютний шлях також усуває неоднозначність аргументів із початковим «-».
target=$(cd -- "$1" && pwd -P) || exit 1
shopt -s nullglob dotglob
entries=("$target"/*)
result=0

for entry in "${entries[@]}"; do
    name=${entry##*/}
    if [[ -L $entry ]]; then
        printf '%s: символічне посилання пропущено\n' "$name"
    elif [[ -d $entry ]]; then
        printf '%s є директорією\n' "$name"
    elif [[ -f $entry ]]; then
        destination="${entry}_dir"
        if [[ -L $destination ]] || { [[ -e $destination ]] && [[ ! -d $destination ]]; }; then
            printf '%s: шлях призначення не є звичайним каталогом\n' "$name" >&2
            result=1
            continue
        fi
        if [[ -e $destination/$name || -L $destination/$name ]]; then
            printf '%s: файл призначення вже існує, переміщення пропущено\n' "$name" >&2
            result=1
            continue
        fi
        if mkdir -p -- "$destination" && mv -n -- "$entry" "$destination/"; then
            printf '%s переміщений до %s_dir\n' "$name" "$name"
        else
            result=1
        fi
    else
        printf '%s: спеціальний файл пропущено\n' "$name"
    fi
done

exit "$result"
