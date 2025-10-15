# Odin Platformer

A 2D platformer game written in [Odin](https://odin-lang.org/) featuring Celeste-style physics and a built-in level editor. This educational project demonstrates game development fundamentals including entity systems, tile-based collision detection, pixel-perfect movement, and real-time level editing.

## Features

- **Celeste-style Physics**: Precise pixel-perfect movement with sub-pixel positioning
- **Tile-based World**: Efficient collision detection using a tilemap system
- **Built-in Level Editor**: Real-time tile editing with mouse controls (Press F2 to toggle)
- **Camera System**: Smooth camera following with zoom controls
- **Virtual Rendering**: Fixed resolution rendering that scales to any window size
- **Asset Management**: Texture loading and proper resource cleanup

## Screenshots

The game features a simple but effective visual style with:
- Player character sprite animation
- Tile-based environment graphics
- Visual editor overlay with collision boxes
- FPS counter and debug information

## Prerequisites

### Odin Language Installation

1. **Download Odin** from the official repository: [https://github.com/odin-lang/Odin](https://github.com/odin-lang/Odin)

2. **Windows Installation**:
   ```powershell
   # Download the latest Windows release
   # Extract to a directory like C:\odin
   # Add C:\odin to your PATH environment variable
   ```

3. **Linux/macOS Installation**:
   ```bash
   git clone https://github.com/odin-lang/Odin
   cd Odin
   make release
   # Add the Odin directory to your PATH
   ```

4. **Verify Installation**:
   ```bash
   odin version
   ```

### Raylib Dependency

This project uses Raylib through Odin's vendor packages. No additional installation is required as Raylib is included with the Odin compiler.

## Building and Running

### Compile the Project

```bash
odin build . -out:game.exe
```

### Run the Game

**Windows**:
```powershell
.\game.exe
```

**Linux/macOS**:
```bash
./game.exe
```

### Development Build (with Debug Info)

```bash
odin build . -out:game.exe -debug
```

## Controls

- **Arrow Keys**: Move left/right
- **Spacebar**: Jump (only when grounded)
- **F2**: Toggle level editor mode
- **Middle Mouse** (Editor): Pan camera
- **Left Mouse** (Editor): Place solid tiles
- **Right Mouse** (Editor): Remove tiles

## Project Structure

```
Odin-Platformer/
├── main.odin          # Entry point and main game loop
├── player.odin        # Player entity logic and input handling
├── physics.odin       # Collision detection and movement systems
├── world.odin         # World management and tilemap rendering
├── editor.odin        # Level editor implementation
├── render.odin        # Rendering constants and configuration
├── utils.odin         # Utility functions and math helpers
├── README.md          # Project documentation
└── assets/            # Game assets directory
```

### File Descriptions

| File | Purpose |
|------|---------|
| `main.odin` | Contains the main game loop, window initialization, rendering pipeline, and core game constants. Manages the game state and coordinates all systems. |
| `player.odin` | Implements player-specific logic including movement controls, jumping mechanics, and ground detection. Handles user input processing. |
| `physics.odin` | Core physics engine with pixel-perfect movement functions (`move_x`, `move_y`), collision detection against tilemaps, and sub-pixel positioning. |
| `world.odin` | World management system including tilemap creation, rendering, entity storage, and resource cleanup. Defines the game world structure. |
| `editor.odin` | Built-in level editor with mouse-based tile placement, camera controls, and visual feedback. Allows real-time level modification. |
| `render.odin` | Rendering configuration constants including virtual screen dimensions, window settings, and target frame rate. |
| `utils.odin` | Mathematical utility functions and helper procedures used throughout the codebase. |

## Code Architecture

### Entity System
The game uses a simple entity-component system where entities contain position, velocity, size, texture, and sub-pixel remainder values for precise movement.

### Physics System
Implements Celeste-style movement with:
- **Sub-pixel positioning**: Uses remainder values to accumulate fractional movement
- **Pixel-perfect collision**: Moves entities one pixel at a time to prevent tunneling
- **Separate axis movement**: X and Y movement are handled independently

### Rendering Pipeline
- **Virtual Screen**: Fixed 320x180 resolution rendered to texture
- **Scaling**: Automatic scaling to fit any window size
- **Camera System**: World-space camera for game objects, screen-space camera for UI

## Code Guidelines and Preferences

Based on the codebase analysis, this project follows these Odin coding conventions:

### Naming Conventions
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `TILE_SIZE`, `MOVE_SPEED`)
- **Procedures**: `snake_case` (e.g., `update_player`, `check_collision`)
- **Variables**: `snake_case` (e.g., `world_space_camera`, `mouse_world`)
- **Types/Structs**: `PascalCase` (e.g., `Entity`, `World`, `TileType`)
- **Enum values**: `.UPPERCASE` (e.g., `.SOLID`, `.EMPTY`)

### Code Organization
- **Package declaration**: All files use `package game`
- **Import grouping**: Core library imports first, then vendor packages
- **Procedure grouping**: Related procedures are grouped together in logical files
- **Clear separation**: Physics, rendering, input, and world logic are in separate files

### Memory Management
- **Explicit cleanup**: `cleanup_world` procedure handles resource deallocation
- **Dynamic arrays**: Used for entities with proper cleanup
- **Texture management**: Textures are loaded once and unloaded on cleanup

### Error Handling
- **Bounds checking**: Array access includes bounds validation
- **Null checks**: Pointer dereferencing includes nil checks where appropriate
- **Resource validation**: Texture loading and window creation are handled safely

### Performance Considerations
- **Efficient collision**: Early exits in collision detection loops
- **Minimal allocations**: Reuse of data structures where possible
- **Fixed timestep**: Consistent frame rate targeting for predictable physics

## Contributing

This is an educational project demonstrating game development concepts in Odin. Contributions are welcome, especially:

- Additional gameplay mechanics
- Visual improvements and effects
- Code optimization and cleanup
- Documentation improvements
- Bug fixes and stability improvements

## License

This project is open source and available for educational purposes. Feel free to use it as a learning resource or starting point for your own Odin game projects.

## Learning Resources

- [Odin Language Documentation](https://odin-lang.org/docs/)
- [Raylib Documentation](https://www.raylib.com/)
- [Game Programming Patterns](https://gameprogrammingpatterns.com/)
- [Celeste Physics Analysis](https://medium.com/@whatwareweb/celeste-and-towerfall-physics-d24bd2ae0fc5)