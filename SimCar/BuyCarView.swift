import SwiftUI

struct BuyCarView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) { // VStack의 정렬을 왼쪽으로 설정
                // 차량 검색 버튼
                NavigationLink(destination: CarSearchView()) {
                    Text("차량 검색")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)

                // 차량 리스트
                List(carList) { car in
                    NavigationLink(destination: DetailCarView(car: car)) {
                        CarRow(car: car)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("내 차 사기")
            .padding(.horizontal) // 좌우 여백 추가 (필요에 따라 조정)
        }
    }
}

struct CarRow: View {
    var car: Car
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: car.imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()
//                    .frame(width: 100, height: 100)
                    .cornerRadius(10) // 모서리 둥글게 설정
            } placeholder: {
                ProgressView() // 로딩 중 표시
            }
            
            VStack(alignment: .leading) {
                Text(car.brand + " " + car.model) // 제조사와 차량 이름
                    .font(.headline)
                
                let yearString = String(car.year)
                
                // 정보 표시: 연식, 키로수, 연료, 지역, 가격
                Text("\(yearString) · \(car.mileage) km · \(car.fuelType) · \(car.region) · \(car.price) 원")
                    .font(.subheadline)
            }
        }
    }
}

