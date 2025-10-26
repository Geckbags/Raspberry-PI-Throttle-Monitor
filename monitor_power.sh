#!/bin/bash

# This script provides a full-screen terminal dashboard to monitor the
# power, thermal, and voltage status of a Raspberry Pi.

# --- ANSI Color Codes ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Main Loop ---
# Use a while loop to run the command indefinitely.
while true
do
  # --- Data Collection ---
  TIMESTAMP=$(date +"%Y-%m-%d %T")
  THROTTLE_STATE=$(vcgencmd get_throttled)
  CORE_VOLTAGE=$(vcgencmd measure_volts core)
  CPU_TEMP=$(vcgencmd measure_temp)

  # Isolate the hexadecimal value for decoding.
  THROTTLE_HEX=${THROTTLE_STATE#*=}
  THROTTLE_DEC=$((THROTTLE_HEX))

  # Get terminal width to draw horizontal lines.
  WIDTH=$(tput cols)

  # --- Helper function to print a line ---
  print_line() {
    printf "%${WIDTH}s\n" "" | tr ' ' "─"
  }

  # --- Screen Drawing ---
  clear
  
  # --- Header ---
  printf "%s\n" "--- Raspberry Pi Health Dashboard ---"
  print_line
  printf " %-25s %s\n" "Last Updated:" "$TIMESTAMP"
  printf " %-25s %s\n" "Raw Throttle Value:" "$THROTTLE_STATE"
  print_line
  
  # --- Live Metrics ---
  printf " %-25s ${CYAN}%s${NC}\n" "Core Voltage:" "${CORE_VOLTAGE#*=}"
  printf " %-25s ${CYAN}%s${NC}\n" "CPU Temperature:" "${CPU_TEMP#*=}"
  print_line

  # --- Status Breakdown ---
  echo "--- Current Status ---"
  # Bit 0: Under-voltage is occurring NOW.
  if (( ($THROTTLE_DEC & 1) != 0 )); then
    printf " ⚡ Under-voltage:         ${RED}%s${NC}\n" "[ PROBLEM ]"
  else
    printf " ⚡ Under-voltage:         ${GREEN}%s${NC}\n" "[    OK   ]"
  fi

  # Bit 1: ARM frequency is capped NOW.
  if (( ($THROTTLE_DEC & 2) != 0 )); then
    printf " 🐌 Freq. Capped:          ${RED}%s${NC}\n" "[ PROBLEM ]"
  else
    printf " 🐌 Freq. Capped:          ${GREEN}%s${NC}\n" "[    OK   ]"
  fi

  # Bit 2: Throttling is occurring NOW.
  if (( ($THROTTLE_DEC & 4) != 0 )); then
    printf " 🌡️ Throttled:             ${RED}%s${NC}\n" "[ PROBLEM ]"
  else
    printf " 🌡️ Throttled:             ${GREEN}%s${NC}\n" "[    OK   ]"
  fi

  echo ""
  echo "--- History (since last boot) ---"
  # Bit 16: Under-voltage HAS occurred.
  if (( ($THROTTLE_DEC & (1<<16)) != 0 )); then
    printf " ⚡ Under-voltage occurred: ${YELLOW}%s${NC}\n" "[  YES  ]"
  else
    printf " ⚡ Under-voltage occurred: ${GREEN}%s${NC}\n" "[   NO   ]"
  fi

  # Bit 17: ARM frequency capping HAS occurred.
  if (( ($THROTTLE_DEC & (1<<17)) != 0 )); then
    printf " 🐌 Freq. Capping occurred: ${YELLOW}%s${NC}\n" "[  YES  ]"
  else
    printf " 🐌 Freq. Capping occurred: ${GREEN}%s${NC}\n" "[   NO   ]"
  fi

  # Bit 18: Throttling HAS occurred.
  if (( ($THROTTLE_DEC & (1<<18)) != 0 )); then
    printf " 🌡️ Throttling occurred:    ${YELLOW}%s${NC}\n" "[  YES  ]"
  else
    printf " 🌡️ Throttling occurred:    ${GREEN}%s${NC}\n" "[   NO   ]"
  fi

  print_line
  echo "Press [Ctrl+C] to exit."

  # Wait for 2 seconds before the next check.
  sleep 2
done

