# Real-Time FPGA Weather Monitoring System
Using Basys 3 and DHT11 Temperature & Humidity Sensor
By Hanuman Mattupalli

## Description
This project presents an FPGA-based integrated system that combines a 12-hour digital clock with DHT11 environmental sensing, implemented on the Basys 3 development board. The system features dynamic display multiplexing, adaptive sensor polling, and context-aware controls, all while maintaining efficient hardware utilization.
It demonstrates:
Accurate timekeeping (±1 sec/day),
Reliable sensor measurements (±2°C, ±5% RH),
Compact integration using <15% of FPGA resources.
This design is fully validated through hardware testing and real-time performance.  

### Why Basys3 ?
Basys3 has some convincing Features which made me use it this project particularly. Those features include:

Seven Segment Displays:
Displaying Real-time adjustable clock requires some Display interface, which Basys3 has it inbuilt. Other FPGA's can also be used but we have to connct 2 Pmod Seven segment displays additionally.

Pmod Ports:
Basys 3 has 4 Pmod connectors (JA–JD).
Each Pmod interface has 8 data lines and 2 power lines (3.3V and GND).
Interfacing DHT11 sensor can be done using these Pmod ports.

### DHT11 Sensor
The DHT11 is a low-cost, digital temperature and humidity sensor. 
Measures:
-Humidity: 20–90% RH (±5%)
-Temperature: 0–50°C (±2°C)
-Supply Voltage: 3.3V to 5V
-Interface: Single-wire digital protocol (not I²C or UART!)
-Output: 40-bit digital data (in 5 bytes)
-Sampling Rate: 1 Hz (1 reading per second)

Bits:
39 – 32	Humidity integer part	e.g., 00110111 → 55% RH
31 – 24	Humidity decimal part	Always 0 for DHT11
23 – 16	Temperature integer part	e.g., 00011000 → 24°C
15 – 8	Temperature decimal part	Always 0 for DHT11
7 – 0	Checksum	Sum of the first 4 bytes modulo 256

Sensor limitation:
Only 1 reading per second allowed,
Timing is critical: Data bits are identified by pulse lengths:
Logic '0': 50 µs low + 26–28 µs high
Logic '1': 50 µs low + 70 µs high

All these constraints are carefully checked and implemented in DHT11_read file.

#### Additional Info
Digital_clock reference:
https://youtu.be/3Waa9Y4OcLo?si=B7p25YSnFnwkum51

Basys 3 Device Part (for Vivado): If the board is not listed, search using the part number:
xc7a35tcpg236-1




