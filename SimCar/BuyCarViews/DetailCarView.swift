import SwiftUI

struct DetailCarView: View {
    var car: Car
    @State private var isFavorite: Bool = false // 하트 상태를 저장하는 변수
    
    var body: some View {
        ScrollView { // ScrollView 추가
            VStack(alignment: .leading) {
                ZStack(alignment: .topTrailing) { // ZStack을 사용하여 하트를 사진 위에 배치
                    AsyncImage(url: URL(string: car.imageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(20) // 모서리 둥글게
                            .frame(height: 300)
                    } placeholder: {
                        ProgressView() // 로딩 중 표시
                    }
                    
                    // 하트 모양 버튼
                    Button(action: {
                        isFavorite.toggle() // 하트 상태 토글
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart") // 상태에 따라 하트 모양 변경
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(isFavorite ? .red : .gray) // 색상 변경
                            .padding() // 버튼 주변 여백
                            .background(Color.white.opacity(0.7)) // 반투명 배경
                            .clipShape(Circle()) // 원형으로 만들기
                    }
                    .padding(.top, 50) // 하트 버튼의 탑 마진 추가
                    .padding(.trailing, 16) // 오른쪽 마진 추가
                }
                
                // 차량 정보 표시
                Text(car.brand + " " + car.model)
                    .font(.largeTitle)
                    .padding(.top, 10)
                
                // 첫 번째 그룹: 연식, 키로수, 연료, 가격, 차량 번호
                VStack(alignment: .leading, spacing: 5) {
                    Text("연식: \(car.year)")
                    Text("키로수: \(car.mileage) km")
                    Text("연료: \(car.fuelType)")
                    Text("가격: \(car.price) 원")
                    Text("차량 번호: \(car.carNumber)")
                }
                .font(.subheadline)
                .padding(.top, 5)

                // 두 번째 그룹: 색상, 변속기, 지역, 연락처
                VStack(alignment: .leading, spacing: 5) {
                    Text("유형: \(car.type)")
                    Text("색상: \(car.color)")
                    Text("변속기: \(car.transmission)")
                    Text("지역: \(car.region)")
                    Text("연락처: \(car.contactNumber)")
                }
                .font(.subheadline)
                .padding(.top, 5)

                NavigationLink(destination: AICarDiagnosisView()) {
                    Text("AI 차량 진단")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top, 10) // 버튼의 상단 여백 추가
                }
            }
            .padding()
        }
        .navigationTitle("상세 보기")
    }
}
