This workspace includes helpers to run the emulator with a selected `.bas` file.

Quick usage
- Run current file with Code Runner (preferred):
  - Install the **Code Runner** extension.
  - Open a `.bas` file and click the Code Runner play button. It runs:
    `cargo run --release "C:/path/to/your/file.bas"`.

- Run current file via VS Code Task (fallback):
  - Open the file you want to run (it must be the active editor).
  - Press `Ctrl+Shift+P` → `Tasks: Run Task` → choose `Run current file with cargo (release)`.
  - Or press the workspace shortcut `Ctrl+Alt+R` (configured in `keybindings.json`).

Debug / Run view
- A debug configuration template is included (`.vscode/launch.json`) named:
  - `Run release binary with current file (LLDB)`
- This runs the release binary at `${workspaceFolder}/target/release/cody_emulator` with the active file path as the single argument.
- Notes:
  - You should first install the **CodeLLDB** extension (or another Rust debugger) to use the Run/Debug button.
  - The `program` path may need editing to match the actual release binary name in your environment (for Windows it may be `cody_emulator.exe` or similar).
  - The launch configuration runs the `Build (cargo release)` task before launching.

Tips
- If the Code Runner play button still shows "language not supported":
  - Ensure the Code Runner extension is installed and reload the window.
  - The workspace `settings.json` maps `.bas` to `cargo run --release "$fullFileName"` if Code Runner is present.
- If you need a different shortcut, edit `.vscode/keybindings.json` and change the `key` binding.
