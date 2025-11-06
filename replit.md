# Keaby - Honeycomb Fishing Script for Roblox

## Project Overview
Keaby adalah GUI bertema sarang lebah untuk Roblox fishing automation script dengan desain yang indah dan responsive untuk semua platform (Android, iOS, PC).

## Recent Changes
- **2025-11-06**: Initial project creation
  - Created honeycomb-themed GUI with bee icons and honey gradient colors
  - Implemented draggable, resizable, and minimizable window
  - Added 2 fishing features: Instant Fishing and Instant 2x Speed
  - Integrated GitHub repository loading for function modules
  - Fixed critical bug: Real-time slider updates now properly apply to active modules
  - All controls support both mouse (PC) and touch (Android/iOS) input

## User Preferences
- Target Platform: Roblox (Android, iOS, PC)
- Script will be executed in Roblox executor
- Uses GitHub repository for hosting: https://github.com/Habibihidayat42/keaby

## Project Architecture

### Main Components
1. **KeabyGUI.lua** - Main GUI file dengan semua visual dan controls
   - Honeycomb/bee themed design
   - Draggable window (from header)
   - Minimize to bee icon
   - Resizable from bottom-right corner
   - 2 feature toggles with expandable slider sections
   - Loads function modules from GitHub

2. **FungsiKeaby/InstantFishing.lua** - Instant Fishing logic (no GUI)
   - 3 configurable delays: Hook, Fishing, Cancel
   - Callbacks for status changes and fish caught events
   - Clean module API with Start(), Stop(), SetSettings()

3. **FungsiKeaby/Instant2Xspeed.lua** - Instant 2x Speed logic (no GUI)
   - 2 configurable delays: Fishing, Cancel
   - Callbacks for status changes and fish caught events
   - Clean module API with Start(), Stop(), SetSettings()

### Key Features
- **Real-time Settings**: Slider adjustments immediately update active modules
- **Cross-platform Input**: Mouse and touch support for all interactive elements
- **GitHub Integration**: Functions loaded dynamically from repository
- **Modular Design**: GUI separated from game logic for maintainability

## How to Use
Load script in Roblox executor:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Habibihidayat42/keaby/main/KeabyGUI.lua"))()
```

## File Structure
```
keaby/
├── KeabyGUI.lua              # Main GUI (execute this)
├── FungsiKeaby/
│   ├── InstantFishing.lua    # Fishing logic module
│   └── Instant2Xspeed.lua    # Speed logic module
├── README.md                 # User documentation
└── replit.md                 # Project documentation
```

## Technical Notes
- This is a Roblox Lua script project, not a web application
- Scripts are designed to run inside Roblox game using an executor
- Requires HttpService enabled to load modules from GitHub
- GUI uses Roblox native UI elements (Frame, TextButton, etc.)
- Touch events handle mobile devices (Android/iOS)
- Mouse events handle desktop (PC)
