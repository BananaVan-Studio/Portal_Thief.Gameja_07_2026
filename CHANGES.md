# Changes added for the game jam

Open the project in Godot 4.5. The `.godot/` cache was removed on purpose so
Godot reimports everything cleanly on first open (this is normal, let it
finish). Your `.git` history is untouched, so `git diff` / `git status` shows
exactly what changed.

## New files
- `autoloads/game.gd` — global state: the movement **rules** (`allow_sprint`,
  `allow_dash`) plus settings (`master_volume`, `fullscreen`).
- `autoloads/scene_manager.gd` — fade transitions, scene changing, the reset
  key, the pause overlay, and the on-screen "house rule" toast. It's a
  persistent `CanvasLayer`, so the fade covers the gap while the next scene
  loads (the pattern from the tutorial you linked).
- `levels/level.gd` — attach to a level root; declares that house's rules with
  two inspector checkboxes.
- `menu/main_menu.tscn` + `.gd` — Play / Settings / Quit. This is now the game's
  main scene.
- `menu/settings_menu.tscn` + `.gd` — volume slider + fullscreen toggle, reused
  by both the main menu and the pause menu.
- `menu/pause_menu.tscn` + `.gd` — Resume / Restart / Settings / Main menu.
- `menu/win_screen.tscn` + `.gd` — shown after the last house.
- `levels/level_2.tscn`, `levels/level_3.tscn` — two more houses (see below).

## Changed files
- `project.godot`
  - main scene is now `menu/main_menu.tscn`.
  - registered `Game` and `SceneManager` autoloads.
  - added input actions: **Reset = R**, **Pause = Esc**.
- `player/player.gd` — sprint and dash are now gated behind `Game.allow_sprint`
  / `Game.allow_dash`. On death it restarts the level via `SceneManager`
  (before, death just left you on a black screen).
- `levels/finish_area.gd` — **fixed:** it used to call `load(...)`, which loads
  the scene into memory but never switches to it, so levels never advanced. It
  now calls `SceneManager.go_to_level(next_level)`.
- `levels/starting_position.gd` — new intro: it holds on a **wide shot of the
  whole house**, then the "bad guy" (a black square) **runs from the bottom
  entrance up to the top gate** tracing the escape route, then the camera
  sweeps down to the player and spawns them (your original spawn is unchanged).
  On a **restart** (the "R" key or dying) the intro is skipped entirely — the
  player just spawns straight away. Toggle per-level with `intro_enabled`.
- `levels/level_0.tscn` / `levels/level_1.tscn` — root now uses `level.gd`, and
  each `FinishArea.next_level` is set so the houses chain together.

## The four houses / rules progression
| Level | Rules |
|-------|-------|
| level_0 | free (sprint + dash) — tutorial |
| level_1 | no sprinting |
| level_2 | no dashing |
| level_3 | no sprinting **and** no dashing — final |

`level_3`'s `FinishArea.next_level` is `99`; there's no `level_99.tscn`, so
`SceneManager` sends the player to the win screen. To add a 5th house: duplicate
a level, set its rules on the root node, point the previous house's
`FinishArea.next_level` at it, and set the new house's `next_level` to `99`.

**Note:** `level_2` and `level_3` are clones of `level_1`'s layout (I copied the
tilemap so it stays valid) with different **rules** and slightly moved obstacles.
Rearrange the tiles/pits/obstacles in the editor to make each house feel
distinct — the mechanics are already wired.

## Still a manual editor step: the top/bottom gates (TODO #3)
The level transition itself is fixed, so walking into the `FinishArea` at the
top now loads the next house. But whether you can physically *walk through* the
top/bottom gate depends on the collision tiles in the `TileMapLayer`, which I
can't safely edit outside the editor. To open a gate: select the
`TileMapLayer`, and in the gate opening erase the wall tiles (or paint
non-colliding floor tiles) so there's a clear gap lined up with the
`StartingPosition` (bottom) and `FinishArea` (top). It's a ~1-minute paint job
per level once you see it rendered.

## How the pieces connect at runtime
- Boot → `main_menu` → **Play** → `SceneManager.go_to_level(0)`.
- Each level root (`level.gd`) pushes its rules into `Game` and tells
  `SceneManager` it's in a level (so R / Esc become active) and flashes the rule.
- **R** restarts the current house; **Esc** opens the pause menu.
- Reaching a `FinishArea` advances to `next_level`; past the last house you hit
  the win screen.

## Level design (all built on level 0's layout)
All four levels share level 0's exact tilemap, so the base house — start at the
bottom gate, finish at the top gate, alarm zone covering the lower-left, pit
wall down the right side — is identical everywhere. Levels differ only by rules
plus node-based **fog** and **blocks**, which are safe to drag around in the
editor.

Two reusable mechanics:
- **Fog** (`FoggedAreas`, a `Node2D` with a dark `modulate`): its child
  `ColorRect`s darken regions, and the *gaps between them* form the lit safe
  path. Level 1 darkens the left and right halves, leaving a lit vertical
  corridor (x ~529–656) straight between the alarm and the pits. Move a rect's
  edges to widen/narrow the corridor. Set the node `visible = false` to disable.
- **Blocks** (`Hubris` instances under `Obstacles`): small solid shapes you must
  walk around. Duplicate one, move it, done.

Current starting configuration (tune visually in-editor — I placed these by
coordinates, so nudge them once you see them rendered):
- **Level 0 — free:** no fog, no blocks. Teaches movement.
- **Level 1 — no sprint:** fog corridor + 2 blocks pinching it. Slow, tense walk.
- **Level 2 — no dash:** fog off (clear vision), a 4-block **slalom** up the
  centre so you must weave instead of dashing straight through.
- **Level 3 — no sprint + no dash:** fog corridor + 3 **blind pinch points** in
  it. The hardest house.

Design tips for making them fun:
- Tie each obstacle to the missing ability. No-dash levels want gaps/weaves that
  a dash would trivialise; no-sprint levels want the alarm zone on the critical
  path so the slow crossing is nerve-wracking.
- The alarm zone rewards speed, so it bites hardest in no-sprint houses — route
  the corridor through it.
- Keep blocks inside the lit corridor (roughly x 529–656) so foggy levels stay
  fair; keep them clear of the pit wall (x > ~670) and the alarm (x < ~528).

## Boss fight (level_4) — revised
The walls are non-solid "shove-zones" (`Area2D`), not solid bodies. While you're
in a wall's solid part it pushes you downward (`wall_push`, default 400 — above
sprint speed, below dash), but it never blocks or traps you. This fixes the
clipping/getting-stuck bug that made narrow gaps impossible: with solid moving
bodies the round player would catch on a corner or get pinned by the descending
wall. Now you can always move; missing the gap just shoves you toward the
precipice. Note the player is ~20px wide, so gaps below ~40 are extremely tight
(still passable, just precise). Other updates over the first pass: the boss is now a small red square styled like the
player (not a big block); the level-intro thief is now red too, to match. The
camera holds a fixed wide view of the whole arena (zoom ~0.55) after a short
presentation where the camera zooms in on the boss, the red square "runs" side
to side, then pulls back to reveal the arena. Hazards spawn faster
(`spawn_interval` 1.1s) and there are now two kinds: solid gap walls, and
full-width pits you must be dashing through or you fall. Pits only appear while
dashing is allowed, so they stay fair as the rules rotate. All still tunable on
the root node (`wall_speed`, `pit_speed`, `gap_width`, `spawn_interval`,
`rule_interval`, `fight_zoom`).

### Original notes
## Boss fight (level_4)
A capstone fight added as `levels/level_4.tscn` (+ `levels/boss.gd`), so it slots
into the existing progression: level 3 now exits to it, and beating it routes to
the win screen (`go_to_level(5)` — no such level, so it falls through to the win
screen, same trick as before).

How it works:
- The red square boss sits at the top; the player spawns at the bottom and must
  climb up and touch it to win.
- The boss sweeps solid red walls downward, each with one gap. Miss the gap and
  the wall shoves you back down toward the precipice (the dark strip along the
  bottom). Fall in and you lose — it reuses the pit `fall_down` death, which
  restarts the fight.
- The movement rules rotate every few seconds: no sprint -> no dash -> neither ->
  repeat, announced by the toast each time. So the way you climb keeps changing.
- It reuses your `StartingPosition` (with `intro_enabled = false`) for spawning,
  so no thief intro plays here. R restarts, Esc pauses, like any level.

Everything is exposed on the `BossLevel` root node in the inspector, so you can
tune it without touching code: `wall_speed`, `gap_width`, `spawn_interval`,
`rule_interval`, and the arena bounds. Starting values are conservative.

Two things to verify on first playtest (I couldn't run the editor here):
1. The walls should physically push the player. They're `AnimatableBody2D` with
   `sync_to_physics = true`, which is Godot's moving-platform push, and the
   player is a `CharacterBody2D` on the default collision layer 1 — so it should
   work out of the box. If a wall ever slides through the player instead of
   shoving them, bump `wall_speed` up or confirm the player's collision
   layer/mask is still 1.
2. Tune `gap_width` / `wall_speed` / `spawn_interval` for difficulty — with the
   rules rotating, the no-sprint phase is the hardest to reposition in, so make
   sure a gap is always reachable at a walk.

## Menu restyle + rename
The game is renamed to **Catch a Burglar** (project name, main-menu title, and
win screen). The menus got a Super Meat Boy-style pass: near-black warm
background, blood-red chunky buttons with thick outlines and a punchy
brighter-red hover/focus state, and big red title text with a heavy dark
outline and drop shadow. Styling lives in `menu/ui_style.gd` (a small static
helper, class `UiStyle`) and is applied from each menu's `_ready`, so there's no
theme resource to hand-maintain and it's easy to tweak the palette in one place.
Note: this uses Godot's built-in font with heavy outlines to get the chunky
look — dropping in an actual grungy display font (Settings > import a .ttf and
set it in `UiStyle`) would push it the rest of the way.

## Portal Burglar — rename, blue menus, tutorial, sound
Renamed the game to **Portal Burglar** (project name + main-menu title). The
main-menu tagline now reads: "A burglar is using portals to break into houses.
Follow the rules of each house to catch the burglar." The menu palette went back
to the blue style (navy background, blue chunky buttons) — the whole palette is
the constants at the top of `menu/ui_style.gd`.

Added a **Tutorial** button on the main menu that opens a controls overlay
(`menu/tutorial.tscn`): Move — WASD / Arrow Keys, Run — Shift, Dash — Space,
plus R to restart and Esc to pause.

Sound, via a new `AudioManager` autoload (`autoloads/audio_manager.gd`),
everything on the Master bus so the settings volume slider controls it:
- `musica.mp3` — looping background music; starts at the menu and plays under
  every scene continuously (autoload, so it never restarts between screens).
- `portal.wav` — plays when you spawn in at the start portal and when you reach
  the finish portal (and when you catch the boss).
- `caida.wav` — replaces the old fall sound; the player's `AudioStreamPlayer`
  now points at it, still triggered by the `fall_down` animation on pits and the
  boss precipice.
- `correr.mp3` — when you start running (Shift, while sprinting is allowed).
- `dash.wav` — when a dash actually fires.
- `boton_avanzar_en_menu.wav` — forward menu actions (Play, Tutorial, opening
  Settings from either menu).
- `boton_atras_en_menu.wav` — Back, Quit, and the pause buttons (Resume,
  Restart, Main menu); the pause Settings button uses the advance sound.

The 7 audio files live in `audio/`. Godot will import them on first open.

## Audio buses, boss finish, no wall bounce
Three tweaks:
- Settings now has three volume sliders: Volume (Master), Music, and Sound FX.
  Music and SFX are sub-buses that feed into Master, so Volume scales everything
  while Music/SFX balance the two groups. Buses are created at runtime by
  `AudioManager`; the music player uses the Music bus, all SFX (including the
  player's fall sound) use the SFX bus. Nudging the SFX slider plays a short blip
  on release so you can hear the level.
- The boss no longer shows a "You beat the house!" message on finish — it just
  plays the portal sound and goes to the win screen.
- The boss walls no longer bounce you. The downward shove is now applied as
  velocity (blended into the player's own movement, smooth like wind) instead of
  nudging the player's position each frame, which was what caused the bounce.
  Walls still push you toward the precipice and never trap/clip you.

## Alarm music rush + boss wall fix (round 2)
- Entering an alarm zone now speeds the background music to 2x (pitch/tempo up),
  and it drops back to normal the moment you leave. Handled in `AudioManager`
  (`ALARM_MUSIC_PITCH`, default 2.0 — bump to 3.0 for x3), driven by the alarm
  zone's enter/exit. Scene changes and level restarts reset it, so dying inside
  an alarm can't leave the music stuck fast.
- Fixed the boss walls flinging the player. The velocity-based push accumulated
  every idle frame (the deceleration branch kept re-adding it), which is what
  made you fly away. The push is now a direct `move_and_collide` after
  `move_and_slide`, so it's a steady downward shove that can't build up — no
  clip, no bounce, no launch. Strength is still `wall_push` on the boss node.

## Title art background + Portal Thief
Added the uploaded title art as the main-menu background
(`assets/portal_thief_bg.jpg`, shown full-screen with keep-aspect-cover). Since
the art already contains the "PORTAL THIEF" logo, the text title and the
description line were removed from the menu, and the four buttons were moved into
the open lower-left corner so they don't cover the two characters. The buttons
keep the blue style you liked (they're opaque with outlines, so they stay legible
over the art). Renamed the game to **Portal Thief** to match the art (project
name + the win screen now reads "THIEF CAUGHT!"). Only the main menu uses the
image; the pause/settings/tutorial/win screens are unchanged.

## Palette match to the title art
Re-skinned the menus and level backgrounds to the Portal Thief art palette
(lavender / dark plum / thief red / cream), all driven from the constants at the
top of `menu/ui_style.gd`:
- Buttons are now violet with a thief-red hover/focus and cream text.
- Overlays (settings, pause, tutorial) use a dark-plum dim; the win screen uses a
  dark-plum background; titles are light lavender.
- Level backgrounds match the art: the outer void is the lavender from the image,
  and the house floor is a dark violet (kept dark so the white player stays
  readable). Applied to all four houses and the boss arena (which got a
  dark-violet floor), and the window clear color is lavender so any void reads as
  the art's purple.

## Level redesign (no tilemap edits), map bounds, boss dash fix
Without touching the tilemap, worked with nodes:
- **Broke the straight line.** The hazards all sat on the sides (pits right, alarm
  left), leaving the center open, and the fog funnelled you up that open middle.
  Removed the fog from levels 1-3 (reveals the full maze) and added pits down the
  centre of each house. Pits are rule-adaptive: dash straight over them when
  dashing is allowed (levels 0-1), weave around them when it isn't (levels 2-3),
  so the same pits create different challenges per rule. The alarm now has a real
  countdown (`caught_margin` per level) so straying into it matters.
- **Map bounds.** Added `levels/bounds.tscn` (invisible walls) to every house so
  you can't walk out the top or bottom gate into the void; the finish is still
  reachable and the start is unaffected.
- **Boss walls no longer dashable.** Raised `wall_push` to 760 (above dash speed
  700), so a dash can't punch through a wall anymore — only pits are dashable, as
  intended.

IMPORTANT: the centre pits are placed by coordinate (I can't see your maze), so
open each level and, if any pit sits inside a wall or its detour is blocked, drag
it — they're plain nodes under "Pits", so it's a few seconds each. Same for the
alarm timings and pit spacing: tune to taste.

## Dash-through-walls (real fix) + alarm siren
- The boss dash-through-walls bug: the player's dash branch returned early,
  before the wall-push line, so the shove was never applied mid-dash. Now the
  push runs during the dash too, so dashing into a wall gets shoved down like
  everything else — walls are un-dashable, only pits are dashable.
- Added `audio/alarm.wav`; it plays the moment the alarm countdown hits zero
  (when you're caught), via `AudioManager.alarm_siren()`.
