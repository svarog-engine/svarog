-- Define your input actions here

Actions.Default = {
	Left	= { Input.Press("Key: Left") },
	Right	= { Input.Press("Key: Right") },
	Up		= { Input.Press("Key: Up") },
	Down	= { Input.Press("Key: Down") },
	Exit	= { Input.Hold("Key: F10", 1000) },
	ZoomIn  = { Input.Press("Key: PageUp") },
	ZoomOut = { Input.Press("Key: PageDown") },
	Reload  = { Input.Press("Key: F5") },
}

Input.Push("Default")