import SwiftUI

struct BuyCarView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("내 차 사기")
                
                NavigationLink(destination: DetailCarView()) {
                    Text("차량 세부 정보로 이동")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                NavigationLink(destination: AICarDiagnosisView()) {
                    Text("AI 차량 진단")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("내 차 사기")
        }
    }
}

