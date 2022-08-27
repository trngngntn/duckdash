extends Control


var stat_list = [
	"atk_damage",
	"atk_speed",
	"fire_rate",
	"mv_speed",
	"dash_speed",
	"kinetic",
]


func _ready():
	StatManager.connect("stat_change", self, "_on_stat_change")
	StatManager.connect("stat_calculated", self, "_on_stat_ready")

func _on_stat_ready() -> void:
	for stat in stat_list:
		var label = Label.new()
		label.name = stat
		label.text = stat
		label.uppercase = true
		$LabelCont.add_child(label)
		label = label.duplicate()
		label.align = Label.ALIGN_RIGHT
		label.text = str(StatManager.current_stat.get(stat))
		$ValueCont.add_child(label)

func _on_stat_change(stat_name: String, _change, new_value) -> void:
	if $ValueCont.has_node(stat_name):
		var label = $ValueCont.get_node(stat_name)
		if label:
			label.text = str(new_value)
