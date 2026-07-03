# panicos-setup

One command turns a bare [PanicOS](https://github.com/djhardrich/PanicOS)
handheld (Anbernic RG35XX Pro class) into a music machine:

- **[norns](https://github.com/djhardrich/norns-panicos)** — the monome
  sound computer: configurable gamepad controls, monome grid + USB MIDI,
  maiden + the [ingenue](https://github.com/seajaysec/ingenue) web editor
  on `:7777`, SuperCollider engines with the aarch64 audio fixes baked in.
- **[m8c](https://github.com/seajaysec/panicos-m8c)** — Dirtywave M8
  headless client (display, controls, M8 audio through the handheld).
- **[usb-audio](https://github.com/seajaysec/panicos-usb-audio)** —
  system-wide USB audio in/out toggles in the Tools menu.
- **[warp_pipe](https://github.com/seajaysec/warp_pipe)** — norns mod
  routing USB audio devices into the norns graph (pre-enabled).

## Before you start

1. Flash PanicOS and boot the device, connect it to Wi-Fi.
2. In ES: **Tools → Install PortMaster** (creates the ports folder).
3. Find the device's IP (ES shows it in the network menu).

## Install

From any computer on the same network (device password: `panicos`):

```sh
ssh root@<device-ip> 'curl -fsSL https://raw.githubusercontent.com/seajaysec/panicos-setup/master/setup.sh | sh'
```

Want the m8c v2.x beta (SDL3, in-app config UI) too?

```sh
ssh root@<device-ip> 'curl -fsSL https://raw.githubusercontent.com/seajaysec/panicos-setup/master/setup.sh | M8C_BETA=1 sh'
```

And the everything button — music machine **plus** the full emulation stack
([panicos-emu](https://github.com/seajaysec/panicos-emu): ROCKNIX RetroArch,
every core, self-updating from the Ports menu):

```sh
ssh root@<device-ip> 'curl -fsSL https://raw.githubusercontent.com/seajaysec/panicos-setup/master/setup.sh | EMU=1 M8C_BETA=1 sh'
```

Safe to re-run — it updates in place and never touches your configs or
scripts. When it finishes, **Norns** and **M8C** are in Ports and
**USB Audio** is in Tools.

## First launch notes

- The first norns launch takes a couple of minutes: it seeds the controls
  config, installs low-latency audio drop-ins, and restarts the audio stack
  once. After that it's fast.
- norns controls: D-pad/sticks/shoulders = E1–E3, Y/X/A = K1–K3 — fully
  remappable in `ports/norns/cfg/controls.conf`, docs in the
  [norns-panicos README](https://github.com/djhardrich/norns-panicos).
- With norns running, maiden is at `http://<device-ip>:5000` and ingenue at
  `http://<device-ip>:7777`.
- m8c: plug the M8 in whenever — it waits. Quit with Select + R3.
