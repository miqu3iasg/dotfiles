# Kanata layout guide

Positions are physical keys, named by their letter on the keyboard.

## Home row

Tap types the letter. Hold gives the modifier or layer.

- `a`: Ctrl (left)
- `s`: Alt
- `d`: NUM layer
- `f`: Shift (left)
- `j`: Shift (right)
- `k`: SYM layer
- `l`: Alt
- `ç`: Ctrl (right)

Caps Lock is also Ctrl. Esc, the physical Alt and AltGr are untouched.

How to use them:

- A hold only counts when you press and release another key while holding.
- Use the modifier on the opposite hand: `f` for Shift on right-hand letters, `j` for left-hand letters.
- `Ctrl+C`: hold `ç`, press `c`. `Ctrl+L`: hold `a`, press `l`.
- Alt on `s` or `l` works as the i3 mod key.
- Tapping `j` or `k` repeatedly is fine. Holding one alone for auto-repeat will turn into Shift or SYM after the hold time. To repeat, tap the key and press it again right away (within the `tap` time) and hold. In vim you can also use counts, like `10j`.
- Raising a hold time costs almost nothing for shortcuts: the hold kicks in as soon as you release the other key, without waiting for the timeout.

## NUM layer (hold `d`)

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
- `d`: does nothing

Ring finger opens, index finger closes.

## SYM layer (hold `k`)

Left hand:

- `q` `w` `e` `r` `t`: `!` `@` `#` `$` `%`
- `a` `s` `d` `f` `g`: `{` `(` `)` `}` `` ` ``
- `z` `x` `c` `v` `b`: `\` `[` `]` `*` `+`

Right hand:

- `y` `u` `o` `p`: `^` `&` `|` `?`
- `h` `j` `l` `ç`: `-` `=` `_` `/`
- `n` `m` `.` and the bottom-right key: `~` `'` `:` `"`
- `i`, `k` and `,` do nothing, because that finger is holding `k`

Notes:

- `! @ # $ %` follow the number row order (1 to 5).
- `<` and `>` are Shift + `,` and Shift + `.`.
- `;` is the bottom-right key on the base layer.
- `^`, `~` and `` ` `` are dead keys on ABNT2. The layer types them followed by a space, so you get an extra space after each.

## Learning plan

- Week 1: only the NUM layer. Type numbers and sums.
- Week 2: brackets, `d` + `s` / `f` / `x` / `v`, while writing small bits of code.
- Week 3: the most common SYM symbols: `(` `)` `_` `-` `=` `"`.
- After that: the rare ones (`^`, `~`, `\`, `|`).

Tips:

- If you hit the wrong key, press Backspace and retry without looking down.
- Release each key before pressing the next one in normal typing. Overlap is what confuses tap-hold.
- Ten minutes a day beats one long session.

## Tuning

Values live in the `defvar` block. Change them in steps of 20 ms.

- `tap`: 200
- `hold-pinky`: 350
- `hold-ring`: 330
- `hold-index`: 300
- `hold-layer`: 300

Problems and fixes:

- A letter disappears or turns into a modifier: raise the hold time for that finger.
- A modifier fires while typing: raise the hold time for that finger.
- Letters appear late: this is normal for tap-hold. If it bothers you, try `tap-hold-require-prior-idle`.
- A roll like "do" turns into `9`: raise `hold-layer`.
- Double letters like `ff` or `ll` fail: adjust `tap`.

## Commands

- Reload the config: hold `d`, press `z`
- Restart after editing the service file: `sudo systemctl daemon-reload` then `sudo systemctl restart kanata`
- Follow the log: `sudo journalctl -u kanata -f`
- Validate the config: `kanata --cfg ~/.config/kanata/kanata.kbd --check`

If the file has a syntax error, kanata logs it and keeps the previous config running.
