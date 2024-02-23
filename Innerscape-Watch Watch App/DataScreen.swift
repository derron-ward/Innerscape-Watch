import SwiftUI
import HealthKit

struct DataScreen: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "heart.fill")
                Text(self.viewModel.data[HKObjectType.quantityType(forIdentifier: .heartRate)!.identifier]!)
            }
            Button(action: {
                self.viewModel.stopSession()
            }) {
                Text("Stop")
            }
        }.padding()
    }
}

#Preview {
    DataScreen()
}
