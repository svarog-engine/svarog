-- Define your input actions here

Actions.Default = {
	Wait	= { Input.Press("Key: Space") },
	Left	= { Input.Press("Key: Left") },
	Right	= { Input.Press("Key: Right") },
	Up		= { Input.Press("Key: Up") },
	Down	= { Input.Press("Key: Down") },
	Exit	= { Input.Hold("Key: F10", 1000) },
	Reload  = { Input.Press("Key: F5") },
	JumpOn  = { Input.Press("Key: LShift")},
	JumpOff = { Input.Release("Key: LShift")},
	ZoomIn  = { Input.Press("Key: PageUp") },
	ZoomOut = { Input.Press("Key: PageDown") },
	Inventory = { Input.Press("Key: I") },
	Tension = { Input.Press("Key: T") },
	Info = { Input.Press("Mouse: Left") },
}

Actions.Inventory = {
	Exit			= { Input.Press("Key: Escape") },
	SelectNext		= {Input.Press("Key: Down") },
	SelectPrevious  = {Input.Press("Key: Up") },
	Drop			= { Input.Press("Key: D") },
	Throw			= { Input.Press("Key: T") },
	Consume			= { Input.Press("Key: C") },
	Cast			= { Input.Press("Key: Z") },
}

Actions.TargetOverlay = {
	Left	= { Input.Press("Key: Left") },
	Right	= { Input.Press("Key: Right") },
	Up		= { Input.Press("Key: Up") },
	Down	= { Input.Press("Key: Down") },
	MouseMove	= { Input.MouseMove("Mouse: Move") },
	MouseCofirm = { Input.Press("Mouse: Left")},
	Confirm	= { Input.Press("Key: Enter") },
	Exit	= { Input.Press("Key: Escape") },
}

LoadScriptIfExists("debug\\DebugActions")

Input.Push("Default")
