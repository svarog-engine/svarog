﻿-- Define your input actions here

Actions.Default = {
	Wait	= { Input.Press("Key: Space") },
	Left	= { Input.Press("Key: Left") },
	Right	= { Input.Press("Key: Right") },
	Up		= { Input.Press("Key: Up") },
	Down	= { Input.Press("Key: Down") },
	Exit	= { Input.Hold("Key: F10", 1000) },
	Reload  = { Input.Press("Key: F5") },

	ZoomIn  = { Input.Press("Key: PageUp") },
	ZoomOut = { Input.Press("Key: PageDown") },
	Inventory = { Input.Press("Key: I")},

	DebugDistances = { Input.Press("Key: F2") },
	DebugPrintDistances = { Input.Press("Key: F3") },
}

Actions.Inventory = {
	Exit = { Input.Press("Key: Escape") },
	SelectNext = {Input.Press("Key: Down") },
	SelectPrevious = {Input.Press("Key: Up") },
}

Input.Push("Default")
