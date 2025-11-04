# Los Animales Engine (la_engine)

Modular runtime scaffold that coordinates world controllers and delegates shared status checks through `la_core`.

## Usage

1. Copy `config.example.lua` to `config.lua` and adjust as needed.
2. Ensure `la_core` is started before `la_engine` in `server.cfg`.
3. Register controllers from other resources by requiring `la_engine.server.main` and calling `registerController(name, handler)`.
4. Use the `/la_engine_status` command to verify the runtime is active.
