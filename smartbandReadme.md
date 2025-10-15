# MirrorMind SmartBand - Bluetooth Integration Guide

This document provides all the necessary information to connect to the MirrorMind SmartBand from a Swift application and receive real-time biometric data.

## Device Overview

The MirrorMind SmartBand is built on a Seeed XIAO ESP32C3 microcontroller and uses a MAX30105 sensor for heart rate and temperature monitoring. It transmits biometric data via Bluetooth Low Energy (BLE).

## Hardware Specifications

- **Microcontroller**: Seeed XIAO ESP32C3
- **Sensor**: MAX30105 (Heart Rate + Temperature)
- **Communication**: Bluetooth Low Energy (BLE)
- **Power**: USB-C charging
- **Placement**: Designed for wrist positioning

## Bluetooth Configuration

### Device Information
```
Device Name: "MirrorMind-SmartBand"
Service UUID: "12345678-1234-1234-1234-123456789abc"
Characteristic UUID: "87654321-4321-4321-4321-cba987654321"
```

### Connection Properties
- **Protocol**: Bluetooth Low Energy (BLE)
- **Characteristic Type**: Notify (unidirectional from device to app)
- **Data Format**: JSON strings
- **Update Frequency**: ~25ms intervals when finger detected
- **Status Updates**: Every 3 seconds

## Data Structure

The device sends JSON-formatted data with the following structure:

### Complete Data Packet (Finger Detected + Valid Heart Rate)
```json
{
  "heartRate": 72.0,
  "temperature": 36.5,
  "rawTemperature": 34.2,
  "irValue": 85432,
  "fingerDetected": true,
  "validHeartRate": true,
  "timestamp": 123456789
}
```

### No Heart Rate Data (Finger Detected, Calculating)
```json
{
  "heartRate": 0.0,
  "temperature": 36.8,
  "rawTemperature": 34.5,
  "irValue": 75221,
  "fingerDetected": true,
  "validHeartRate": false,
  "timestamp": 123456790
}
```

### No Finger Detected
```json
{
  "heartRate": 0.0,
  "temperature": 36.2,
  "rawTemperature": 33.9,
  "irValue": 25000,
  "fingerDetected": false,
  "validHeartRate": false,
  "timestamp": 123456791
}
```

## Data Field Descriptions

| Field | Type | Description | Range |
|-------|------|-------------|-------|
| `heartRate` | Float | Calculated BPM (0 when invalid) | 40-200 BPM |
| `temperature` | Float | Calibrated body temperature | 36.0-37.0°C |
| `rawTemperature` | Float | Raw sensor temperature | ~33-36°C |
| `irValue` | Long | Infrared sensor reading | 0-2^32 |
| `fingerDetected` | Boolean | Finger presence detection | <50000 = false |
| `validHeartRate` | Boolean | Heart rate calculation status | Requires 3+ beats |
| `timestamp` | Long | Device uptime in milliseconds | 0-2^32 |

## Swift Integration Guide

### 1. Core Bluetooth Setup

Import the necessary framework:
```swift
import CoreBluetooth
```

### 2. UUID Constants
```swift
let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-123456789abc")
let characteristicUUID = CBUUID(string: "87654321-4321-4321-4321-cba987654321")
let deviceName = "MirrorMind-SmartBand"
```

### 3. Data Model
```swift
struct BiometricData: Codable {
    let heartRate: Float
    let temperature: Float
    let rawTemperature: Float
    let irValue: Int64
    let fingerDetected: Bool
    let validHeartRate: Bool
    let timestamp: Int64
}
```

### 4. Connection Process

1. **Scan for devices** with the service UUID
2. **Connect** when "MirrorMind-SmartBand" is found
3. **Discover services** using the service UUID
4. **Discover characteristics** using the characteristic UUID
5. **Enable notifications** on the TX characteristic
6. **Parse incoming JSON data** in the notification callback

### 5. Data Parsing Example
```swift
func parseReceivedData(_ data: Data) -> BiometricData? {
    guard let jsonString = String(data: data, encoding: .utf8) else { return nil }
    guard let jsonData = jsonString.data(using: .utf8) else { return nil }
    
    do {
        return try JSONDecoder().decode(BiometricData.self, from: jsonData)
    } catch {
        print("JSON parsing error: \(error)")
        return nil
    }
}
```

## Device Behavior

### Heart Rate Calculation
- Requires **minimum 3 beats** for valid reading
- Uses **4-point moving average** for smoothing
- Filters readings outside **40-200 BPM** range
- Resets when finger removed

### Temperature Calibration
- **Raw temperature**: Direct MAX30105 sensor reading
- **Calibrated temperature**: Advanced algorithm with dynamic correction
- **Safety clamp**: Body temperature constrained to 36.0-37.0°C range
- **Calibration logic**: Varies based on raw temperature ranges

### Connection States
- **Advertising**: Device broadcasts availability
- **Connected**: Active data transmission
- **Disconnected**: Automatic re-advertising after 500ms delay

## Troubleshooting

### Common Issues

1. **Device not found**: Ensure Bluetooth is enabled and device is powered on
2. **Connection drops**: Device will automatically restart advertising
3. **Invalid heart rate**: Ensure proper finger placement on sensor
4. **Temperature seems off**: Remember this is calibrated body temperature, not ambient

### Optimal Usage
- Place device on **wrist** for best readings
- Ensure **good skin contact** with sensor
- Allow **3-5 seconds** for heart rate stabilization
- **Avoid movement** during measurement for accuracy

## Technical Notes

### Power Management
- Device runs continuously when connected
- Temperature readings available even without finger detection
- Heart rate calculation only active when finger detected

### Data Reliability
- `fingerDetected: false` when IR value < 50,000
- `validHeartRate: false` until 3+ consecutive beats detected
- Timestamp based on device uptime (resets on power cycle)

### Update Frequencies
- **Heart rate events**: Triggered by beat detection (~25ms intervals)
- **Status updates**: Every 3 seconds regardless of finger detection
- **Temperature**: Updated with every packet transmission

## Example Connection Flow

1. App scans for BLE devices
2. Finds "MirrorMind-SmartBand"
3. Connects and discovers services/characteristics
4. Subscribes to notifications
5. Receives periodic JSON data packets
6. Parses and displays biometric information
7. Handles connection state changes

This device is ready for production use and provides reliable, real-time biometric data transmission via Bluetooth Low Energy.