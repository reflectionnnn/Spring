--!strict

local ITERATIONS = 8
local DEFAULT_MASS = 5
local DEFAULT_FORCE = 50
local DEFAULT_DAMPING = 4
local DEFAULT_SPEED = 4

local Spring = {}
Spring.__index = Spring

export type Spring = typeof(setmetatable(
	{} :: {
		Mass: number,
		Force: number,
		Damping: number,
		Speed: number,

		_target: Vector3,
		_position: Vector3,
		_velocity: Vector3
	},
	Spring
))

function Spring.new(mass: number?, force: number?, damping: number?, speed: number?): Spring
	local self = setmetatable({}, Spring) :: Spring

	self.Mass = mass or DEFAULT_MASS
	self.Force = force or DEFAULT_FORCE
	self.Damping = damping or DEFAULT_DAMPING
	self.Speed = speed or DEFAULT_SPEED

	self._target = Vector3.zero
	self._position = Vector3.zero
	self._velocity = Vector3.zero

	return self
end

function Spring.ApplyImpulse(self: Spring, force: Vector3): ()
	self._velocity += force
end

function Spring.Update(self: Spring, deltaTime: number): Vector3
	local scaledDeltaTime = (math.min(deltaTime, 1) * self.Speed) / ITERATIONS

	for _ = 1, ITERATIONS do
		local iterationForce = self._target - self._position
		local acceleration = (iterationForce * self.Force) / self.Mass

		acceleration -= self._velocity * self.Damping

		self._velocity += acceleration * scaledDeltaTime
		self._position += self._velocity * scaledDeltaTime
	end

	return self._position
end

return Spring