//
//  ContentView.swift
//  BeaconEmitter2
//
//  Created by Marco Alonso on 04/10/24.
//

import SwiftUI
import CoreBluetooth
import CoreLocation

struct ContentView: View {
    @StateObject private var beaconClass = BeaconClass()
    
    var body: some View {
        VStack {
            Image("ble")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            Text("This is an BLE Simulator")
                .font(.title)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}


class BeaconClass: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    private var peripheralManager: CBPeripheralManager?
    private let region: CLBeaconRegion
    var centralManager: CBCentralManager!
    
    @Published var discoveredBeacons: [CBPeripheral] = []
    
    override init() {
        let uuid = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!
        region = CLBeaconRegion()
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func startAdvertising() {
        guard let peripheralManager = peripheralManager else {
            return // Ensure peripheralManager is not nil
        }
        if peripheralManager.state == .poweredOn {
            let peripheralData = region.peripheralData(withMeasuredPower: nil) as! [String: Any]
            let additionalData: [String: Any] = [CBAdvertisementDataLocalNameKey: "iPhone BLE", CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: "180D" )]]
            let mergedData = peripheralData.merging(additionalData) { (_, new) in new }
            peripheralManager.startAdvertising(mergedData)
            print ("advertising started")
        } else {
            print ("Peripheral manager is not in powered-on state")
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
            
        case .unknown:
            print("Debug: unknown")
        case .resetting:
            print("Debug: resetting")
        case .unsupported:
            print("Debug: unsupported")
        case .unauthorized:
            print("Debug: unauthorized")
        case .poweredOff:
            peripheral.stopAdvertising()
        case .poweredOn:
            startAdvertising()
        @unknown default:
            print("Debug: default")
        }
    }
}
