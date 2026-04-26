# Spring

A physics-based 3D spring simulation module for Luau. This module uses numerical integration with sub-stepping to provide stable and smooth motion, making it ideal for camera systems, procedural animations, and UI effects.

[View Documentation](https://reflectionnnn.github.io/Spring/)


## Features

- **3D Vector Support**: Built natively for `Vector3` operations.
- **Sub-stepping**: Maintain stability even at low or variable frame rates.
- **Customizable Physics**: Fine-tune mass, force (stiffness), damping (friction), and speed.
- **Type Safety**: Fully typed with Luau for excellent Luau LSP support.
- **Lightweight**: Zero dependencies, simple closure-based API.

## Installation

### Manual
- Go to Releases on github page.
- Download .rbxm of latest release.

### Wally
- Visit https://wally.run/package/reflectionnnn/spring
- Copy install command of latest version.
- Add that to your `wally.toml`.
```toml
Spring = "reflectionnnn/spring@VERSION"
```

## Usage Example

```lua
-- Require spring
local Spring = require(path.to.Spring)

-- Create a new spring object (Mass, Force, Damping, Speed, Iterations)
-- Or use default parameters "local cameraSpring = Spring()"
local cameraSpring = Spring(4, 100, 4, 4, 16)

-- Cache state to avoid unnecessary GC pressure
local cachedState: Spring.PartialState = {
  Target = Vector3.zero
}

-- Update loop (e.g., RunService.RenderStepped)
game:GetService("RunService").PreSimulation:Connect(function(deltaTime: number)
    -- Update cached state
    cachedState.Target = workspace.CurrentCamera.CFrame.Position + Vector3.new(0, 10, 0)

    -- Set the destination
    cameraSpring.SetState(cachedState)

    -- Advance the simulation and get the new Position
    local newPosition = cameraSpring.Update(deltaTime)
    
    -- Apply to an object
    somePart.Position = newPosition
end)

-- Apply an immediate kick (recoil/explosion)
cameraSpring.ApplyImpulse(Vector3.new(0, 10, 0))

-- Adjust stiffness or damping on the fly
cameraSpring.SetState({
    Force = 60,
    Damping = 2
})

-- Get snapshot of current physical state
local cameraState = cameraSpring.GetState()
print(cameraState.Velocity)
```
