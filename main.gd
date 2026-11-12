extends Control
## ManU Manager — how long will you last? The whole UI is built in code.

const Data = preload("res://events.gd")
const Face = preload("res://face.gd")

const STATS := ["fans", "board", "squad", "press"]
const STAT_COLORS := {
	"fans": Color("ffd21f"), "board": Color("6ee07a"),
	"squad": Color("6cc8ff"), "press": Color("ff8fd0"),
}
const SAVE_PATH := "user://manu_manager.cfg"

var stats := {}
var week := 0
var days := 0
var best := 0
var deck: Array = []
var current := {}
var state := "title"

var bars := {}
var deltas := {}
var header: Label
var sub: Label
var face: Control
var who: Label
var body: Label
var btn_a: Button
var btn_b: Button
var root_box: VBoxContainer


func _ready() -> void:
	_load_best()
	_build_ui()
	_show_title()


# ---------------------------------------------------------------- UI

func _label(text: String, size: int, color := Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


func _box(color: Color, radius := 24, border := Color(0, 0, 0, 0)) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.set_content_margin_all(22)
	if border.a > 0.0:
		s.border_color = border
		s.set_border_width_all(5)
		s.border_width_bottom = 11
	return s


func _button(color: Color) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, 118)
	b.clip_text = true
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 28)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(c, Color("1a1010"))
	b.add_theme_stylebox_override("normal", _box(color, 22, Color("1a1010")))
	b.add_theme_stylebox_override("hover", _box(color.lightened(0.15), 22, Color("1a1010")))
	var p := _box(color.darkened(0.15), 22, Color("1a1010"))
	p.border_width_bottom = 5
	b.add_theme_stylebox_override("pressed", p)
	return b


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color("5a0808")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	margin.add_theme_constant_override("margin_top", 56)
	margin.add_theme_constant_override("margin_bottom", 36)
	add_child(margin)

	root_box = VBoxContainer.new()
	root_box.add_theme_constant_override("separation", 14)
	margin.add_child(root_box)

	header = _label("", 50, Color("ffd21f"))
	root_box.add_child(header)
	sub = _label("", 26, Color(1, 1, 1, 0.8))
	root_box.add_child(sub)

	# Stat bars
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	root_box.add_child(row)
	for s in STATS:
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(col)
		col.add_child(_label(s.to_upper(), 22, STAT_COLORS[s]))
		var bar := ProgressBar.new()
		bar.custom_minimum_size = Vector2(0, 26)
		bar.show_percentage = false
		bar.add_theme_stylebox_override("background", _box(Color(0, 0, 0, 0.45), 13))
		bar.add_theme_stylebox_override("fill", _box(STAT_COLORS[s], 13))
		col.add_child(bar)
		bars[s] = bar
		var d := _label("", 24)
		d.custom_minimum_size = Vector2(0, 30)
		col.add_child(d)
		deltas[s] = d

	face = Face.new()
	face.custom_minimum_size = Vector2(0, 250)
	face.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_box.add_child(face)

	# Event card
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _box(Color("fff4dc"), 28, Color("1a1010")))
	card.custom_minimum_size = Vector2(0, 330)
	root_box.add_child(card)
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 10)
	cv.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(cv)
	who = _label("", 25, Color("b01515"))
	cv.add_child(who)
	body = _label("", 30, Color("1a1010"))
	cv.add_child(body)

	btn_a = _button(Color("ffd21f"))
	btn_a.pressed.connect(_on_choice.bind("a"))
	root_box.add_child(btn_a)
	btn_b = _button(Color("ffffff"))
	btn_b.pressed.connect(_on_choice.bind("b"))
	root_box.add_child(btn_b)


func _refresh() -> void:
	var total := 0.0
	var lowest := 100.0
	for s in STATS:
		bars[s].value = stats[s]
		total += stats[s]
		lowest = minf(lowest, stats[s])
	face.mood = clampf((total / 4.0 + lowest) / 200.0 + 0.15, 0.0, 1.0)
	face.baldness = clampf(week / 22.0, 0.0, 1.0)
	if state != "title" and state != "sacked":
		header.text = "WEEK %d" % week
		sub.text = "Day %d in the job  ·  Record: %d days" % [days, best]


func _flash(s: String, amount: int) -> void:
	if amount == 0:
		return
	var l: Label = deltas[s]
	l.text = "%+d" % amount
	l.add_theme_color_override("font_color", Color("7dff8a") if amount > 0 else Color("ff6b5e"))
	l.modulate.a = 1.0
	create_tween().tween_property(l, "modulate:a", 0.0, 1.8).set_delay(0.6)


func _shake() -> void:
	face.shock = 1.0
	var tw := create_tween()
	for i in 6:
		tw.tween_property(root_box, "position:x", randf_range(-14, 14), 0.04)
	tw.tween_property(root_box, "position:x", 0.0, 0.04)


# ---------------------------------------------------------------- Game flow

func _show_title() -> void:
	state = "title"
	for s in STATS:
		stats[s] = 50
	week = 0
	_refresh()
	header.text = "ManU MANAGER"
	sub.text = "The Impossible Job  ·  Record: %d days" % best
	who.text = "CONGRATULATIONS (?)"
	body.text = "You are the new ManU manager. Keep the FANS, BOARD, SQUAD and PRESS happy.\n\nNot too happy, though. That also ends badly.\n\nHow long will you last?"
	btn_a.text = "SIGN THE CONTRACT"
	btn_b.visible = false


func _start() -> void:
	for s in STATS:
		stats[s] = 50
	week = 0
	days = 0
	deck.clear()
	_next_event()


func _next_event() -> void:
	state = "choose"
	week += 1
	days += randi_range(5, 9)
	if deck.is_empty():
		deck = range(Data.EVENTS.size())
		deck.shuffle()
	current = Data.EVENTS[deck.pop_back()]
	who.text = current.who
	body.text = current.text
	btn_a.text = current.a.label
	btn_b.text = current.b.label
	btn_b.visible = true
	_refresh()


func _apply(fx: Dictionary) -> void:
	# The job gets harder the longer you cling on.
	var pressure := 1.0 + week * 0.035
	var hurt := false
	for s in fx:
		var v: float = fx[s]
		if v < 0:
			v *= pressure
			hurt = true
		var amount := int(round(v))
		stats[s] = clampi(stats[s] + amount, 0, 100)
		_flash(s, amount)
	if hurt:
		_shake()


func _play_match() -> String:
	var opp: String = Data.OPPONENTS.pick_random()
	var roll := randf()
	var win: float = 0.12 + stats.squad / 170.0
	if roll < win:
		_apply({"fans": 4, "board": 2})
		return "MATCHDAY: Won %d-%d v %s. %s" % [randi_range(1, 4) + 1, randi_range(0, 1), opp, Data.WIN_LINES.pick_random()]
	elif roll < win + 0.22:
		var g := randi_range(0, 3)
		_apply({"fans": -2})
		return "MATCHDAY: Drew %d-%d v %s. %s" % [g, g, opp, Data.DRAW_LINES.pick_random()]
	_apply({"fans": -5, "press": -4, "board": -2})
	return "MATCHDAY: Lost %d-%d v %s. %s" % [randi_range(0, 1), randi_range(2, 7), opp, Data.LOSS_LINES.pick_random()]


func _sack_reason() -> String:
	for s in STATS:
		if stats[s] <= 0:
			return Data.SACK_LOW[s]
	for s in STATS:
		if stats[s] >= 100:
			return Data.SACK_HIGH[s]
	return ""


func _on_choice(which: String) -> void:
	match state:
		"title", "sacked":
			_start()
		"result":
			var reason := _sack_reason()
			if reason != "":
				_sacked(reason)
			else:
				_next_event()
		"choose":
			var pick: Dictionary = current[which]
			_apply(pick.fx)
			var text: String = pick.out
			if _sack_reason() == "":
				text += "\n\n" + _play_match()
			state = "result"
			who.text = "WHAT HAPPENED NEXT"
			body.text = text
			btn_a.text = "NEXT WEEK  >>" if _sack_reason() == "" else "UH OH…"
			btn_b.visible = false
			_refresh()


func _sacked(reason: String) -> void:
	state = "sacked"
	var rank := ""
	for r in Data.RANKS:
		if days >= r[0]:
			rank = r[1]
	var record := days > best
	if record:
		best = days
		_save_best()
	header.text = "SACKED!"
	sub.text = "You lasted %d days (%d weeks)" % [days, week]
	who.text = "NEW RECORD!" if record else "OFFICIAL CLUB STATEMENT"
	body.text = "%s\n\n%s" % [reason, rank]
	btn_a.text = "GET REHIRED (nobody else wants it)"
	btn_b.visible = false
	face.mood = 0.0
	_shake()


# ---------------------------------------------------------------- Save

func _load_best() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		best = cfg.get_value("game", "best", 0)


func _save_best() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "best", best)
	cfg.save(SAVE_PATH)
