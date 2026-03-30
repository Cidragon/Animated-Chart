extends Node2D

var curve : Curve2D

@onready var line_2d: Line2D = %Line2D
@onready var _1000: Label = %_1000
@onready var _900: Label = %_900
@onready var _800: Label = %_800

var is_chart_running : bool = false
var start_margin_x : int = 40
var line_width : int = 3
var line_magnitud_y : float = 1.8
var point_distance : int = 6
var start_line_y : int = 150
var end_line_y : int = 600

var chart_data: Array[int] = [
	1000, 983, 995, 987, 971, 956, 940, 930, 916, 907,
	893, 881, 873, 863, 856, 859, 865, 879, 877, 870,
	857, 858, 848, 838, 830, 828, 851, 847, 848, 864,
	854, 866, 881, 894, 890, 903, 899, 909, 898, 903,
	899, 896, 891, 902, 911, 918, 910, 916, 904, 910,
	895, 884, 894, 899, 894, 894, 913, 922, 912, 913,
	910, 906, 917, 919, 925, 915, 910, 912, 931, 934,
	941, 948, 934, 920, 929, 943, 956, 957, 945, 947,
	930, 921, 929, 943, 962, 959, 959, 957, 960, 954,
	963, 980, 984, 994, 1009, 1020, 1035, 1021, 1018, 1009,
	994, 994, 1008, 999, 1005, 1021, 1004, 991, 974, 973,
	959, 976, 992, 1005, 996, 1002, 1003, 1004, 1017, 1017,
	1003, 1017, 1034, 1042, 1055, 1046, 1054, 1067, 1060, 1060,
	1060, 1048, 1052, 1052, 1048, 1048, 1052, 1058, 1047, 1047,
	1028, 1009, 1009, 1005, 1007, 1011, 1012, 1026, 1016, 1016,
	1013, 1026, 1040, 1054, 1037, 1041, 1026, 1026, 1035, 1035,
	1025, 1033, 1038, 1023, 1031, 1045, 1024, 1034, 1029, 1029,
	1021, 1030, 1014, 1003, 1008, 989, 998, 994, 999, 996,
	979, 988, 971, 986
]

var counter : int = 0
var max_data_points : int = 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("run_chart"):
		is_chart_running = true
		
func _process(delta: float) -> void:
	if not is_chart_running:
		return
	
	counter = min(counter + 1, 1000)
	if counter % 3 == 0:
		#print(counter)
		max_data_points = min(chart_data.size(), max_data_points + 1)
		queue_redraw()
		draw_line_2d()
	
func _ready() -> void:
	_1000.position = Vector2(0, start_line_y - _1000.size.x/2)
	_900.position = Vector2(0, start_line_y + line_magnitud_y*100 - _900.size.x/2)
	_800.position = Vector2(0, start_line_y + line_magnitud_y*100*2 - _900.size.x/2)
	
	curve = Curve2D.new()
	for i in range(max_data_points):
		var point := Vector2(i, chart_data[i])
		var adjusted_point := adjust_point_to_chart(point)
		#print(str(chart_data[i]) + " " + str(adjusted_point.y))
		curve.add_point(adjusted_point)
	
	line_2d.points = curve.get_baked_points()
	line_2d.width = line_width
	#line_2d.joint_mode =  Line2D.LineJointMode.LINE_JOINT_ROUND
	#print(line_2d.points)
	

var DRAW_LINE_WIDTH : int = 2
var DASH_LINE_LENGTH : int = 10
var DATA_SEGMENT_LENGTH : int = 10
var label_x : Array[Label] = []
func _draw() -> void:
	#chart lines
	draw_line(Vector2(start_margin_x, end_line_y), Vector2(start_margin_x + 1250, end_line_y), Color.WHITE, DRAW_LINE_WIDTH)
	draw_line(Vector2(start_margin_x,0), Vector2(start_margin_x, end_line_y), Color.WHITE,2)
	#value lines
	draw_dashed_line(Vector2(start_margin_x, start_line_y), Vector2(start_margin_x+1250,start_line_y), Color.WHITE, DRAW_LINE_WIDTH,DASH_LINE_LENGTH)
	draw_dashed_line(Vector2(start_margin_x, start_line_y + (line_magnitud_y*100)), Vector2(start_margin_x+1250,start_line_y + (line_magnitud_y*100)), Color.WHITE, DRAW_LINE_WIDTH,DASH_LINE_LENGTH)
	draw_dashed_line(Vector2(start_margin_x, start_line_y + (line_magnitud_y*100*2)), Vector2(start_margin_x+1250,start_line_y + (line_magnitud_y*100*2)), Color.WHITE, DRAW_LINE_WIDTH,DASH_LINE_LENGTH)
	#print(Vector2(start_margin_x, start_line_y + (line_magnitud_y*100*2)))
	
	while label_x.size() > 0:
		var label = label_x.pop_back()
		label.queue_free()
	
	for i in range(1,max_data_points/DATA_SEGMENT_LENGTH + 1,1):
		var start = Vector2(start_margin_x + point_distance * i * DATA_SEGMENT_LENGTH, end_line_y - 5)
		var end = Vector2(start_margin_x + point_distance * i * DATA_SEGMENT_LENGTH, end_line_y + 5)
		draw_line(start,end,Color.WHITE,DRAW_LINE_WIDTH)
		var new_label := Label.new()
		new_label.text = str(i * DATA_SEGMENT_LENGTH)
		new_label.position = Vector2(start_margin_x + point_distance * i * DATA_SEGMENT_LENGTH,end_line_y + 20)
		new_label.position.x -= new_label.size.x/2
		label_x.append(new_label)
		add_child(new_label)
	
func adjust_point_to_chart(point : Vector2) -> Vector2:
	var flipped_y : int = flip_values_to_opposite(point.y)
	var new_point = Vector2(point.x * point_distance + start_margin_x, flipped_y)
	return new_point

func flip_values_to_opposite(value : int) -> int:
	#1000 as the anchor for starting point
	return (1000 - value) * line_magnitud_y + start_line_y

func draw_line_2d() -> void:
	curve = Curve2D.new()
	for i in range(max_data_points):
		var point := Vector2(i, chart_data[i])
		var adjusted_point := adjust_point_to_chart(point)
		#print(str(chart_data[i]) + " " + str(adjusted_point.y))
		curve.add_point(adjusted_point)
	
		line_2d.points = curve.get_baked_points()
		line_2d.width = line_width
