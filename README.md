# 🖥️ Raspberry Pi Health Dashboard

A **real-time terminal dashboard** to monitor your Raspberry Pi’s **power**, **temperature**, and **voltage** status — all in one clean, color-coded interface.

---

## 🚀 Features

- 📊 **Live Monitoring**
  - Continuously displays **core voltage**, **CPU temperature**, and **throttling status**.
- ⚡ **Throttle State Decoding**
  - Converts `vcgencmd get_throttled` output into readable warnings.
- 🎨 **Color-Coded Indicators**
  - 🟢 OK 🟡 Warning (Occurred before) 🔴 Problem (Active)
- 🔁 **Auto Refresh**
  - Updates every **2 seconds** in a full-screen view.
- 🧱 **Clean Terminal Layout**
  - Draws dynamic lines and uses UTF-8 icons for readability.

---

## 🧩 Requirements

| Requirement | Description |
|-------------|-------------|
| **OS** | Raspberry Pi OS (or any Linux with `vcgencmd`) |
| **Dependencies** | `bash`, `tput`, `vcgencmd` |
| **Terminal** | Must support ANSI colors and UTF-8 |

To install missing tools:
```bash
sudo apt update
sudo apt install libraspberrypi-bin
