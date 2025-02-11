import SwiftUI

struct DetailCarView: View {
    var carId: Int
    @Binding var selectedTab: Int
    
    @State private var car: CarDetail?
    @State private var isFavorite: Bool = false
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    @State private var showLoginAlert: Bool = false
    @State private var showDiagnosisModal: Bool = false  // AI 진단 모달을 위한 상태 변수
    
    @EnvironmentObject var userSettings: UserSettings

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
                            if userSettings.isLoggedIn {
                                if isFavorite {
                                    removeFavorite(carId: car.id)
                                } else {
                                    addFavorite(carId: car.id)
                                }
                            } else {
                                showLoginAlert = true
                            }
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
                    
                    // AI 차량 진단 버튼: 버튼을 눌러 모달을 띄움
                    Button(action: {
                        showDiagnosisModal = true
                    }) {
                        Text("AI 차량 진단")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.top, 10)
                    }
                    .sheet(isPresented: $showDiagnosisModal) {
                        // 모달로 AICarDiagnosisView를 띄움 (car.id 사용)
                        if let car = car {
                            AICarDiagnosisView(carId: car.id)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("상세 보기")
        .alert(isPresented: $showLoginAlert) {
            Alert(title: Text("알림"),
                  message: Text("로그인 후 이용해 주세요"),
                  dismissButton: .default(Text("확인"), action: {
                    selectedTab = 2
                  }))
        }
        .onAppear {
            fetchCarDetail(carId: carId)
        }
    }
    
    // 이하 fetchCarDetail, fetchFavoriteStatus, addFavorite, removeFavorite 함수는 그대로 유지
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
                if let httpResponse = response as? HTTPURLResponse,
                   !(200...299).contains(httpResponse.statusCode) {
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
                    if userSettings.isLoggedIn {
                        fetchFavoriteStatus()
                    }
                } catch {
                    errorMessage = "데이터 파싱 오류: \(error.localizedDescription)"
                }
                isLoading = false
            }
        }.resume()
    }
    
    private func fetchFavoriteStatus() {
        guard let url = URL(string: "http://localhost:8080/api/members/favorites") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let favoritesList = try JSONDecoder().decode([CarModel].self, from: data)
                        if let currentCar = self.car {
                            self.isFavorite = favoritesList.contains(where: { $0.id == currentCar.id })
                        }
                    } catch { }
                }
            }
        }.resume()
    }
    
    private func addFavorite(carId: Int) {
        guard let url = URL(string: "http://localhost:8080/api/favorites/\(carId)") else {
            errorMessage = "잘못된 URL입니다."
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "찜하기 실패: \(error.localizedDescription)"
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    isFavorite = true
                } else {
                    errorMessage = "찜하기 실패: 서버 오류"
                }
            }
        }.resume()
    }
    
    private func removeFavorite(carId: Int) {
        guard let url = URL(string: "http://localhost:8080/api/favorites/\(carId)") else {
            errorMessage = "잘못된 URL입니다."
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "찜하기 취소 실패: \(error.localizedDescription)"
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    isFavorite = false
                } else {
                    errorMessage = "찜하기 취소 실패: 서버 오류"
                }
            }
        }.resume()
    }
}
