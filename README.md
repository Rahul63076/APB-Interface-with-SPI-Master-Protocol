APB Interface With SPI Master – Verilog Project
-

This project shows how an APB (Advanced Peripheral Bus) Slave controls an SPI Master using Verilog.
The APB side writes configuration and data, and the SPI Master sends/receives data through MOSI/MISO.
---

📌 Overview

APB is used by processor to write/read registers.
SPI Master uses those registers to send data to an external SPI Slave.
Output data (received from MISO) is given back to APB through read register.
---

📦 Features

APB Slave interface (PSEL, PENABLE, PWRITE, PWDATA, PRDATA)
SPI Master (MOSI, MISO, SCLK, SS)
Control register (enable, CPOL, CPHA)
Clock divider for SPI SCLK
TX register & RX register
Transfer-done status flag
Clean modular Verilog design
Task-based APB testbench
---

🧩 Block Modules

1. APB Slave – handles read/write and updates registers
2. Control Register – SPI enable, mode bits
3. Clock Divider – creates SCLK
4. TX Register – holds parallel data to send
5. RX Register – stores received data
6. SPI Master – shifts data on MOSI and samples MISO
8. Top Module – connects all blocks


⚙️ How It Works

1. APB Master writes:
SPI enable
CPOL/CPHA
Clock divider
TX data
2. SPI Master starts transfer
3. SCLK toggles
4. MOSI sends bits (MSB → LSB)
5. MISO data is captured
6. RX register stores received data
7. Transfer-done flag goes high
8. APB Master reads RX data and status
---
