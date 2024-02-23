import SwiftUI

struct SyncScreen: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "wifi")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
            
            //let name = self.viewModel.syncData.username != "" ? self.viewModel.syncData.username : "Waiting for Username"
            let name = self.viewModel.username != "" ? self.viewModel.username : "Waiting for Username"
            
            Text(name)
                .padding()
            Button(action: {
                self.viewModel.cancelSync()
            }) {
                Text("Cancel")
            }
        }.padding()
    }
}

#Preview {
    SyncScreen()
}
