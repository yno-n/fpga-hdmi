# FPGA HDMI / TF Card Project

FPGA project for the Anlogic EG4S20BG256, including TF/SD card access,
SDRAM buffering, HDMI output, video processing, OSD, audio, and key control.

## Project Layout

- `sources/`: RTL modules, memory initialization data, Python generators,
  and module-level testbenches.
- `td6.2.2prj/EG4_SD_HDMI.al`: Anlogic TD project entry point.
- `td6.2.2prj/constraint/`: pin assignments and timing constraints.
- `td6.2.2prj/al_ip/`: generated IP wrappers, RTL, and configuration files.

## Opening the Project

1. Install Anlogic TD with EG4 device support. The project records TD
   version `6.2.190657` (6.2.2).
2. Open `td6.2.2prj/EG4_SD_HDMI.al` in TD. If TD asks for the project
   location, select the local `td6.2.2prj` directory.
3. Confirm device `EG4S20BG256` and top module `EG4_SD_HDMI_SUBSYSTOP`.
4. Check the pin constraints against your board before synthesis and
   implementation.

The current RTL selects `640x480@60`. Changing the HDMI timing parameter
also requires matching pixel and serializer clocks; see the comments in
`sources/sd_ctrl/EG4_SD_HDMI_SUBSYSTOP.v`.

## Publication Scope

This repository is a snapshot of the current local project, not its old
Git history. Build output, logs, caches, local debugger state, backup files,
and the outer document, image, and music folders are not included.
TF/SD card media must be prepared separately.

This publication does not establish a new successful build or hardware
test. Use the supplied project and the appropriate vendor tools to verify
it for your target board.

## Third-Party Files

Anlogic-generated IP and other third-party files retain their existing
copyright notices and applicable terms. No additional license is granted
by this repository.
