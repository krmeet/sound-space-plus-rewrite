extends Control

func comma_sep(number):
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	
	return res

func get_time_ms(ms:float):
	var s = max(floor(ms / 1000),0)
	var m = floor(s / 60)
	var rs = fmod(s,60)
	return "%d:%02d" % [m,rs]

onready var difficulty_btns:Array = [
	$ButtonDisp/NODIF,
	$ButtonDisp/EASY,
	$ButtonDisp/MEDIUM,
	$ButtonDisp/HARD,
	$ButtonDisp/LOGIC,
	$ButtonDisp/TASUKETE
]

func update(_s=null):
	if !SSP.selected_song: return
	var map:Song = SSP.selected_song
	$EndInfo.visible = true
	$Actions.visible = true
	$Info/M/V/Id/L.text = map.id
	$Info/M/V/Name/L.text = map.name
	$Info/M/V/Mapper/L.text = map.creator
	$Info/D/Difficulty.text = Globals.difficulty_names.get(map.difficulty,"INVALID DIFFICULTY ID")
	$Info/D/Difficulty.modulate = Globals.difficulty_colors.get(map.difficulty,Color("#ffffff"))
	$Info/D/Data.text = "%s - %s notes" % [get_time_ms(map.last_ms),comma_sep(map.note_count)]
	
	var txt = ""
	if SSP.note_hitbox_size == 1.140: txt += "Default hitboxes, "
	else: txt += "Hitboxes: %s, " % SSP.note_hitbox_size
	if SSP.hitwindow_ms == 55: txt += "default hitwindow"
	else: txt += "hitwindow: %s ms" % SSP.hitwindow_ms
	$Hitboxes.text = txt
	
	for i in range(difficulty_btns.size()):
		var n:Panel = difficulty_btns[i]
		n.visible = (map.difficulty == i-1)
		n.get_node("F").visible = SSP.is_favorite(map.id)
		if map.has_cover:
			n.get_node("Name").visible = false
			n.get_node("Cover").visible = true
			n.get_node("Cover").texture = map.cover
		else:
			n.get_node("Cover").visible = false
			n.get_node("Name").visible = true
			n.get_node("Name").text = map.name
	
	if map.warning != "":
		$Info/M/V/Warning.visible = true
		$Info/M/V/Warning/L.text = map.warning
		if map.is_broken:
			$Info/M/V/Warning/L.set("custom_colors/font_color",Color(1,0,0))
#			$Info/M/V/Run/Run.disabled = true
#			$Info/M/V/Buttons/Control/Favorite.disabled = true
#			$Info/M/V/Buttons/Control/PreviewMusic.disabled = true
		else:
			$Info/M/V/Warning/L.set("custom_colors/font_color",Color(1,1,0))
#			$Info/M/V/Run/Run.disabled = false
#			$Info/M/V/Buttons/Control/Favorite.disabled = false
#			$Info/M/V/Buttons/Control/PreviewMusic.disabled = false
	else: $Info/M/V/Warning.visible = false
	$Info/M/V/Run/Run.disabled = false
	$Info/M/V/Buttons/Control/Favorite.disabled = false
	$Info/M/V/Buttons/Control/PreviewMusic.disabled = false
	
	$Actions/Convert.disabled = (
		$Actions/Convert.debounce or
		SSP.selected_song.converted or
		SSP.selected_song.is_broken or
		SSP.selected_song.is_builtin or
		SSP.selected_song.songType == Globals.MAP_SSPM
	)
	if !SSP.selected_song.is_builtin and SSP.selected_song.songType == Globals.MAP_SSPM:
		$Actions/Convert.visible = false
		$Actions/Difficulty.visible = true
	else:
		$Actions/Convert.visible = true
		$Actions/Difficulty.visible = false
	
	# give the containers time to update
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	if $Info.rect_size.y > 245:
		$Actions.rect_position.y = $Info.rect_size.y + 35
		$EndInfo.rect_position.y = $Info.rect_size.y + 35
	else:
		$Actions.rect_position.y = 280
		$EndInfo.rect_position.y = 280

func return_to_song_select():
	get_node("/root/Menu/Sidebar").press(1,false)

func _ready():
	SSP.connect("selected_song_changed",self,"update")
	SSP.connect("mods_changed",self,"update")
	SSP.connect("favorite_songs_changed",self,"update")
	$ButtonDisp/Select.connect("pressed",self,"return_to_song_select")
	if SSP.selected_song: update()
	else:
		$EndInfo.visible = false
		$Actions.visible = false
		$Info/M/V/Run/Run.disabled = true
		$Info/M/V/Buttons/Control/Favorite.disabled = true
		$Info/M/V/Buttons/Control/PreviewMusic.disabled = true