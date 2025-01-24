import SwiftUI

struct DetailCarView: View {
    var car: Car
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: car.imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } placeholder: {
                ProgressView() // 로딩 중 표시
            }
            
            Text(car.manufacturer + " " + car.model)
                .font(.largeTitle)
                .padding(.top, 10)
            
            Text("연식: \(car.year) | 키로수: \(car.mileage) km | 연료: \(car.fuel) | 가격: \(car.price) 원")
                .font(.subheadline)
                .padding(.top, 5)
            
            NavigationLink(destination: AICarDiagnosisView()) {
                Text("AI 차량 진단")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .navigationTitle("상세 보기")
    }
}
