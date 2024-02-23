import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject var viewModel = ViewModel([
            HKDataType(objectType:
                        HKObjectType.quantityType(forIdentifier: .heartRate)!,
                       unitType: HKUnit(from: "count/min")),
            HKDataType(objectType:
                       HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
                      unitType: HKUnit(from: "degC")),
            HKDataType(objectType:
                       HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                      unitType: HKUnit.percent()),
            HKDataType(objectType:
                       HKObjectType.quantityType(forIdentifier: .vo2Max)!,
                      unitType: HKUnit(from: "ml/kg*min")),
            HKDataType(objectType:
                       HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!,
                      unitType: HKUnit(from: "dBASPL")),
            HKDataType(objectType:
                       HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                      unitType: HKUnit(from: "count/min")),
            HKDataType(objectType:
                       HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
                      unitType: HKUnit(from: "count/min")),
            HKDataType(objectType:
                       HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                      unitType: HKUnit.minute()),
            HKDataType(objectType:
                       HKObjectType.quantityType(forIdentifier: .atrialFibrillationBurden)!,
                      unitType: HKUnit.percent()) 
        ])
    
    var body: some View {
        switch viewModel.screen {
        case .Home:
            HomeScreen()
                .environmentObject(viewModel)
        case .Sync:
            SyncScreen()
                .environmentObject(viewModel)
        case .Data:
            DataScreen()
                .environmentObject(viewModel)
        }
    }
}

#Preview {
    ContentView()
}
