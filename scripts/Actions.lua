-- Define your input actions here

Actions.Default = {
	ScanOn	= { Input.Press("Key: LAlt") },
	ScanOff	= { Input.Release("Key: LAlt") },
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
	ExpandDiary = { Input.Press("Key: Tab") },
}

Actions.Death = {
	Reload = { Input.Hold("Key: Space", 500) }
}

Actions.Inventory = {
	Exit			= { Input.Press("Key: Escape") },
	SelectNext		= {Input.Press("Key: Down") },
	SelectPrevious  = {Input.Press("Key: Up") },
	Drop			= { Input.Press("Key: D") },
	Throw			= { Input.Press("Key: T") },
	ConsumeOrCast	= { Input.Press("Key: C") },
}

Actions.Boon = {
	Take			= { Input.Hold("Key: Space", 1000) },
	Confirm			= { Input.Press("Key: Space") },
}

Actions.Loot = {
	Exit			= { Input.Press("Key: Escape") },
	A				= { Input.Press("Key: A") },
	B				= { Input.Press("Key: B") },
	C				= { Input.Press("Key: C") },
	D				= { Input.Press("Key: D") },
	E				= { Input.Press("Key: E") },
	F				= { Input.Press("Key: F") },
	G				= { Input.Press("Key: G") },
	H				= { Input.Press("Key: H") },
	I				= { Input.Press("Key: I") },
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

Actions.Diary = {
	Exit	= { Input.Press("Key: Tab") },
}

LoadScriptIfExists("debug\\DebugActions")

Input.Push("Default")
