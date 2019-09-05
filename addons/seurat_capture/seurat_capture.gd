# Seurat Capture Plugin
tool
extends EditorPlugin

const SeuratCaptureBox = preload("res://addons/seurat_capture/capture_gizmo.gd")

var capture_box = SeuratCaptureBox.new();

func _enter_tree():
	add_custom_type("SeuratCaptureBox", "Spatial", SeuratCaptureBox.CaptureSpatial, preload("spatial_icon.png"))
	add_spatial_gizmo_plugin(capture_box);
	pass


func _exit_tree():
	remove_spatial_gizmo_plugin(capture_box);
	remove_custom_type("SeuratCaptureBox");
	pass;

