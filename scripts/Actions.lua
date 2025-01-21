
Actions.Default = {
	Left	= { Input.Press("Key: Left") },
	Right	= { Input.Press("Key: Right") },
	Up		= { Input.Press("Key: Up") },
	Down	= { Input.Press("Key: Down") },
	Debug	= { Input.Release("Key: Escape") },
	Exit	= { Input.Hold("Key: F10", 1000) }
}

Actions.Debug = {
	Reload  = { Input.Press("Key: F5") },
	Back = { Input.Release("Key: Escape") }
}

Input.Push("Default")
