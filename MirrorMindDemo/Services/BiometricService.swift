//
//  BiometricService.swift
//  MirrorMindDemo
//
//  Created on Phase 3 - Bluetooth Integration
//

import Foundation
import CoreBluetooth
import Combine

/// Service responsible for managing Bluetooth Low Energy communication with the MirrorMind SmartBand
class BiometricService: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var isConnected: Bool = false
    @Published var isScanning: Bool = false
    @Published var currentData: BiometricData?
    @Published var connectionState: ConnectionState = .disconnected
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var lastError: BluetoothError?
    
    // MARK: - Private Properties
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var targetCharacteristic: CBCharacteristic?
    private var dataSubject = PassthroughSubject<BiometricData, Never>()
    private var reconnectTimer: Timer?
    private let reconnectInterval: TimeInterval = 5.0
    
    // MARK: - Constants
    private let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-123456789abc")
    private let characteristicUUID = CBUUID(string: "87654321-4321-4321-4321-cba987654321")
    private let deviceName = "MirrorMind-SmartBand"
    
    // MARK: - Publishers
    var dataPublisher: AnyPublisher<BiometricData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        print("🔵 BiometricService initialized")
    }
    
    deinit {
        stopScanning()
        disconnect()
        reconnectTimer?.invalidate()
        print("🔴 BiometricService deinitialized")
    }
    
    // MARK: - Public Methods
    
    /// Start scanning for MirrorMind SmartBand devices
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            lastError = .bluetoothNotAvailable
            print("❌ Bluetooth not available for scanning")
            return
        }
        
        guard !isScanning else {
            print("⚠️ Already scanning")
            return
        }
        
        discoveredDevices.removeAll()
        isScanning = true
        connectionState = .scanning
        
        centralManager.scanForPeripherals(
            withServices: [serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
        
        print("🔍 Started scanning for SmartBand devices")
        
        // Set timeout for scanning
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            if self?.isScanning == true && self?.connectionState == .scanning {
                self?.stopScanning()
                self?.lastError = .deviceNotFound
            }
        }
    }
    
    /// Stop scanning for devices
    func stopScanning() {
        guard isScanning else { return }
        
        centralManager.stopScan()
        isScanning = false
        
        if connectionState == .scanning {
            connectionState = .disconnected
        }
        
        print("🛑 Stopped scanning")
    }
    
    /// Connect to a specific peripheral
    func connect(to peripheral: CBPeripheral) {
        stopScanning()
        
        guard centralManager.state == .poweredOn else {
            lastError = .bluetoothNotAvailable
            return
        }
        
        connectionState = .connecting
        connectedPeripheral = peripheral
        peripheral.delegate = self
        
        centralManager.connect(peripheral, options: nil)
        print("🔗 Attempting to connect to \(peripheral.name ?? "Unknown Device")")
        
        // Set connection timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) { [weak self] in
            if self?.connectionState == .connecting {
                self?.disconnect()
                self?.lastError = .connectionTimeout
            }
        }
    }
    
    /// Connect to the first discovered SmartBand device
    func connectToSmartBand() {
        if let smartBand = discoveredDevices.first(where: { $0.name == deviceName }) {
            connect(to: smartBand)
        } else if !isScanning {
            startScanning()
        }
    }
    
    /// Connect directly to known SmartBand device (for demo purposes)
    func connectToKnownSmartBand() {
        // Para demo: usar dispositivos conocidos por Core Bluetooth
        let knownPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [serviceUUID])
        
        if let knownSmartBand = knownPeripherals.first(where: { $0.name == deviceName }) {
            print("🔍 Encontrado dispositivo conocido: \(knownSmartBand.name ?? "Unknown")")
            connect(to: knownSmartBand)
            return
        }
        
        // Fallback: buscar dispositivos previamente conectados
        let retrievedPeripherals = centralManager.retrievePeripherals(withIdentifiers: [])
        for peripheral in retrievedPeripherals {
            if peripheral.name == deviceName {
                print("🔍 Reconectando a dispositivo previo: \(peripheral.name ?? "Unknown")")
                connect(to: peripheral)
                return
            }
        }
        
        // Si no encuentra dispositivos conocidos, hacer búsqueda normal
        connectToSmartBand()
    }
    
    /// Disconnect from current device
    func disconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        
        connectedPeripheral = nil
        targetCharacteristic = nil
        isConnected = false
        connectionState = .disconnected
        currentData = nil
        
        print("🔌 Disconnected from SmartBand")
    }
    
    /// Toggle connection state
    func toggleConnection() {
        if isConnected {
            disconnect()
        } else {
            connectToSmartBand()
        }
    }
    
    /// Enable automatic reconnection
    func enableAutoReconnect() {
        guard reconnectTimer == nil else { return }
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: reconnectInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if !self.isConnected && self.connectionState != .connecting && self.connectionState != .scanning {
                print("🔄 Auto-reconnect attempt...")
                self.connectToSmartBand()
            }
        }
    }
    
    /// Disable automatic reconnection
    func disableAutoReconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
}

// MARK: - CBCentralManagerDelegate
extension BiometricService: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("📡 Bluetooth state changed: \(central.state.rawValue)")
        
        switch central.state {
        case .poweredOn:
            lastError = nil
            if connectionState == .disconnected {
                // Auto-start scanning when Bluetooth becomes available
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.startScanning()
                }
            }
        case .poweredOff:
            lastError = .bluetoothPoweredOff
            disconnect()
        case .unauthorized:
            lastError = .bluetoothUnauthorized
        case .unsupported:
            lastError = .bluetoothUnsupported
        default:
            lastError = .bluetoothNotAvailable
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("🔍 Discovered device: \(peripheral.name ?? "Unknown") - RSSI: \(RSSI)")
        
        // Add to discovered devices if not already present
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredDevices.append(peripheral)
        }
        
        // Auto-connect to SmartBand if found
        if peripheral.name == deviceName {
            connect(to: peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to \(peripheral.name ?? "Unknown Device")")
        
        connectionState = .connected
        isConnected = true
        lastError = nil
        
        // Discover services
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("❌ Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
        
        lastError = .connectionFailed(error?.localizedDescription ?? "Unknown error")
        connectionState = .disconnected
        isConnected = false
        connectedPeripheral = nil
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("🔌 Disconnected from \(peripheral.name ?? "Unknown Device")")
        
        if let error = error {
            print("❌ Disconnection error: \(error.localizedDescription)")
            lastError = .connectionLost(error.localizedDescription)
        }
        
        isConnected = false
        connectionState = .disconnected
        connectedPeripheral = nil
        targetCharacteristic = nil
        currentData = nil
        
        // Attempt reconnection if auto-reconnect is enabled
        if reconnectTimer != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.connectToSmartBand()
            }
        }
    }
}

// MARK: - CBPeripheralDelegate
extension BiometricService: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("❌ Service discovery error: \(error.localizedDescription)")
            lastError = .serviceDiscoveryFailed
            return
        }
        
        guard let services = peripheral.services else {
            print("❌ No services found")
            lastError = .serviceNotFound
            return
        }
        
        print("🔍 Discovered \(services.count) services")
        
        // Find our target service
        for service in services {
            if service.uuid == serviceUUID {
                print("✅ Found SmartBand service")
                peripheral.discoverCharacteristics([characteristicUUID], for: service)
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("❌ Characteristic discovery error: \(error.localizedDescription)")
            lastError = .characteristicDiscoveryFailed
            return
        }
        
        guard let characteristics = service.characteristics else {
            print("❌ No characteristics found")
            lastError = .characteristicNotFound
            return
        }
        
        print("🔍 Discovered \(characteristics.count) characteristics")
        
        // Find our target characteristic
        for characteristic in characteristics {
            if characteristic.uuid == characteristicUUID {
                print("✅ Found SmartBand characteristic")
                targetCharacteristic = characteristic
                
                // Enable notifications
                peripheral.setNotifyValue(true, for: characteristic)
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ Notification setup error: \(error.localizedDescription)")
            lastError = .notificationSetupFailed
            return
        }
        
        if characteristic.isNotifying {
            print("✅ Notifications enabled - Ready to receive data")
            connectionState = .dataReady
        } else {
            print("⚠️ Notifications disabled")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ Data update error: \(error.localizedDescription)")
            return
        }
        
        guard let data = characteristic.value else {
            print("❌ No data received")
            return
        }
        
        parseReceivedData(data)
    }
}

// MARK: - Data Parsing
private extension BiometricService {
    
    func parseReceivedData(_ data: Data) {
        guard let jsonString = String(data: data, encoding: .utf8) else {
            print("❌ Failed to convert data to string")
            return
        }
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("❌ Failed to convert string to data")
            return
        }
        
        do {
            let biometricData = try JSONDecoder().decode(BiometricData.self, from: jsonData)
            
            DispatchQueue.main.async {
                self.currentData = biometricData
                self.dataSubject.send(biometricData)
            }
            
            // Log data for debugging
            if biometricData.fingerDetected && biometricData.validHeartRate {
                print("💓 HR: \(biometricData.heartRate) BPM, Temp: \(biometricData.formattedTemperature)")
            } else if biometricData.fingerDetected {
                print("👆 Finger detected, calculating heart rate...")
            } else {
                print("🖐️ No finger detected")
            }
            
        } catch {
            print("❌ JSON parsing error: \(error)")
            lastError = .dataParsingFailed
        }
    }
}

// MARK: - Supporting Types
extension BiometricService {
    
    enum ConnectionState: String, CaseIterable {
        case disconnected = "Disconnected"
        case scanning = "Scanning"
        case connecting = "Connecting"
        case connected = "Connected"
        case dataReady = "Receiving Data"
        
        var description: String {
            return rawValue
        }
        
        var color: String {
            switch self {
            case .disconnected: return "red"
            case .scanning: return "orange"
            case .connecting: return "yellow"
            case .connected: return "blue"
            case .dataReady: return "green"
            }
        }
    }
    
    enum BluetoothError: Error, LocalizedError {
        case bluetoothNotAvailable
        case bluetoothPoweredOff
        case bluetoothUnauthorized
        case bluetoothUnsupported
        case deviceNotFound
        case connectionTimeout
        case connectionFailed(String)
        case connectionLost(String)
        case serviceDiscoveryFailed
        case serviceNotFound
        case characteristicDiscoveryFailed
        case characteristicNotFound
        case notificationSetupFailed
        case dataParsingFailed
        
        var errorDescription: String? {
            switch self {
            case .bluetoothNotAvailable:
                return "Bluetooth is not available"
            case .bluetoothPoweredOff:
                return "Bluetooth is turned off"
            case .bluetoothUnauthorized:
                return "Bluetooth access not authorized"
            case .bluetoothUnsupported:
                return "Bluetooth is not supported on this device"
            case .deviceNotFound:
                return "SmartBand device not found"
            case .connectionTimeout:
                return "Connection timeout"
            case .connectionFailed(let message):
                return "Connection failed: \(message)"
            case .connectionLost(let message):
                return "Connection lost: \(message)"
            case .serviceDiscoveryFailed:
                return "Failed to discover services"
            case .serviceNotFound:
                return "SmartBand service not found"
            case .characteristicDiscoveryFailed:
                return "Failed to discover characteristics"
            case .characteristicNotFound:
                return "SmartBand characteristic not found"
            case .notificationSetupFailed:
                return "Failed to setup notifications"
            case .dataParsingFailed:
                return "Failed to parse received data"
            }
        }
    }
}