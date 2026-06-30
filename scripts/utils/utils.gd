class_name Utils

static func to_dict(obj: Object) -> Dictionary:
	var data: Dictionary = {}
	# 获取传入对象的所有属性列表
	for property: Dictionary in obj.get_property_list():
		# 过滤出脚本变量 (排除系统属性)
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			data[property.name] = obj.get(property.name)
	return data


static func convert_object(source_object: Object, target_class: Script) -> Object:
	# 1. 动态创建目标类的实例
	var target_object: Object = target_class.new()

	# 2. 获取源数据的字典
	var source_script: Script = source_object.get_script()
	var data_dict: Dictionary = Utils.to_dict(source_object)

	# 3. 遍历并赋值
	for key: String in data_dict:
		# 检查目标对象是否有这个属性
		if key in target_object:
			target_object.set(key, data_dict[key])

	return target_object

# 同类实例属性拷贝方法
static func copy_properties(source: Object, target: Object) -> Object:
	# 1. 简单校验：确保两者都是对象且属于同一个类
	if not source or not target:
		push_error("Utils.copy_properties: Source or Target is null.")
		return

	if source.get_class() != target.get_class():
		push_warning("Utils.copy_properties: Class mismatch. Source: %s, Target: %s" % [source.get_class(), target.get_class()])

	# 2. 获取源对象的所有属性列表
	for property in source.get_property_list():
		# 3. 过滤：只处理脚本定义的变量 (排除 name, transform 等系统属性)
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var prop_name = property.name
			# 4. 获取值并设置给目标对象
			var value = source.get(prop_name)
			if value is Array:
				push_warning("Array shadow copy")
			elif value is Resource:
				push_warning("Resource shadow copy")
			target.set(prop_name, value)

	return target

static func save_resource(resource: Resource, save_path: String) -> void:
	var dir: String = save_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var err := ResourceSaver.save(resource, save_path)
	if err != OK:
		push_error("Utils.save_resource: Failed to save resource to '%s'. Error: %s" % [save_path, error_string(err)])

## 并发执行一组 Callable，监听对应的 Signal，全部信号触发后返回
## [br]callables 与 signals 长度必须一致，每个 callable 与同下标的 signal 对应
## [br]返回 [Array] — 与输入同序，每个元素为对应 signal 的参数数组
static func run_and_wait_all(callables: Array[Callable]) -> void:
	var tasks: Array = []
	for c in callables:
		tasks.append(c.call()) # 假设 callable 返回的是协程/信号

	# 如果 callables 返回的是需要 await 的对象，可以并发等待
	for task in tasks:
		if task is Signal or task is Callable:
			await task
