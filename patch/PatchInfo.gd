var id: String = ""
var name: String = ""
var description: String = ""
var support: VersionSupport = null
var revision: int = 1
var requires = []
var needs_lib: bool = true


class VersionSupport:
	var soft_minimum: Version
	var soft_maximum: Version
	var hard_minimum: HardVersion = null
	var hard_maximum: HardVersion = null
	
	func _init(soft_minimum:String, soft_maximum:String):
		self.soft_minimum = Version.new(soft_minimum)
		self.soft_maximum = Version.new(soft_maximum)
	
	func set_hard_minimum(version:String, reason:String):
		hard_minimum = HardVersion.new(version, reason)
	
	func set_hard_maximum(version:String, reason:String):
		hard_maximum = HardVersion.new(version, reason)


class HardVersion:
	var version: Version
	var reason: String
	
	func _init(version:String, reason:String):
		self.version = Version.new(version)
		self.reason = reason
	
	func _to_string():
		return "%s - Reason: %s" % [version, reason]


class Version:
	var major: int
	var minor: int
	var patch: int
	
	func _init(full:String):
		var tuple = full.split(".")
		major = int(tuple[0])
		minor = int(tuple[1])
		patch = int(tuple[2].split("-")[0])
	
	func is_geq(other:Version) -> bool:  # Greater or Equal
		if major != other.major:
			return major > other.major
		if minor != other.minor:
			return minor > other.minor
		return patch >= other.patch
	
	func is_gtr(other:Version) -> bool:  # Greater
		if major != other.major:
			return major > other.major
		if minor != other.minor:
			return minor > other.minor
		return patch > other.patch
	
	func _to_string():
		return "%d.%d.%d" % [major, minor, patch]


func add_requirement(path:String):
	requires.append(load(path))
