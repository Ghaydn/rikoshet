extends Resource

class_name CellDesc

export(Vector2) var xy
export(bool) var is_flag
export(bool) var is_doubled
export(bool) var is_reversed
export(bool) var rotation

func desc(dxy: Vector2, dis_flag: bool, dis_doubled: bool, dis_reversed: bool, drotation: int):
	xy = dxy
	is_flag = dis_flag
	is_doubled = dis_doubled
	is_reversed = dis_reversed
	rotation = drotation

func tostring() -> String:
	return "x=" + String(xy.x) + \
	", y=" + String(xy.y) + \
	", is_flag=" + String(is_flag) + \
	", is_doubled=" + String(is_doubled) + \
	", is_reversed=" + String(is_reversed) + \
	", rotation=" + String(rotation)
