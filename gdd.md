Captain Sharpe - GDD / Roadmap

Engine: Godot 4.6

Style: 2D pixel platformer, 16×16 assets, speedrun-friendly

Target: 5–10 short levels, scene-based exits, vertical slice → itch.io release

Repo: https://github.com/CaptainTiki/Sharpe

Core Mechanics



Movement: Run (accel/friction), Jump/Double Jump, Wall Jump/Wall Slide, Coyote Time + Jump Buffer, Crouch + Crouch Slide (momentum carry under low gaps)

Dart Gun: Straight horizontal shoot (facing direction only), fires one dart that sticks to surfaces and becomes a temporary bouncy springboard platform. 1.8 s reload (one use per sequence). Dart despawns after 8 s or next shot.

Fake Walls: Look like normal tiles (tiny crack tell). Jump/walk straight through → secret room instantly revealed (blocker tile fades). Resets on death.

Collectibles: 3 Dream Orbs per level (hidden in secrets or high-skill routes).

Death/Respawn: Instant (0.3 s), timer resets, orbs reset per attempt.

Progression: Local high-score file only (per-level time + orb count). S+ rank = all orbs + under par time.



Art \& Audio Specs



Everything: 16×16 pixels, chunky retro (Commander Keen vibe). No anti-aliasing.

Tilesets: Exactly 4 themes. Each theme = 8×8 atlas (max 16 unique 16×16 tiles). No color-shifting inside a theme.

Theme 1: Bedroom / House Interior

Theme 2: Hallway / Pirate Ship Deck

Theme 3: Treehouse / Backyard Sky Fortress

Theme 4: Sewer / Underground Lava Dungeon + Neighbor’s Yard



Player: Finn Sharpe (football helmet, red hoodie, blue jeans, flowing cape). Separate cape layer. Idle/run/jump/crouch/shoot animations.

Parallax: Max 3 layers standard + optional 4th far background or blurred close foreground (for depth moments).

Audio: Chiptune only (120–140 BPM loops per theme). 8-bit SFX (jump, dart thunk/boing, slide, orb chime).



Tech Setup (main.tscn Foundation)



Root Scene (main.tscn): Persistent. Contains:

MenuManager

GameManager (level loading, timer, transitions)

DataManager (persistent: times, orbs, high scores)

CanvasLayer (global HUD: timer + orb counter)

LevelContainer (Node2D – levels are instanced here)



Levels: Lightweight .tscn files in scenes/levels/. Each has TileMap, Player instance/spawn, exit Area2D, parallax, orbs, fake walls.

Transitions: GameManager handles load/unload via handle\_level\_exit(next\_path).

Controls (keyboard-first):

WASD / Arrows – move

Space – jump

Left Shift / C – crouch + slide

Ctrl / X – shoot dart

Full controller support (A=slide, B=jump, RT=shoot)





Roadmap (Phases – 4 weekends max)

Phase 0 – Done



main.tscn + managers + DataManager + CanvasLayer + LevelContainer skeleton



Phase 1 – This Weekend (Vertical Slice)



Reusable Player.tscn with full movement + dart gun

Bedroom\_01 fully playable (Theme 1 tiles, parallax 3 layers, 3 fake walls, 3 orbs, exit)

Timer + orb HUD + instant respawn + death handling

Main menu → Bedroom load → end-level transition stub

Push \& playtest: tune numbers (jump velocity, dart bounce, slide momentum)



Phase 2 – Next Weekend



Themes 2–4 tilesets + 3 more levels (one per theme)

Fake wall triggers + orb collection system

Level select screen + basic high-score save

Polish: particle feedback, screen shake on death/land



Phase 3 – Weekend 3



Remaining 4–6 levels (total 8–10)

End sequence (victory screen + stats)

Audio integration (loops + SFX)

Polish pass + S+ rank logic



Phase 4 – Weekend 4 (Ship)



Export-ready (Windows/HTML5)

itch.io page assets (title screen, screenshots)

Optional: local leaderboard file + secret dream journal entries

Decision point: stop at 10 levels or add metroidvania hub (backburner)



Hard Scope Limits



Max 3 enemy types total

No save system beyond high scores

No mouse aiming, no lives, no cutscenes

If anything feels like “extra system” → park for Phase 2+

