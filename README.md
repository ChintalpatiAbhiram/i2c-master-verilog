# I2C Master Controller in Verilog
I2C communication protocol using verilog

# Overview

This project implements an I2C Master Controller in Verilog HDL using a Finite State Machine (FSM) architecture. The design supports fundamental I2C operations including START condition generation, STOP condition generation, ACK handling, and serial byte transmission.

The project was developed and simulated using Xilinx Vivado.

# Features
1. I2C START and STOP condition generation
2. Serial byte transmission over SDA
3. FSM-based protocol sequencing
4. ACK detection support
5. SCL clock generation
6. Simulation testbench included

# Tools Used
1. Verilog HDL
2. Xilinx Vivado

# FSM States

The controller uses an FSM for protocol handling.

Main states include:

1. IDLE
2. START
3. ADDRESS
4. ACK
5. WRITE_DATA
6. STOP

# Future Improvements
1. Read operation support
2. Repeated START support
3. Clock stretching support
4. Multi-slave communication
