import SwiftUI

struct DetailCarView: View {
    var carId: Int
    @State private var car: CarDetail?
    @State private var isFavorite: Bool = false
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("차량 정보 불러오는 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = errorMessage {
                Text("오류: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else if let car = car {
                VStack(alignment: .leading) {
                    ZStack(alignment: .topTrailing) {
                        AsyncImage(url: URL(string: car.imageUrl)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(20)
                                .frame(height: 300)
                        } placeholder: {
                            ProgressView()
                        }
                        
                        Button(action: {
                            isFavorite.toggle()
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(isFavorite ? .red : .gray)
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .padding(.top, 50)
                        .padding(.trailing, 16)
                    }
                    
                    Text(car.brand + " " + car.model)
                        .font(.largeTitle)
                        .padding(.top, 10)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("연식: \(car.year)")
                        Text("키로수: \(car.mileage ?? 0) km")
                        Text("연료: \(car.fuelType ?? "정보 없음")")
                        Text("가격: \(car.price) 원")
                        Text("차량 번호: \(car.carNumber)")
                    }
                    .font(.subheadline)
                    .padding(.top, 5)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("유형: \(car.type)")
                        Text("색상: \(car.color)")
                        Text("변속기: \(car.transmission)")
                        Text("지역: \(car.region ?? "미등록")")
                        Text("연락처: \(car.contactNumber ?? "없음")")
                    }
                    .font(.subheadline)
                    .padding(.top, 5)

                    NavigationLink(destination: AICarDiagnosisView()) {
                        Text("AI 차량 진단")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.top, 10)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("상세 보기")
        .onAppear {
            fetchCarDetail(carId: carId)
        }
    }
    
    private func fetchCarDetail(carId: Int) {
        guard let url = URL(string: "http://localhost:8080/api/cars/\(carId)") else {
            errorMessage = "잘못된 URL입니다."
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "네트워크 오류: \(error.localizedDescription)"
                    isLoading = false
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    errorMessage = "서버 오류: \(httpResponse.statusCode)"
                    isLoading = false
                    return
                }

                guard let data = data else {
                    errorMessage = "데이터를 받을 수 없습니다."
                    isLoading = false
                    return
                }

                do {
                    let decodedCar = try JSONDecoder().decode(CarDetail.self, from: data)
                    self.car = decodedCar
                } catch {
                    errorMessage = "데이터 파싱 오류: \(error.localizedDescription)"
                }

                isLoading = false
            }
        }.resume()
    }
}

struct CarDetail: Identifiable, Codable {
    var id: Int
    var type: String
    var imageUrl: String
    var brand: String
    var model: String
    var year: Int
    var mileage: Int?
    var fuelType: String?
    var price: Int
    var carNumber: String
    var insuranceHistory: String?
    var inspectionHistory: String?
    var color: String
    var transmission: String
    var region: String?
    var contactNumber: String?
}
