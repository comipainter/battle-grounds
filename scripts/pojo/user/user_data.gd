extends Resource
class_name UserData

@export var userInfo: UserInfo = UserInfo.new()
func get_user_info() -> UserInfo:
	return userInfo
func set_user_info(_info: UserInfo) -> void:
	userInfo = _info
