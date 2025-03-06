
Wheels = {}

local majorNames = { "Open", "Uncover", "Enlarge", "Flow", "Calm", "Rage", "Yearn", "Discover", "Heal", "Endure", "Luck", "Fade" }
local minorNames = { "Alarm", "Identify", "Stop", "Darken", "Frighten", "Store", "Light", "Strengthen", "Steal", "Learn", "Weaken", "Break" }

local majorWheel = { Open = Open, Uncover = Uncover, Enlarge = Enlarge, Flow = Flow, Calm = Calm, Rage = Rage, Yearn = Yearn, Discover = Discover, Heal = Heal, Endure = Endure, Luck = Luck, Fade = Fade, }
local minorWheel = { Alarm = Alarm, Identify = Identify, Stop = Stop, Darken = Darken, Frighten = Frighten, Store = Store, Light = Light, Strengthen = Strengthen, Steal = Steal, Learn = Learn, Weaken = Weaken, Break = Break, }

function CreateWheels(major, minor)
	Wheels.major = major
	Wheels.minor = minor
	return Wheels
end

function Wheels:GetMajor(n, o)
	local offset = o or 0
	local index = self.major + n + offset
	if index > 12 then index = (index % 12) + 1 end
	return majorNames[index], majorWheel[majorNames[index]]
end

function Wheels:GetMinor(n, o)
	local offset = o or 0
	local index = self.minor + n + offset
	if index > 12 then index = (index % 12) + 1 end
	return minorNames[index], minorWheel[minorNames[index]]
end

function Wheels:Twist(o)
	Wheels.major = Wheels.major + o
	Wheels.minor = Wheels.minor + o
end

return Wheels