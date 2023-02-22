extends Node3D
class_name GameObject

var game:GameScene
var manager:ObjectManager

@export var id:String

func _init(id:String):
	self.id = id

func _process(_delta):
	if game == null or manager == null: return
	update(game.sync_manager.current_time)

func update(current_time:float):
	pass