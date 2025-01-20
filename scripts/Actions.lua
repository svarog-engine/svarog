
Actions.Default = {
	Left	= { Input.Press("Key: Left") },
	Right	= { Input.Press("Key: Right") },
	Up		= { Input.Press("Key: Up") },
	Down	= { Input.Press("Key: Down") },
	Menu	= { Input.Release("Key: Escape") },
	Exit	= { Input.Hold("Key: F10", 1000) }
}

Actions.Menu = {
	Back = { Input.Release("Key: Escape") }
}

Input.Push("Default")
