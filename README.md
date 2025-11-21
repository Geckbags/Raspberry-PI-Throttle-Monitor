# 🖥️ Raspberry Pi Health Dashboard (Ultimate Edition)

A **professional terminal dashboard** to diagnose and monitor your Raspberry Pi’s **power supply health**, **CPU performance**, and **thermal status**.

Now featuring a TUI (Text User Interface) with visual gauges, real-time graphs, and historical logging.

---

## 🚀 Features

### 🔌 Power Supply Diagnostics (New!)
- **"Brick Test"**: Instantly tells you if your power supply (brick) or cable is failing.
- **Pass/Fail Badges**: Clearly marks status as `[ OK ]`, `[ UNSTABLE ]`, or `[ CRITICAL ]`.
- **Audible Alarms**: System bell (`\a`) beeps immediately when a voltage drop occurs.

### 📊 Visual Performance Monitoring
- **Real-Time CPU Usage**: Calculates precise 0-100% CPU usage (unlike Load Average).
- **Visual Gauges**: Progress bars `[|||||.....]` for Temperature and CPU Load.
- **Color-Coded Indicators**: Bars change from **Green** → **Yellow** → **Red** based on severity.

### 📝 Event Logging
- **Auto-Logging**: Automatically saves power events to `pi_power_log.csv`.
- **History**: Records Timestamp, Voltage, Temp, and CPU metrics whenever an undervolt occurs, helping you catch intermittent power drops.

### 🎨 Professional UI
- **Clean Layout**: Uses Unicode box-drawing characters for a polished look.
- **Static Interface**: Hides the cursor and prevents flickering for a smooth dashboard experience.

---

## 🧩 Requirements

| Requirement | Description |
|-------------|-------------|
| **OS** | Raspberry Pi OS (or any Linux with `vcgencmd`) |
| **Dependencies** | `bash`, `vcgencmd` (pre-installed on Pi OS) |
| **Terminal** | Must support ANSI colors and UTF-8 |

---

## 📥 Installation & Usage

1. **Download the script:**
   Save the code to a file named `monitor_power.sh`.

2. **Make it executable:**
   ```bash
   chmod +x monitor_power.sh
