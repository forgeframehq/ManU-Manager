# ManU Manager

**Play in a browser:** open `index.html` (single file, built for phone screens). It adds touch mini-games on top of the desk events: a formation board that 'auto-corrects' you to 2 at the back, a transfer market, press conferences, substitutions, VAR and team talks.

Edit `web/template.html` (game) or `events.gd` (desk events), then run `python3 tools/build.py .` to regenerate `index.html`.

The Godot version below has the desk events only.

A goofy portrait-mode Godot 4 game: you are the new ManU manager. How long will you last?

Every week something ridiculous lands on your desk. Pick one of two terrible options and try to keep
the **Fans**, **Board**, **Squad** and **Press** happy. Let any of them hit zero and you're sacked.
Let any of them hit 100 and you're *also* gone (carried off by the fans, promoted to Vibes Ambassador...).
The job gets harder every week, and your manager visibly loses his hair.

## Run it

1. Install [Godot 4.3+](https://godotengine.org/download) (standard build, no .NET needed).
2. Import `project.godot` and press Play. On Android, open the folder in the Godot Android editor.

Viewport is 720x1280 portrait with touch input; exports cleanly to Android, iOS or Web.

## Files

- `main.gd` — game loop and UI (built in code, no scenes to wire up)
- `face.gd` — the procedurally drawn, steadily balding gaffer
- `events.gd` — all the events, match lines and sacking statements. Add your own here.

Everything is parody. All names, people and clubs in the events are invented.
