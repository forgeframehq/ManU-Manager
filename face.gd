extends Control
## The Gaffer. Drawn entirely in code. Ages roughly ten years per fortnight.

var mood := 0.7       # 0 = meltdown, 1 = smug
var baldness := 0.0   # 0 = full head of hair, 1 = cue ball
var shock := 0.0      # set > 0 for a quick wobble
var t := 0.0

const SKIN := Color("f2c9a0")
const RAGE := Color("e2543f")
const INK := Color("1a1010")

func _process(delta: float) -> void:
	t += delta
	shock = maxf(0.0, shock - delta * 1.5)
	queue_redraw()

func _draw() -> void:
	var stress := 1.0 - mood
	var r := minf(size.x, size.y) * 0.34
	var c := size / 2.0 + Vector2(0, -r * 0.12 + sin(t * 2.0) * 6.0)
	var j := stress * 3.0 + shock * 14.0
	c += Vector2(randf_range(-j, j), randf_range(-j, j))

	# Suit + club scarf
	var sh := c + Vector2(0, r * 0.95)
	draw_colored_polygon(PackedVector2Array([
		sh + Vector2(-r * 1.5, r * 1.3), sh + Vector2(-r * 0.9, 0),
		sh + Vector2(r * 0.9, 0), sh + Vector2(r * 1.5, r * 1.3)]), Color("22222c"))
	draw_colored_polygon(PackedVector2Array([
		sh + Vector2(-r * 0.3, 0), sh + Vector2(r * 0.3, 0), sh + Vector2(0, r * 0.6)]), Color.WHITE)
	for i in 6:
		var col := Color("d81e1e") if i % 2 == 0 else Color("ffd21f")
		draw_rect(Rect2(sh + Vector2(-r * 0.75 + i * r * 0.25, -r * 0.12), Vector2(r * 0.25, r * 0.26)), col)
	draw_rect(Rect2(sh + Vector2(r * 0.35, 0), Vector2(r * 0.24, r * 0.8 + sin(t * 3.0) * 6.0)), Color("d81e1e"))

	# Head
	var skin := SKIN.lerp(RAGE, clampf(stress * 1.2 - 0.2, 0.0, 1.0))
	draw_circle(c + Vector2(-r, 0), r * 0.2, skin)
	draw_circle(c + Vector2(r, 0), r * 0.2, skin)
	draw_circle(c, r, skin)

	# Hair: leaves him strand by strand
	var strands := int(round(lerpf(17.0, 0.0, baldness)))
	for i in strands:
		var a := deg_to_rad(-160.0 + 140.0 * (float(i * 7 % 17) / 16.0))
		var base := c + Vector2(cos(a), sin(a)) * r * 0.97
		var wob := sin(t * 3.0 + i) * 0.25 * (0.3 + stress)
		var tip := base + Vector2(cos(a + wob), sin(a + wob)) * r * (0.35 + 0.1 * sin(i * 1.7))
		draw_line(base, tip, Color("4a3020"), 7.0, true)
	if strands == 0:
		draw_arc(c + Vector2(-r * 0.3, -r * 0.55), r * 0.2, PI * 1.1, PI * 1.6, 8, Color(1, 1, 1, 0.7), 5.0, true)

	# Eyes: bulge with stress
	var er := r * (0.2 + 0.1 * stress)
	var ey := c.y - r * 0.15
	for s: float in [-1.0, 1.0]:
		var e := Vector2(c.x + s * r * 0.38, ey)
		if baldness > 0.35:
			draw_arc(e + Vector2(0, er * 0.5), er, 0.2, PI - 0.2, 10, Color(0.3, 0.1, 0.3, 0.45), 5.0, true)
		draw_circle(e, er, Color.WHITE)
		var look := Vector2(sin(t * 1.3 + s), cos(t * 0.9)) * er * 0.3
		look += Vector2(randf_range(-1, 1), randf_range(-1, 1)) * stress * 4.0
		draw_circle(e + look, er * lerpf(0.42, 0.2, stress), INK)
		# Eyebrows: smug when happy, furious/terrified when not
		var tilt := lerpf(-0.25, 0.55, stress) * s
		var bc := e + Vector2(0, -er * 1.45)
		var d := Vector2(cos(tilt), sin(tilt)) * er * 1.1
		draw_line(bc - d, bc + d, INK, 9.0, true)

	# Mouth
	var mc := c + Vector2(0, r * 0.45)
	var mw := r * 0.42
	if mood > 0.58:
		draw_arc(mc + Vector2(0, -mw * 0.5), mw, 0.2 * PI, 0.8 * PI, 16, INK, 8.0, true)
	elif mood > 0.4:
		draw_line(mc + Vector2(-mw * 0.8, sin(t * 6.0) * 3.0), mc + Vector2(mw * 0.8, -sin(t * 6.0) * 3.0), INK, 8.0, true)
	elif mood > 0.2:
		draw_arc(mc + Vector2(0, mw * 0.9), mw, 1.2 * PI, 1.8 * PI, 16, INK, 8.0, true)
	else:
		# Full scream
		draw_circle(mc, mw * (0.55 + 0.1 * sin(t * 14.0)), INK)
		draw_circle(mc + Vector2(0, mw * 0.25), mw * 0.25, Color("c0392b"))

	# Sweat
	var drops := int(stress * 6.0)
	for i in drops:
		var ph := fmod(t * 0.9 + i * 0.37, 1.0)
		var sx := c.x + (r * 0.75 + (i % 3) * 14.0) * (1.0 if i % 2 == 0 else -1.0)
		var p := Vector2(sx, c.y - r * 0.7 + ph * r * 1.3)
		draw_circle(p, 8.0, Color(0.45, 0.8, 1.0, 1.0 - ph))
		draw_colored_polygon(PackedVector2Array([p + Vector2(-7, -3), p + Vector2(7, -3), p + Vector2(0, -18)]), Color(0.45, 0.8, 1.0, 1.0 - ph))
