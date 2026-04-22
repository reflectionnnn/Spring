--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreateSpring = require(ReplicatedStorage.Spring)

return function()
	describe("Initialization", function()
		it("should initialize with default parameters when no arguments are provided", function()
			local spring = CreateSpring()
			local state = spring.GetState()

			expect(state.Mass).to.equal(5)
			expect(state.Force).to.equal(50)
			expect(state.Damping).to.equal(4)
			expect(state.Speed).to.equal(4)
			expect(state.Iterations).to.equal(8)

			expect(state.Position).to.equal(Vector3.zero)
			expect(state.Target).to.equal(Vector3.zero)
			expect(state.Velocity).to.equal(Vector3.zero)
		end)

		it("should initialize with custom parameters when provided", function()
			local customMass, customForce, customDamp, customSpeed, customIter = 10, 100, 8, 2, 16
			local spring = CreateSpring(customMass, customForce, customDamp, customSpeed, customIter)
			local state = spring.GetState()

			expect(state.Mass).to.equal(customMass)
			expect(state.Force).to.equal(customForce)
			expect(state.Damping).to.equal(customDamp)
			expect(state.Speed).to.equal(customSpeed)
			expect(state.Iterations).to.equal(customIter)
		end)

		it("should return a frozen spring object", function()
			local spring = CreateSpring()

			expect(table.isfrozen(spring)).to.equal(true)

			expect(function()
				(spring :: any).NewMethod = function() end
			end).to.throw()
		end)
	end)

	describe("State Management (GetState / SetState)", function()
		it("GetState should return a frozen state table", function()
			local spring = CreateSpring()
			local state = spring.GetState()

			expect(table.isfrozen(state)).to.equal(true)

			expect(function()
				(state :: any).Mass = 100
			end).to.throw()
		end)

		it("SetState should update Vectors correctly", function()
			local spring = CreateSpring()
			local newPosition = Vector3.new(10, 20, 30)
			local newTarget = Vector3.new(100, 200, 300)
			local newVelocity = Vector3.new(1, 2, 3)

			spring.SetState({
				Position = newPosition,
				Target = newTarget,
				Velocity = newVelocity,
			})

			local state = spring.GetState()
			expect(state.Position).to.equal(newPosition)
			expect(state.Target).to.equal(newTarget)
			expect(state.Velocity).to.equal(newVelocity)
		end)

		it("SetState should update physical properties correctly", function()
			local spring = CreateSpring()

			spring.SetState({
				Mass = 1,
				Force = 2,
				Damping = 3,
				Speed = 4,
				Iterations = 5,
			})

			local state = spring.GetState()
			expect(state.Mass).to.equal(1)
			expect(state.Force).to.equal(2)
			expect(state.Damping).to.equal(3)
			expect(state.Speed).to.equal(4)
			expect(state.Iterations).to.equal(5)
		end)

		it("SetState should ignore nil values and retain previous state", function()
			local spring = CreateSpring(10, 20, 30, 40, 50)
			local initialPosition = Vector3.new(5, 5, 5)
			spring.SetState({ Position = initialPosition })

			local newTarget = Vector3.new(10, 10, 10)
			spring.SetState({ Target = newTarget })

			local state = spring.GetState()
			expect(state.Position).to.equal(initialPosition)
			expect(state.Target).to.equal(newTarget)
			expect(state.Mass).to.equal(10)
		end)
	end)

	describe("Physics & Mechanics", function()
		it("ApplyImpulse should directly modify velocity", function()
			local spring = CreateSpring()
			local impulse = Vector3.new(0, 50, 0)

			spring.ApplyImpulse(impulse)

			local state = spring.GetState()
			expect(state.Velocity).to.equal(impulse)
		end)

		it("ApplyImpulse should accumulate when called multiple times", function()
			local spring = CreateSpring()

			spring.ApplyImpulse(Vector3.new(10, 0, 0))
			spring.ApplyImpulse(Vector3.new(0, 20, 0))
			spring.ApplyImpulse(Vector3.new(-5, 0, 10))

			local state = spring.GetState()
			expect(state.Velocity).to.equal(Vector3.new(5, 20, 10))
		end)

		it("Update should return the new position", function()
			local spring = CreateSpring()
			spring.SetState({ Target = Vector3.new(100, 0, 0) })

			local newPos = spring.Update(0.1)
			local state = spring.GetState()

			expect(newPos).to.equal(state.Position)
		end)

		it("Update should move the position towards the target over time", function()
			local spring = CreateSpring()
			local targetPos = Vector3.new(10, 0, 0)
			spring.SetState({ Target = targetPos })

			local initialDist = (spring.GetState().Position - targetPos).Magnitude
			spring.Update(0.1)
			local newDist = (spring.GetState().Position - targetPos).Magnitude

			expect(newDist < initialDist).to.equal(true)
		end)

		it("Update should cap deltaTime to 1", function()
			local spring1 = CreateSpring()
			local spring2 = CreateSpring()

			local target = Vector3.new(50, 50, 50)
			spring1.SetState({ Target = target })
			spring2.SetState({ Target = target })

			spring1.Update(1)
			spring2.Update(9999)

			local state1 = spring1.GetState()
			local state2 = spring2.GetState()

			expect(state1.Position).to.equal(state2.Position)
			expect(state1.Velocity).to.equal(state2.Velocity)
		end)

		it("Update with 0 deltaTime should not change position", function()
			local spring = CreateSpring()
			spring.SetState({
				Position = Vector3.new(5, 5, 5),
				Target = Vector3.new(100, 100, 100),
			})

			local result = spring.Update(0)
			expect(result).to.equal(Vector3.new(5, 5, 5))
			expect(spring.GetState().Velocity).to.equal(Vector3.zero)
		end)

		it("Update should eventually reach and settle at the target", function()
			local spring = CreateSpring()
			local targetPos = Vector3.new(100, 50, -25)
			spring.SetState({ Target = targetPos })

			for i = 1, 300 do
				spring.Update(1 / 60)
			end

			local finalState = spring.GetState()
			local distance = (finalState.Position - targetPos).Magnitude

			expect(distance < 0.01).to.equal(true)
			expect(finalState.Velocity.Magnitude < 0.01).to.equal(true)
		end)
	end)

	describe("Edge Cases & Safety", function()
		it("Update should not affect state if already resting at target", function()
			local spring = CreateSpring()
			local target = Vector3.new(10, 20, 30)

			spring.SetState({
				Position = target,
				Target = target,
				Velocity = Vector3.zero,
			})

			local newPos = spring.Update(0.1)
			local state = spring.GetState()

			expect(newPos).to.equal(target)
			expect(state.Velocity).to.equal(Vector3.zero)
		end)
	end)

	describe("Mathematical Stability", function()
		it("should remain stable under very high speed/force settings", function()
			local spring = CreateSpring()
			spring.SetState({
				Force = 1000,
				Speed = 20,
				Iterations = 10,
				Target = Vector3.new(1, 1, 1),
			})

			local pos = spring.Update(0.016)
			expect(pos.X == pos.X).to.equal(true)
			expect(pos.Magnitude < 1000).to.equal(true)
		end)
	end)
end
