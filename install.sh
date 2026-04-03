#!/usr/bin/env bash
set -euo pipefail

# Install policy:
# - Always overwrite SKILL.md from main (users get upstream behavior; re-run to update).
# - Never overwrite local config or ledger files — only create missing defaults.

SKILL_REPO="git@github.com:Know-Your-People/haah-skill.git"
SKILL_WEB="https://github.com/Know-Your-People/haah-skill"
SKILL_RAW="https://raw.githubusercontent.com/Know-Your-People/haah-skill/main"
SKILLS_DIR="${HOME}/.openclaw/workspace/skills/haah"
HAAH_DIR="${HOME}/.openclaw/workspace/haah"

GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
BOLD=$'\033[1m'
NC=$'\033[0m'

link() {
  printf '\033]8;;%s\033\\%s\033]8;;\033\\' "$1" "${2:-$1}"
}

echo ""
echo -e "${GREEN}  ██╗  ██╗ █████╗  █████╗ ██╗  ██╗${NC}"
echo -e "${GREEN}  ██║  ██║██╔══██╗██╔══██╗██║  ██║${NC}"
echo -e "${GREEN}  ███████║███████║███████║███████║${NC}"
echo -e "${GREEN}  ██╔══██║██╔══██║██╔══██║██╔══██║${NC}"
echo -e "${GREEN}  ██║  ██║██║  ██║██║  ██║██║  ██║${NC}"
echo -e "${GREEN}  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝${NC}"
echo ""
echo "  Broadcast a question to your trusted circle. Get answers back."
echo "  ──────────────────────────────────────────"
echo ""

# Check OpenClaw is installed
if ! command -v openclaw &> /dev/null; then
  echo -e "${RED}✗ OpenClaw not found.${NC}"
  echo ""
  echo "  Install OpenClaw first: $(link 'https://openclaw.ai')"
  echo ""
  exit 1
fi

echo -e "${GREEN}✓ OpenClaw found${NC}"

# Create skills directory and fetch SKILL.md (always overwrite with latest from main)
mkdir -p "$SKILLS_DIR"

echo "  Fetching latest SKILL.md (overwrites existing)..."
curl -fsSL "${SKILL_RAW}/SKILL.md" -o "${SKILLS_DIR}/SKILL.md"

echo -e "${GREEN}✓ Skill installed to ${SKILLS_DIR}${NC}"

# Create workspace directory
if [ ! -d "$HAAH_DIR" ]; then
  mkdir -p "$HAAH_DIR"
  echo -e "${GREEN}✓ Created ${HAAH_DIR}${NC}"
else
  echo -e "${GREEN}✓ ${HAAH_DIR} already exists${NC}"
fi

# Migrate legacy ledger filenames (outbound.md / inbound.md are the canonical names)
if [ -f "${HAAH_DIR}/haah-pending.md" ] && [ ! -f "${HAAH_DIR}/outbound.md" ]; then
  mv "${HAAH_DIR}/haah-pending.md" "${HAAH_DIR}/outbound.md"
  echo -e "${GREEN}✓ Renamed haah-pending.md → outbound.md${NC}"
fi
if [ -f "${HAAH_DIR}/haah-inbound.md" ] && [ ! -f "${HAAH_DIR}/inbound.md" ]; then
  mv "${HAAH_DIR}/haah-inbound.md" "${HAAH_DIR}/inbound.md"
  echo -e "${GREEN}✓ Renamed haah-inbound.md → inbound.md${NC}"
fi

# Create empty ledger files only if missing — never overwrite user content
for ledger in "outbound.md" "inbound.md"; do
  LEDGER_FILE="${HAAH_DIR}/${ledger}"
  if [ ! -f "$LEDGER_FILE" ]; then
    touch "$LEDGER_FILE"
    echo -e "${GREEN}✓ Created ${LEDGER_FILE}${NC}"
  fi
done

# Create haahconfig.yml only if missing — never overwrite existing keys/settings
CONFIG_FILE="${HAAH_DIR}/haahconfig.yml"
if [ ! -f "$CONFIG_FILE" ]; then
  echo ""
  echo "  ──────────────────────────────────────────"
  echo -e "  ${BOLD}Register for Haah:${NC}"
  echo ""
  echo "  To activate Haah, register your account at:"
  echo ""
  echo "    $(link 'https://haah.peepsapp.ai')"
  echo ""
  echo "  Once registered, grab your key from Settings."
  echo "  A valid key is 64 lowercase hex characters. Press Enter to skip for now."
  echo ""
  read -r -p "  Key, or Enter to skip: " USER_KEY

  {
    if [ -z "$USER_KEY" ]; then
      echo "key: a3f8...c921 # replace with your key"
    else
      ESC_KEY=$(printf '%s' "$USER_KEY" | sed "s/'/''/g")
      echo "key: '${ESC_KEY}'"
    fi
  } > "$CONFIG_FILE"

  echo -e "${GREEN}✓ Created ${CONFIG_FILE}${NC}"
  if [ -z "$USER_KEY" ]; then
    echo -e "${YELLOW}  No key added — edit ${CONFIG_FILE} to add one later.${NC}"
  fi
else
  echo -e "${GREEN}✓ ${CONFIG_FILE} already exists (not modified)${NC}"
fi

echo ""
echo "  ──────────────────────────────────────────"
echo -e "  ${GREEN}All done.${NC} Try it:"
echo ""
echo '  "Search my circle — who knows a good architect in Singapore?"'
echo '  "Ask my network if anyone can help with fundraising in London."'
echo '  "Check if there are any new answers to my open questions."'
echo ""
echo "  Sign in and manage circles: $(link 'https://haah.peepsapp.ai')"
echo "  Source: $(link "$SKILL_WEB" "$SKILL_REPO")"
echo ""
