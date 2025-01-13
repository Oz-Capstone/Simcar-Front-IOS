import SwiftUI

struct SellCarView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "star")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("내 차 팔기")
                
                NavigationLink(destination: RegistrationCarView()) {
                    Text("차량 등록")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("내 차 팔기")
        }
    }
}

