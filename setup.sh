#!/bin/sh
# panicos-setup — one-command music setup for a bare PanicOS device.
# Run ON the device as root (or via ssh):
#
#   ssh root@<device-ip> 'curl -fsSL https://raw.githubusercontent.com/seajaysec/panicos-setup/master/setup.sh | sh'
#
# Installs, idempotently (safe to re-run):
#   1. norns        — monome norns port (Ports > Norns), engines + audio fixes baked in
#   2. m8c          — Dirtywave M8 client (Ports > M8C); M8C_BETA=1 adds the SDL3 beta
#   3. usb-audio    — system-wide USB in/out toggles (Tools > USB Audio)
#   4. warp_pipe    — norns mod: USB audio into the norns graph (pre-enabled)
set -e

NORNS_ZIP="https://github.com/seajaysec/norns-panicos/releases/download/v0.2.0-rc1/norns-panicos.zip"
M8C_TGZ="https://github.com/seajaysec/panicos-m8c/releases/download/v1.0.0/m8c-port.tar.gz"
M8C_BETA_TGZ="https://github.com/seajaysec/panicos-m8c/releases/download/v1.0.0/m8c-beta-port.tar.gz"
USBAUDIO_TGZ="https://github.com/seajaysec/panicos-usb-audio/releases/download/v1.0.0/usb-audio-bundle.tar.gz"
WARP_PIPE_GIT="https://github.com/seajaysec/warp_pipe"

grep -qi panicos /etc/os-release 2>/dev/null || { echo "this doesn't look like a PanicOS device" >&2; exit 1; }
PORTS=/storage/roms/ports
[ -d "$PORTS" ] || { echo "$PORTS missing — is PortMaster installed? (Tools > Install PortMaster)" >&2; exit 1; }

echo "== [1/4] norns =="
curl -fSL -o /tmp/norns-panicos.zip "$NORNS_ZIP"
( cd "$PORTS" && unzip -oq /tmp/norns-panicos.zip && chmod +x Norns.sh norns/bin/* )
rm -f /tmp/norns-panicos.zip
echo "   norns installed"

echo "== [2/4] m8c =="
curl -fSL "$M8C_TGZ" | tar xz -C "$PORTS"
chmod +x "$PORTS/M8C.sh" "$PORTS/m8c/m8c"
if [ "${M8C_BETA:-0}" = 1 ]; then
    curl -fSL "$M8C_BETA_TGZ" | tar xz -C "$PORTS"
    chmod +x "$PORTS/M8C-Beta.sh" "$PORTS/m8c-beta/m8c"
    echo "   m8c installed (stable + beta)"
else
    echo "   m8c installed (M8C_BETA=1 for the SDL3 beta too)"
fi

echo "== [3/4] usb-audio =="
rm -rf /tmp/ua && mkdir -p /tmp/ua
curl -fSL "$USBAUDIO_TGZ" | tar xz -C /tmp/ua
sh /tmp/ua/install.sh
rm -rf /tmp/ua

echo "== [4/4] warp_pipe (norns mod) =="
WP="$PORTS/norns/data/dust/code/warp_pipe"
if [ -d "$WP/.git" ] || [ -f "$WP/lib/mod.lua" ]; then
    echo "   already present — leaving as-is"
else
    git clone -q --depth 1 "$WARP_PIPE_GIT" "$WP"
    chmod +x "$WP/setup/bin/shairport-sync" 2>/dev/null || true
    echo "   installed"
fi
MODS="$PORTS/norns/data/dust/data/system.mods"
if [ ! -f "$MODS" ]; then
    printf 'return {\n{\n   "warp_pipe",\n},\n}\n' > "$MODS"
    echo "   pre-enabled (SYSTEM > MODS)"
elif ! grep -q warp_pipe "$MODS"; then
    echo "   NOTE: enable warp_pipe manually in norns SYSTEM > MODS (won't edit your existing mods file)"
fi

systemctl restart panicos-es.service 2>/dev/null || true
echo ""
echo "=== done — Ports: Norns, M8C · Tools: USB Audio ==="
echo "First norns launch takes a couple of minutes (seeds config, tunes audio latency)."
