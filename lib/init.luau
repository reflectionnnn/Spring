--!strict

-- Constants
local DEFAULT_MASS = 5
local DEFAULT_FORCE = 50
local DEFAULT_DAMPING = 4
local DEFAULT_SPEED = 4
local DEFAULT_ITERATIONS = 8

export type State = {
	Position: Vector3,
	Target: Vector3,
	Velocity: Vector3,

	Mass: number,
	Force: number,
	Damping: number,
	Speed: number,
	Iterations: number,
}

export type Spring = {
	Update: (deltaTime: number) -> Vector3,
	ApplyImpulse: (force: Vector3) -> (),

	SetState: (state: { [any]: any }) -> (),
	GetState: () -> State,
}

-- Cached
local math_min = math.min

local function CreateSpring(
	input_mass: number?,
	input_force: number?,
	input_damping: number?,
	input_speed: number?,
	input_iteration: number?
): Spring
	local self_mass = input_mass or DEFAULT_MASS
	local self_force = input_force or DEFAULT_FORCE
	local self_damping = input_damping or DEFAULT_DAMPING
	local self_speed = input_speed or DEFAULT_SPEED
	local self_iterations = input_iteration or DEFAULT_ITERATIONS

	local self_position = Vector3.zero
	local self_target = Vector3.zero
	local self_velocity = Vector3.zero

	local function update(deltaTime: number): Vector3
		local scaledDeltaTime = (math_min(deltaTime, 1) * self_speed) / self_iterations

		for _ = 1, self_iterations do
			local iterationForce = self_target - self_position
			local acceleration = (iterationForce * self_force) / self_mass

			acceleration -= self_velocity * self_damping

			self_velocity += acceleration * scaledDeltaTime
			self_position += self_velocity * scaledDeltaTime
		end

		return self_position
	end

	local function applyImpulse(impulse: Vector3)
		self_velocity += impulse
	end

	local function setState(state: { [any]: any })
		self_position = state.Position or self_position
		self_target = state.Target or self_target
		self_velocity = state.Velocity or self_velocity

		self_mass = state.Mass or self_mass
		self_force = state.Force or self_force
		self_damping = state.Damping or self_damping
		self_speed = state.Speed or self_speed
		self_iterations = state.Iterations or self_iterations
	end

	local function getState(): State
		local state: State = {
			Position = self_position,
			Target = self_target,
			Velocity = self_velocity,

			Mass = self_mass,
			Force = self_force,
			Damping = self_damping,
			Speed = self_speed,
			Iterations = self_iterations,
		}

		return table.freeze(state) :: State
	end

	local spring: Spring = {
		Update = update,
		ApplyImpulse = applyImpulse,

		SetState = setState,
		GetState = getState,
	}

	return table.freeze(spring) :: Spring
end

return CreateSpring
