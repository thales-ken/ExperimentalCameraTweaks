# ExpCameraTweaks

I’ve loved the ActionCam feature ever since it was introduced, but one thing has always annoyed me: every time I logged in, I had to type /console ActionCam full in chat again.

That led me to search for an addon that could automatically enable this setting when I entered the game. Unfortunately, the options I found were either abandoned or overloaded with features, and they often took days to be updated after a new patch.

So, I created ExperimentalCameraTweaks! It’s an intentionally simple addon that I can quickly update on day one of a new patch.

## Features

- **Automatic ActionCam Activation** - Optionally enable ActionCam automatically on login
- **Customizable Settings Panel** - Full control through the in-game AddOns menu
- **Adjustable Parameters**:
  - Dynamic Camera Pitch toggle
  - Head Movement Strength (0-5)
  - Head Movement Range (0-20)
  - Over-Shoulder Offset (0-3)
  - Target Focus for Enemies
  - Target Focus for Interactables
- **Enable/Disable Toggle** - Switch between ActionCam and default camera anytime
- **Reset to Defaults** - One-click restoration of default settings
- **No Confirmation Dialogs** - Bypasses the annoying experimental feature warning

## Installation

1. Download the latest release
2. Extract the `ExpCameraTweaks` folder to your WoW AddOns directory:
   - Windows: `World of Warcraft\_retail_\Interface\AddOns\`
   - Mac: `World of Warcraft/_retail_/Interface/AddOns/`
3. Restart WoW or type `/reload` in-game

## Usage

1. Open the Game Menu (ESC)
2. Go to **Options** → **AddOns**
3. Find **"Experimental Camera Tweaks"** in the list
4. Customize your ActionCam settings to your preference

### Settings

- **Enable ActionCam** - Toggle ActionCam on/off
- **Auto-apply on login** - Automatically enable settings when you log in
- **Dynamic Camera Pitch** - Enables dynamic camera movement
- **Head Movement Strength** - Controls how much the camera follows character head movement
- **Head Movement Range** - Controls the range of head movement tracking
- **Over-Shoulder Offset** - Adjusts the camera position to the side of your character
- **Target Focus** - Makes the camera focus on enemies and interactables

## Technical Details

### File Structure

```
ExpCameraTweaks/
├── Core.lua          # Event handling and initialization
├── Database.lua      # SavedVariables management
├── Settings.lua      # Camera CVar application
├── UI.lua           # Settings panel interface
├── ExpCameraTweaks.lua # Stub file for compatibility
└── ExpCameraTweaks.toc # Addon metadata
```

### Compatibility

- **Retail (The War Within)**: ✅ 11.0+
- **Cataclysm Classic**: ✅ 4.4+
- **Wrath Classic**: ✅ 3.4+
- **Classic Era**: ✅ 1.15+

## Version History

**v0.3** (Current)
- Modularized code structure
- Added DisableSettings function for proper ActionCam toggle
- Removed chat notifications
- Better organization across multiple files

**v0.2**
- Added comprehensive settings panel
- SavedVariables support
- Customizable sliders and toggles

**v0.1**
- Initial release
- Basic ActionCam activation
