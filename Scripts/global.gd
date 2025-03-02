extends Node

# the tip of the claw 
var tip: Area3D

# if the claw is holding a pinched car part
var is_pinching_part: bool

# the root node of current scene (level)
var level_root: Node3D

enum TrashTypes {METAL, GLASS, INTERIOR, ENGINE, BATTERY, AXLE, TIRE}
