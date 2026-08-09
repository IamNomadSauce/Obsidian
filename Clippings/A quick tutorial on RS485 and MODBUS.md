---
title: "A quick tutorial on RS485 and MODBUS"
source: "https://www.virtual-serial-port.org/articles/modbus-vs-rs485/"
author:
  - "[[Olga Weis]]"
published: 2024-10-04
created: 2026-05-03
description: "If you are a technician responsible for supporting RS485 devices, there are some techniques that can make your job easier. We present this short tutorial that demonstrates the differences in the Modbus vs RS485 protocols."
tags:
  - "clippings"
---
![Cookie](https://www.virtual-serial-port.org/images/upload/gdpr/cookie.png)

Electronic Team, Inc. uses cookies to personalize your experience on our website. By continuing to use this site, you agree to our cookie policy. Click [here](https://www.electronic.us/company/policies/#Cookies "Policy") to learn more.

## Modbus vs RS485

This article provides a comprehensive tutorial on RS485 communication and its relationship with the Modbus protocol. It explains the key distinctions between RS485 and RS232, explores the half-duplex system used in RS485 networks, and breaks down the Modbus protocol—widely implemented in RS485 devices. Learn about Modbus message formats, serial transmission modes, and how to navigate RS485-based industrial communication systems effectively. This guide is essential for technicians working with RS485 and Modbus protocols.

Contents

## Understanding the Differences: Is Modbus the Same as RS485?

RS485 is a serial data transmission standard widely used in industrial implementations. The Modbus protocol is commonly used when implementing RS485 communication. This differentiates RS485 from the RS232 protocol which communicates by transmitting with ASCII characters. It is important to understand Modbus if you will be working with devices using the RS485 protocol.

If you are a technician responsible for supporting RS485 devices, there are some techniques that can make your job easier. We present this short tutorial that demonstrates the differences in the Modbus vs RS485 protocols.

## What is RS485 communication?

```
RS485
```
is a protocol similar to RS232 that is used to implement serial data communication. The two protocols use different electric signals to enable data transmission.

One of the reasons that RS485 interfacing is employed in industrial settings is its ability to serve several devices attached to the same bus. This eliminates the need to have several interfaces available when querying multiple devices. You can do this by using a

```
bus terminator
```
, moving a switch or with a small resistor screwed onto a terminal.

Care must be taken to ensure that the correct interface is being used as the RS485 and RS32 protocols are not completely compatible. You can construct a gateway between RS232 and RS485 interfaces, but usually you will see the RS485 protocol connecting directly to USB, GSM or Ethernet ports. This less expensive approach removes the requirement for any additional components to be used.

Devices using RS485 ports usually employ the Modbus protocol. When moving from working with the ASCII protocols of RS232 devices, it is advisable to learn the differences involved with the Modbus protocol. That is the purpose of this brief Modbus tutorial.

Below is a table that summarizes the characteristics of the RS485 protocol. RS485 provides half-duplex transmission on a balanced line covering distances of up to 1.2 km.

| **Parameter** |  |
| --- | --- |
| Mode of Operation | Differential |
| Number of Drivers and Receivers | 32 Drivers   32 Receivers |
| Maximum cable length (metres) | 1200 |
| Maximum data rate (baud) | 10 M |
| Maximum common mode voltage (Volts) | 12 to -7 |
| Minimum Driver Output Levels (Loaded) | +/- 1.5 |
| Minimum Driver Output Levels (Unloaded) | +/- 6 |
| Drive Load (Ohms) | 60 (min) |
| Driver Output short circuit current Limit (mA) | 150 to Gnd, 250 to -7 or 12 V |
| Minimum receiver input Resistance (kohms) | 12 |
| Receiver sensitivity | +/- 200mv |

If you desire more information regarding RS485 you can consult the

```
EIA (Electronic Industries Association)
```
or companies such as
```
Texas Instruments
```
or Maxim Semiconductors that manufacture devices compatible with the protocol.

### What is half-duplex system?

A **half-duplex** system is comprised of one or more transmitters and receivers where only one transmitter can be active at a time. Communication is enacted by a transmitter making a request directed at a specific receiver. The transmitter then waits a pre-determined length of time for a reply or decides that no reply will be forthcoming from the receiver.

An RS485 network is built based on a master/slave framework. The master performs the role of the transmitter, making requests to a designated slave which acts as the receiver. The master listens for the response and if not obtained in an appropriate time-frame will terminate the communication.

## What is Modbus?

### Modbus Messages

**The principle of Modbus messages.** In a Modbus RS485 Network, communication begins when the master device sends a query to a connected slave. A slave device spends its time monitoring the network for queries specifically addressed to it. When a query is received, it will either perform an action or reply with a response to the master. Queries are only initiated by the master device.

![The principle of Modbus messages](https://www.virtual-serial-port.org/images/upload/products/spm/articles/modbus/1.jpg "The principle of Modbus messages")

The Modbus protocol affords the master the choice of addressing messages to specific slave devices or communicating with all slaves simultaneously. This is done using a special “Broadcast” address. Some products such as those from Integra and SPR do not support the use of this broadcast address.

Read and write operations are sent through Modbus messages using coils. A coil consists of 16-bit words and binary registers. A slave can only respond to a received message and never initiates communication with the master.

Each slave device attached to the RS485 bus in parallel is assigned a unique Modbus slave ID. All Modbus communication begins with the slave ID being sent, either to alert a slave device to accept a query or inform the master which device supplied the reply.

In the same way that RS232 connectivity works, slave and master devices need to be configured correctly. Parameters such as speed and parity need to be synchronized throughout the network.

### Modbus Message Format

The message format is used in Modbus communication between master and slave is defined in the protocol.

A **Modbus query** is made up of the device (or broadcast) address, a function code that defines any requested action, data returned with the request, and an error-checking field.

A **Modbus response** is comprised of fields that verify the requested action has been taken, data sent with the response, and an error-checking field. The slave device will create an error message as its response if it is unable to fulfill the request or if errors impacted the receipt of the message.

### The Serial Transmission Modes

Modbus communication employs two distinct serial transmission modes: ASCII and RTU.

[**Modbus ASCII**](https://www.virtual-serial-port.org/articles/modbus-ascii-guide/) (American Standard Code for Information Interchange) mode sends each 8-bit message as two ASCII characters. Advantages of ASCII mode include the ability to easily monitor messages on a text console. This mode also allows for a one-second interval to be acceptable without initiating a timeout.

[**Modbus RTU**](https://www.virtual-serial-port.org/articles/modbus-rtu-guide/) (Remote Terminal Unit) mode transmits messages in a different format. Here, an 8-bit message contains two 4-bit hexadecimal characters. Data using this transmission mode is required to be sent in a continuous stream and enables better throughput for a comparable baud rate than does ASCII mode.

### Serial Port Monitor

Requirements: Windows (32-bit and 64-bit): Vista/7/8/10/11, Windows Server 2008/2012/2016/2019/2022, Windows on ARM, 9.85MB size  
Version 9.5.600 (8 Mar, 2025) [Release notes](https://help.electronic.us/support/solutions/articles/44002214674-what-s-new-in-this-version-of-serial-port-monitor "Changelog (RSS)")  
Category: Communication Application

4.8 Rank  
based on  
345 + users Reviews (345)