extends Resource
class_name UserInfo

@export var id: String = UUID.v4()
func set_id(_id: String) -> void:
	id = _id
func get_id() -> String:
	return id

@export var description: String = "新建存档"
func get_description() -> String:
	return description
