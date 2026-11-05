#!/usr/bin/env bash
# Installs the Cosmic template into AMP as a local deployment template. Run with sudo.
#   sudo ./install.sh              install/refresh the template and restart ADS
#   sudo ./install.sh --let-claude-read
#                                  also give bronco read-only access to AMP's template folder and ADS logs
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
PROJECT="$(dirname "$SRC")"

# amp has to reach the project folder: traverse-only on the home dir, no listing
setfacl -m u:amp:x "$(dirname "$PROJECT")"
sudo -u amp test -r "$PROJECT/docker-compose.yml" || { echo "amp still can't read $PROJECT/docker-compose.yml"; exit 1; }
sudo -u amp docker info >/dev/null 2>&1 || echo "WARNING: amp can't talk to Docker yet (is it in the docker group? restart ampinstmgr after adding it)"

ADS_PLUGIN=$(ls -d /home/amp/.ampdata/instances/*/Plugins/ADSModule 2>/dev/null | head -1)
[ -n "$ADS_PLUGIN" ] || { echo "Couldn't find ADS under /home/amp/.ampdata/instances"; exit 1; }
ADS_DIR="$(dirname "$(dirname "$ADS_PLUGIN")")"
ADS_NAME=$(basename "$ADS_DIR")
DEST="$ADS_PLUGIN/DeploymentTemplates/LOCAL-cosmic-main"

# AMP only loads a template folder that has a manifest.json describing it
mkdir -p "$DEST"
cp "$SRC"/manifest.json "$SRC"/cosmic.kvp "$SRC"/cosmic*.json "$DEST/"
chown -R amp:amp "$ADS_PLUGIN/DeploymentTemplates"
echo "Template copied to $DEST:"
ls -la "$DEST"
echo "Other template folders:"
ls "$ADS_PLUGIN/DeploymentTemplates"

if [[ "${1:-}" == "--let-claude-read" ]]; then
    # read-only for bronco: traverse the parents, read the templates and ADS logs; nothing else
    setfacl -m u:bronco:x /home/amp /home/amp/.ampdata /home/amp/.ampdata/instances "$ADS_DIR" "$ADS_DIR/Plugins" "$ADS_PLUGIN"
    setfacl -R -m u:bronco:rX -m d:u:bronco:rX "$ADS_PLUGIN/DeploymentTemplates"
    [ -d "$ADS_DIR/AMP_Logs" ] && setfacl -R -m u:bronco:rX -m d:u:bronco:rX "$ADS_DIR/AMP_Logs"
    echo "bronco can now read $ADS_PLUGIN/DeploymentTemplates and $ADS_DIR/AMP_Logs"
fi

sudo -u amp ampinstmgr --RestartInstance "$ADS_NAME"
echo "Restarted $ADS_NAME. In AMP: refresh the browser, then Create Instance -> look under 'JM' for"
echo "'MapleStory v83 (Cosmic, Docker)'. Untick the Docker/container option when creating it."
