Raspberry Pi Health Dashboard
A full-screen, real-time terminal dashboard to monitor the power, thermal, and voltage status of your Raspberry Pi.

This script provides an at-a-glance, color-coded view of your Pi's health, refreshing every two seconds. It clearly distinguishes between current problems (happening right now) and historical problems (that have happened since the last boot).

Example Output
Here is a sample of what the dashboard looks like. Statuses will be color-coded in your terminal (Green for OK, Red for current problems, Yellow for historical issues).

Plaintext

--- Raspberry Pi Health Dashboard ---
──────────────────────────────────────────────────────────────────────────────
 Last Updated:            2025-10-26 19:30:02
 Raw Throttle Value:      throttled=0x50000
──────────────────────────────────────────────────────────────────────────────
 Core Voltage:            1.2000V
 CPU Temperature:         45.5'C
──────────────────────────────────────────────────────────────────────────────
--- Current Status ---
 ⚡ Under-voltage:         [   OK    ]
 🐌 Freq. Capped:          [   OK    ]
 🌡️ Throttled:             [   OK    ]

--- History (since last boot) ---
 ⚡ Under-voltage occurred: [   YES   ]
 🐌 Freq. Capping occurred: [   NO    ]
 🌡️ Throttling occurred:    [   YES   ]
──────────────────────────────────────────────────────────────────────────────
Press [Ctrl+C] to exit.
Features
Full-Screen Dashboard: Clears the screen on each update for a clean, easy-to-read display.

Live Metrics: Monitors real-time Core Voltage and CPU Temperature.

Color-Coded Status:

<span style="color:green;">GREEN</span> [ OK ] / [ NO ]: No problem detected.

<span style="color:red;">RED</span> [ PROBLEM ]: A problem is currently happening.

<span style="color:yellow;">YELLOW</span> [ YES ]: A problem has occurred since the last boot.

Detailed Throttle Breakdown: Separates status into "Current" and "History" to help diagnose intermittent issues.

Current Status: Checks for active under-voltage, frequency capping, or throttling.

History: Reports if any of these events have happened in the past (since the last boot).

Auto-Refreshes: Updates all data every 2 seconds.

How to Use
Clone the repository:

Bash

git clone https://github.com/Geekbags/Raspberry-Pi-Throttle-Monitor.git
cd Raspberry-Pi-Throttle-Monitor
Make the script executable: (Assuming you name this script dashboard.sh)

Bash

chmod +x dashboard.sh
Run the script:

Bash

./dashboard.sh
Exit: Press Ctrl+C to stop the dashboard.

Understanding the Output
Live Metrics (Core Voltage, CPU Temperature): These are live readings. Keep an eye on the temperature to ensure it doesn't get too high (typically above 80'C).

Current Status ([ PROBLEM ] in Red): This section tells you what is wrong right now.

Under-voltage: Your power supply is not providing enough voltage. This is a common issue. Check your power adapter and USB cable.

Freq. Capped: The CPU clock speed is being limited, likely due to high temperature.

Throttled: The system is actively reducing performance to protect against damage (from heat or low voltage).

History ([ YES ] in Yellow): This section tells you what has happened since the Pi was last powered on. A [ YES ] here, even if the "Current Status" is [ OK ], means you have an intermittent problem. For example, your Pi might have been throttled during a heavy task, but is now idle and back to normal.

License
This project is licensed under the MIT License - see the LICENSE file for details.
