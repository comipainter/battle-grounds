class_name PathUtils

static func exist(path: String) -> bool:
	if ResourceLoader.exists(path):
		return true
	else:
		push_error("随从图片资源不存在! 路径: %s" % path)
		return false

static func get_user_info_path(userInfo: UserInfo) -> String:
	return Path.SavePath.Base + userInfo.get_id() + "/" + "user_info.tres"
	
static func get_user_info_dir(userInfo: UserInfo) -> String:
	return Path.SavePath.Base + userInfo.get_id() + "/"
