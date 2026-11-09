# Kanata layout guide

Positions are physical keys, named by their letter on the keyboard.

## Layer keys

The home row is plain: every letter key types its letter, with no modifiers on it.

- `AltGr`: SYM layer
- `Win` (left): NUM layer

Caps Lock is Ctrl. Esc and the physical Alt are untouched on the base layer.

How to use them:

- Tap a layer key to toggle its layer on for the whole keyboard. Tap the same key again, or press Esc, to go back to the base layer.
- Hold a layer key and press another key to use the layer only while the key is down. The hold counts as soon as another key is pressed, so there is no waiting.
- A tap is a press shorter than `hold-layer` with no other key pressed in between.
- Esc types an Esc and also returns to the base layer.
- In the NUM layer, only `Win` and Esc return to the base layer. In the SYM layer, only `AltGr` and Esc do.
- `Ctrl+C`: hold Caps Lock, press `c`.
- Alt works as the i3 mod key.
- Holding `j` or `k` for auto-repeat works normally, since the letter keys have no tap-hold.
- `AltGr` no longer types the ABNT2 combinations such as `¹ ² ³ £ ¢ ¬`, and `Win` no longer works as Super.

## NUM layer (toggle or hold `Win`)

Numbers, on the right hand:

- `u` `i` `o`: 7 8 9
- `j` `k` `l`: 4 5 6
- `m` `,` `.`: 1 2 3
- `n`: 0
- `h`: decimal point
- `g`: decimal comma

Operators, on the right hand:

- `y`: `=`
- `p`: `*`
- Key right of `p`: `/`
- `ç`: `+`
- Bottom-right key: `-`

Brackets, on the left hand:

- `w` `s` `x`: `[` `(` `{`
- `r` `f` `v`: `]` `)` `}`

Other:

- `z`: reload the config
- `q` `e` `t` `a` `c` `b`: type their letters
- `d` and `AltGr`: do nothing
- `Win` and Esc: back to the base layer

Ring finger opens, index finger closes.

## SYM layer (toggle or hold `AltGr`)

Left hand:

- `q` `w` `e` `r` `t`: `!` `@` `#` `$` `%`
- `a` `s` `d` `f` `g`: `{` `(` `)` `}` `` ` ``
- `z` `x` `c` `v` `b`: `\` `[` `]` `*` `+`

Right hand:

- `y` `u` `o` `p`: `^` `&` `|` `?`
- `h` `j` `l` `ç`: `-` `=` `_` `/`
- `n` `m` `.` and the bottom-right key: `~` `'` `:` `"`
- `i`, `k`, `,` and the key right of `p` do nothing

Other:

- `Win`: does nothing
- `AltGr` and Esc: back to the base layer

Notes:

- `! @ # $ %` follow the number row order (1 to 5).
- `<` and `>` are Shift + `,` and Shift + `.`.
- `;` is the bottom-right key on the base layer.
- `^`, `~` and `` ` `` are dead keys on ABNT2. The layer types them followed by a space, so you get an extra space after each.

## Learning plan

- Week 1: only the NUM layer. Type numbers and sums.
- Week 2: brackets, `Win` + `s` / `f` / `x` / `v`, while writing small bits of code.
- Week 3: the most common SYM symbols: `(` `)` `_` `-` `=` `"`.
- After that: the rare ones (`^`, `~`, `\`, `|`).

Tips:

- If you hit the wrong key, press Backspace and retry without looking down.
- To toggle a layer, tap the layer key alone. Pressing another key while it is down makes it a hold.
- Ten minutes a day beats one long session.

## Tuning

Values live in the `defvar` block. Change them in steps of 20 ms.

- `tap`: 200
- `hold-layer`: 300

Problems and fixes:

- A slow tap on `AltGr` or `Win` acts as a hold instead of toggling: raise `hold-layer`.
- A quick press meant as a hold toggles the layer instead: press the other key before releasing the layer key, or lower `hold-layer`.

## Commands

- Reload the config: toggle or hold `Win`, press `z`
- Restart after editing the service file: `sudo systemctl daemon-reload` then `sudo systemctl restart kanata`
- Follow the log: `sudo journalctl -u kanata -f`
- Validate the config: `kanata --cfg ~/.config/kanata/kanata.kbd --check`

If the file has a syntax error, kanata logs it and keeps the previous config running.
