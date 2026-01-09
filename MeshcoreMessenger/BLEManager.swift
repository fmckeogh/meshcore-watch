//
//  BLEManager.swift
//  MeshcoreMessenger
//

import Combine
import CoreBluetooth
import Foundation

extension Notification.Name {
    static let bleDataReceived = Notification.Name("bleDataReceived")
    static let bleReady = Notification.Name("bleReady")
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate,
    CBPeripheralDelegate
{
    static let shared = BLEManager()

    @Published var isConnected = false
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var userDidManuallyDisconnect = false

    private var centralManager: CBCentralManager!
    private var meshcorePeripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?

    private var isManualDisconnect = false
    private var isAutoReconnecting = false

    private let lastPeripheralIdentifierKey =
        "lastConnectedPeripheralIdentifier"

    // https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/libraries/bluetooth/services/nus.html
    let uartServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")

    // Write data to the RX Characteristic to send it to the UART interface.
    let rxCharacteristicUUID = CBUUID(
        string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    )

    // Enable notifications for the TX Characteristic to receive data from the application. The application transmits all data that is received over UART as notifications.
    let txCharacteristicUUID = CBUUID(
        string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    )

    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Public Control Methods

    func startScan() {
        discoveredPeripherals.removeAll()
     
        let hasLastPeripheralIdentifier = UserDefaults.standard.string(forKey: lastPeripheralIdentifierKey) != nil
        isAutoReconnecting = hasLastPeripheralIdentifier && !userDidManuallyDisconnect
        
        Logger.shared.log("BLEManager: starting scan (is auto reconnecting: \(isAutoReconnecting))")
        
        centralManager.scanForPeripherals(
            withServices: [uartServiceUUID],
            options: nil
        )
    }

    func stopScan() {
        Logger.shared.log("BLEManager: Stopping scan.")
        centralManager.stopScan()
    }

    func connect(to peripheral: CBPeripheral) {
        Logger.shared.log(
            "BLEManager: Attempting to connect to \(peripheral.name ?? "Unknown")"
        )
        stopScan()
        self.meshcorePeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }

    func disconnect() {
        guard let peripheral = meshcorePeripheral else { return }
        Logger.shared.log("BLEManager: User initiated disconnect.")
        isManualDisconnect = true
        isAutoReconnecting = false
        centralManager.cancelPeripheralConnection(peripheral)
    }

    func writeData(_ data: Data) {
        guard let peripheral = self.meshcorePeripheral,
            let characteristic = self.writeCharacteristic
        else {
            Logger.shared.log("BLEManager: Not ready to send data.")
            return
        }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    // MARK: - Delegate Methods
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
       
        switch central.state {
        case .poweredOn:
            Logger.shared.log("BLEManager: bluetooth powered on")
            startScan()
            
        case .poweredOff:
            Logger.shared.log("BLEManager: bluetooth powered off")
            
        case .unauthorized:
            Logger.shared.log("BLEManager: bluetooth unauthorized")
            
        case .unsupported:
            Logger.shared.log("BLEManager: bluetooth unsupported")
            
        case .resetting:
            Logger.shared.log("BLEManager: bluetooth resetting")
            
        case .unknown:
            Logger.shared.log("BLEManager: bluetooth unknown")
            
        default:
            Logger.shared.log("BLEManager: default case undefined state")
        }
       
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {

        if !discoveredPeripherals.contains(where: {
            $0.identifier == peripheral.identifier
        }) {
            DispatchQueue.main.async {
                self.discoveredPeripherals.append(peripheral)
            }
        }

        if isAutoReconnecting {
            guard
                let uuidString = UserDefaults.standard.string(
                    forKey: lastPeripheralIdentifierKey
                )
            else { return }
            if peripheral.identifier.uuidString == uuidString {
                Logger.shared.log(
                    "BLEManager: Found last known device via scan. Connecting..."
                )
                connect(to: peripheral)
            }
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        Logger.shared.log("BLEManager: Connected to Node.")
        isAutoReconnecting = false

        UserDefaults.standard.set(
            peripheral.identifier.uuidString,
            forKey: lastPeripheralIdentifierKey
        )

        DispatchQueue.main.async { self.isConnected = true }
        peripheral.delegate = self
        peripheral.discoverServices([uartServiceUUID])
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        Logger.shared.log(
            "BLEManager: Failed to connect. Error: \(error?.localizedDescription ?? "Unknown")"
        )

        isAutoReconnecting = false
        startScan()
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        Logger.shared.log("BLEManager: Disconnected from Node.")
        self.meshcorePeripheral = nil
        self.writeCharacteristic = nil

        DispatchQueue.main.async {
            self.isConnected = false
            if self.isManualDisconnect {
                self.userDidManuallyDisconnect = true
                self.isManualDisconnect = false
            } else {
                self.startScan()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
        Logger.shared.log("BLEManager: didUpdateANCSAuthorizationFor")
    }
    
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        Logger.shared.log("BLEManager: connection event")
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        guard let services = peripheral.services else { return }
        for service in services where service.uuid == uartServiceUUID {
            peripheral.discoverCharacteristics(
                [rxCharacteristicUUID, txCharacteristicUUID],
                for: service
            )
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        guard let characteristics = service.characteristics else { return }
        var foundWrite = false
        var foundNotify = false

        for characteristic in characteristics {
            if characteristic.uuid == rxCharacteristicUUID {
                self.writeCharacteristic = characteristic
                foundWrite = true
            } else if characteristic.uuid == txCharacteristicUUID {
                peripheral.setNotifyValue(true, for: characteristic)
                foundNotify = true
            }
        }

        if foundWrite && foundNotify {
            Logger.shared.log(
                "BLEManager: Ready to communicate. Posting notification."
            )
            NotificationCenter.default.post(name: .bleReady, object: nil)
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        guard let data = characteristic.value else { return }
        NotificationCenter.default.post(name: .bleDataReceived, object: data)
    }
}
