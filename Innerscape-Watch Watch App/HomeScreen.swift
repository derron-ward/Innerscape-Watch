import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Text("Innerscape")
                .bold()
                .padding()
            Button(action: {
                self.viewModel.startSession()
            }) {
                Text("Start")
            }
        }.padding()
    }
}

#Preview {
    HomeScreen()
}
