# GODify
A GUI wrapper around [iso2god-rs](https://github.com/iliazeus/iso2god-rs). For converting your legally acquired ISOs to Games-On-Demand format. 

This was created for a friend, as we were both discovering the Xbox 360 homebrew scene and ran into a problem that had a need.
GODify was created to satisfy this need in the most niche of niche corners. This is for my fellow Mac users who can appreciate a nice OS with a great terminal.

## Architecture
This project is small and built in Swift. The application embeds a pre-built versions of iso2god-rs for arm64 and x86_64. The application is to be built as a universal binary for both architectures, at compile time the appropriate iso2god binary is selected.

Everything starts at `GODifyApp`, which simply declares a single window rendering the standard SwiftUI `ContentView`. A custom app delegate is employed to handle cases where the window is closing or application is quitting while a job is running.

The ContentView consists of a few key portions:
* ISO list - This is the list of ISOs that you want to convert to Games-On-Demand format. These will be processed one at a time in the order they are given. 
* Progress Bar - This progress bar reflects the evaluated logging output of iso2god-rs to determine how far into the part file writing we are. 
* Logging view - A scrollable text view containing the logging output of the iso2god-rs tool.
* Output directory selection - A set of controls allowing you to change the output directory of the iso2god-rs tool. There's also a button to open the folder in Finder.
* Primary controls - The primary controls sit at the bottom of the application. These controls allow you to "Add ISO", "Clear" the list, and "Start" the job.

A set of helper classes were also added for the application:
* `ISOItem` - Represents a single ISO in the primary list.
* `ISOProcessor` - Handles processing the ISOs in the list through the iso2god-rs tool.
* `SharedAppState` - Shared state for `isRunning` or `isTerminating`
* `WindowAdapter` - Exposes `NSWindow` commands so we can set the red dot in the main window when we're running.

## Usage
Usage of the tool is as follows:
1. Download, install, and open the tool.
2. Click the "Add ISO(s)" button, a file picker will appear. Select as many **legally acquired** ISOs as you'd like.
3. [Optional] If you'd like to change the output directory of the GODify tool, click the "Change" button next to the output path to select an output directory.
    a. NOTE: This directory will **not** be remembered between sessions.
4. Click "Go" to start the job 
5. When the job is complete, you may copy the files to your Xbox 360's storage medium via FTP or USB.

## Attribution
[iso2god-rs](https://github.com/iliazeus/iso2god-rs) is a tool developed by **iliazeus**. This tool is distributed under the **MIT License**, the same as this tool. 