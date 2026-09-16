#!/usr/bin/env bash
# Módulo bluetooth para polybar: ícone + nº de dispositivos conectados.
#
# O ícone (nf-fa-bluetooth, U+F293) é gerado a partir dos bytes UTF-8
# explícitos em vez de um caractere literal no arquivo — isso evita
# qualquer problema de encoding/perda de glifo ao transferir o script.
# UTF-8 de U+F293 = 0xEF 0x8A 0x93
ICON=$(printf '\xEF\x8A\x93')

if ! bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    printf '%s off\n' "$ICON"
    exit 0
fi

count=$(bluetoothctl devices Connected 2>/dev/null | wc -l)
printf '%s %s\n' "$ICON" "$count"
