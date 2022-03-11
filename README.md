# EDID Modification Workspace

Hacking on my laptop's EDID to add missing modes. Leaving breadcrumbs for future EDID hackers.

### Motivation

I would like to switch My Dell XPS 13 9360's QHD+ (3200x1600) display into a lower-resolution KMS mode (1600x900) to save power and eyestrain when computing outside.

## Gameplan

1. Fetch needed tools via `flake.nix`: `nix develop`. You need nix with flakes enabled to use this. It's worth learning if you do a lot of random stuff with software.
2. Read embedded EDID: `edid-decode /sys/class/drm/card0-eDP-1/edid` (adapt for your port).
3. Read the spec ([VESA E-EDID Standard Release A2 (EDID 1.4)](https://glenwing.github.io/docs/VESA-EEDID-A2.pdf)), particularly section "3.10.2 Detailed Timing Descriptor: 18 bytes", and plan to fill an unused 18 byte block with the desired mode.
4. Copy your current EDID: `cp /sys/class/drm/card0-eDP-1/edid mod.edid`.
5. Hex editor: `wxHexEdit mod.edid`
6. Import the included edid.tags to mark regions of the file.
7. Decide which of the 4 18-byte regions to overwrite. For me, the first two were valid modes, and the last were an ASCII string of unknown purpose and a vendor specific value. I chose to overwrite the 3rd region
8. Get your new value.
   1. Generate your own: (TODO: the nix edid-generator package is missing the needed script, so you need to clone the repo first) `cd edid-generator && cvt 1600 900 60 | zsh ./edid-generator/modeline2edid && make`
   2. Download one of these: https://github.com/armbian/firmware/tree/master/edid
   3. Copy the 18 bytes starting at 0x36. This is your DTD. Select the target range and "Fill selection".
9. Check your work with `edid-decode`.
10. Fix the display size values. These can be copied from your existing DTD. See **Table 3.21 - Detailed Timing Definition** (bytes 12-14 for sure, 15 and 16 were zero for me). Check.
11. Fix the checksum byte with the value from `edid-decode`.

## Useful Python math snippets

```python
>>> swapbytes = lambda x: ((x << 8) | (x >> 8)) & 0xFFFF
>>> swapbytes(0xa474)
29860
```
## Random links

- [EDID — The Linux Kernel documentation](https://www.kernel.org/doc/html/latest/admin-guide/edid.html)
- https://wiki.archlinux.org/title/kernel_mode_setting#Forcing_modes_and_EDID
- https://github.com/akatrevorjay/edid-generator
  - [edid-generator: init at unstable-2018-03-15 by flokli · Pull Request #81200 · NixOS/nixpkgs](https://github.com/NixOS/nixpkgs/pull/81200)
- https://github.com/linuxhw/EDID

