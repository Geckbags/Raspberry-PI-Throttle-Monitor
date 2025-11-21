#!/bin/bash

# --- Raspberry Pi Health Dashboard (Ultimate Edition) ---
# Features:
# 1. Power Supply Health (Pass/Fail)
# 2. Real-time CPU Usage (0-100%)
# 3. Visual Gauges & Status Badges
# 4. Event Logging & Audible Alarms

# --- Configuration ---
LOG_FILE="pi_power_log.csv"
ENABLE_AUDIBLE_ALARM=true

# --- Styling & Colors ---
# Text Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[1;30m'
NC='\033[0m' # No Color

# Background Colors (for badges)
BG_RED='\033[41m\033[1;37m'    # White on Red
BG_GREEN='\033[42m\033[1;37m'  # White on Green
BG_YELLOW='\033[43m\033[1;37m' # White on Yellow

# Box Drawing Characters
BOX_H="─"
BOX_V="│"
BOX_TL="┌"
BOX_TR="┐"
BOX_BL="└"
BOX_BR="┘"

# --- Initialization ---
UNDERVOLT_COUNT=0

# Hide Cursor on start, Show on exit
tput civis
trap "tput cnorm; echo -e '${NC}'; exit" INT TERM EXIT

# Initialize Log
if [ ! -f "$LOG_FILE" ]; then
    echo "Timestamp,Throttle_Hex,Temp_C,Core_Volts,Freq_MHz,Cpu_Usage_Pct,UnderVolt_Now" > "$LOG_FILE"
fi

# --- CPU Usage Helper ---
get_cpu_stats() {
  read -r cpu a b c idle rest < /proc/stat
  # Sum all columns to get total CPU time
  echo "$((a+b+c+idle)) $idle"
}
# Read initial state for accurate calculation
read PREV_TOTAL PREV_IDLE <<< $(get_cpu_stats)

# --- UI Helper: Draw Bar ---
# Usage: draw_bar <current_value> <max_value>
draw_bar() {
    local val=$1
    local max=$2
    local width=20
    
    # Cap value at max to prevent bar breaking
    if [ "$val" -gt "$max" ]; then val=$max; fi
    
    local percent=$(( (val * 100) / max ))
    local filled=$(( (val * width) / max ))
    local empty=$(( width - filled ))

    # Color logic
    local color=$GREEN
    if [ "$percent" -ge 80 ]; then color=$RED;
    elif [ "$percent" -ge 50 ]; then color=$YELLOW; fi

    printf "${GRAY}[${color}"
    if [ "$filled" -gt 0 ]; then printf "%0.s|" $(seq 1 $filled); fi
    printf "${GRAY}"
    if [ "$empty" -gt 0 ]; then printf "%0.s." $(seq 1 $empty); fi
    printf "${GRAY}]${NC}"
}

# --- Main Loop ---
while true
do
  # --- 1. Data Collection ---
  TIMESTAMP=$(date +"%T")
  THROTTLE_STATE=$(vcgencmd get_throttled)
  CORE_VOLTAGE=$(vcgencmd measure_volts core)
  CPU_TEMP=$(vcgencmd measure_temp)
  CLOCK_FREQ=$(vcgencmd measure_clock arm)
  
  # --- 2. CPU Usage Calculation (Real 0-100%) ---
  read CURR_TOTAL CURR_IDLE <<< $(get_cpu_stats)
  DIFF_TOTAL=$((CURR_TOTAL - PREV_TOTAL))
  DIFF_IDLE=$((CURR_IDLE - PREV_IDLE))

  if [ "$DIFF_TOTAL" -ne 0 ]; then
    CPU_USAGE=$(( (100 * (DIFF_TOTAL - DIFF_IDLE)) / DIFF_TOTAL ))
  else
    CPU_USAGE=0
  fi
  # Save state for next loop
  PREV_TOTAL=$CURR_TOTAL
  PREV_IDLE=$CURR_IDLE

  # --- 3. Parsing & Logic ---
  THROTTLE_HEX=${THROTTLE_STATE#*=}
  THROTTLE_DEC=$((THROTTLE_HEX))
  FREQ_MHZ=$((${CLOCK_FREQ#*=} / 1000000))
  
  RAW_TEMP_STR=${CPU_TEMP#*=}
  RAW_TEMP_NUM=$(echo "$RAW_TEMP_STR" | tr -d "'C")
  TEMP_INT=${RAW_TEMP_NUM%.*} 

  # Check Power Status
  CURRENTLY_UNDERVOLTED=false
  if (( ($THROTTLE_DEC & 1) != 0 )); then
    CURRENTLY_UNDERVOLTED=true
    UNDERVOLT_COUNT=$((UNDERVOLT_COUNT+1))
    if [ "$ENABLE_AUDIBLE_ALARM" = true ]; then printf "\a"; fi
  fi

  # Logging
  if (( ($THROTTLE_DEC & 1) != 0 )) || (( ($THROTTLE_DEC & (1<<16)) != 0 )); then
    if [ $(stat -c%s "$LOG_FILE") -lt 10000000 ]; then
        UV_FLAG="NO"
        if [ "$CURRENTLY_UNDERVOLTED" = true ]; then UV_FLAG="YES"; fi
        echo "$(date +"%Y-%m-%d %T"),$THROTTLE_HEX,$RAW_TEMP_NUM,${CORE_VOLTAGE#*=},$FREQ_MHZ,$CPU_USAGE,$UV_FLAG" >> "$LOG_FILE"
    fi
  fi

  # --- 4. Interface Drawing ---
  clear
  
  # Header
  echo -e "${WHITE}${BOX_TL}$(printf "%0.s${BOX_H}" {1..48})${BOX_TR}${NC}"
  printf "${WHITE}${BOX_V}  RASPBERRY PI MONITOR   %-23s${BOX_V}${NC}\n" "$TIMESTAMP"
  echo -e "${WHITE}${BOX_BL}$(printf "%0.s${BOX_H}" {1..48})${BOX_BR}${NC}"
  echo ""

  # SECTION: POWER SUPPLY
  echo -e " ${WHITE}POWER SUPPLY HEALTH:${NC}"
  
  if [ "$CURRENTLY_UNDERVOLTED" = true ]; then
    printf " Status:  ${BG_RED} CRITICAL FAILURE ${NC}  (Check Cable/Brick!)\n"
  elif (( ($THROTTLE_DEC & (1<<16)) != 0 )); then
    printf " Status:  ${BG_YELLOW} UNSTABLE ${NC}  (Voltage drops detected)\n"
  else
    printf " Status:  ${BG_GREEN} OK ${NC}  (Voltage stable > 4.63V)\n"
  fi
  
  printf " Events:  ${YELLOW}%d${NC} undervolt events this session\n" "$UNDERVOLT_COUNT"
  echo ""
  
  # SECTION: PERFORMANCE
  echo -e " ${WHITE}PERFORMANCE:${NC}"
  
  # Temp Bar
  printf " CPU Temp:  "
  draw_bar "$TEMP_INT" "85"
  printf " ${CYAN}%s${NC}\n" "$RAW_TEMP_STR"

  # Usage Bar
  printf " CPU Usage: "
  draw_bar "$CPU_USAGE" "100"
  printf " ${CYAN}%s%%${NC}\n" "$CPU_USAGE"
  
  # SECTION: METRICS GRID
  echo ""
  echo -e " ${WHITE}METRICS:${NC}"
  printf " ${GRAY}Core Volt:${NC} %-10s   ${GRAY}Clock:${NC} %s MHz\n" "${CORE_VOLTAGE#*=}" "$FREQ_MHZ"
  printf " ${GRAY}Throttle:${NC}  %-10s   ${GRAY}Gov:${NC}   %s\n" "$THROTTLE_HEX" "$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"

  # SECTION: ALERTS
  echo ""
  if (( ($THROTTLE_DEC & 2) != 0 )); then
     echo -e " ${BG_RED} ALERT ${NC} Frequency CAPPED (Heat/Power)!"
  fi
  if (( ($THROTTLE_DEC & 4) != 0 )); then
     echo -e " ${BG_RED} ALERT ${NC} CPU is THROTTLING!"
  fi

  # Footer
  echo ""
  echo -e "${GRAY}Press [Ctrl+C] to exit.${NC}"

  sleep 2
done
