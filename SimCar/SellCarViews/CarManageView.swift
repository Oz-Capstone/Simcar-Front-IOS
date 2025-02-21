import SwiftUI

struct CarManageView: View {
    var carId: Int
    @Binding var selectedTab: Int
    
    @State private var car: CarDetail?
    @State private var isFavorite: Bool = false
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    @State private var showLoginAlert: Bool = false
    @State private var showDiagnosisModal: Bool = false  // AI 진단 모달 상태 변수
    
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode

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
                VStack(alignment: .leading, spacing: 20) {
                    // 차량 이미지 영역: car.images가 있을 경우 TabView로 여러 이미지를 스와이프 가능하도록 표시
                    ZStack(alignment: .topTrailing) {
                        if let images = car.images, !images.isEmpty {
                            TabView {
                                ForEach(images) { image in
                                    if let url = URL(string: image.fullImageUrl) {
                                        AsyncImage(url: url) { img in
                                            img
                                                .resizable()
                                                .frame(height: 200)
                                                .cornerRadius(20)
                                                .clipped()
                                        } placeholder: {
                                            ProgressView()
                                                .frame(height: 200)
                                        }
                                    } else {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                    }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .frame(height: 200)
                        } else if let urlString = car.representativeImageUrl,
                                  let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .frame(height: 200)
                                    .cornerRadius(20)
                                    .clipped()
                            } placeholder: {
                                ProgressView()
                                    .frame(height: 200)
                            }
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(20)
                                .clipped()
                        }
                        
                        // 찜하기 버튼
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
                                .frame(width: 30, height: 30)
                                .foregroundColor(isFavorite ? .red : .white)
                                .padding(8)
                        }
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                    }
                    
                    Text("\(car.brand) \(car.model)")
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
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("유형: \(car.type)")
                        Text("색상: \(car.color)")
                        Text("변속기: \(car.transmission)")
                        Text("지역: \(car.region ?? "미등록")")
                        Text("연락처: \(car.contactNumber ?? "없음")")
                    }
                    .font(.subheadline)
                    
                    // AI 차량 진단 버튼
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
                        if let car = car {
                            AICarDiagnosisView(carId: car.id)
                        }
                    }
                    
                    // 차량 수정 및 제거 버튼
                    HStack(spacing: 20) {
                        NavigationLink(destination: EditCarView(selectedTab: $selectedTab, car: car, carId: car.id)) {
                            Text("차량 수정")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            deleteCar(carId: car.id)
                        }) {
                            Text("차량 제거")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("상세 보기")
        .alert(isPresented: $showLoginAlert) {
            Alert(
                title: Text("알림"),
                message: Text("로그인 후 이용해 주세요"),
                dismissButton: .default(Text("확인"), action: {
                    selectedTab = 2
                })
            )
        }
        .onAppear {
            fetchCarDetail(carId: carId)
        }
    }
    
    // MARK: - API 호출 함수들
    
    private func fetchCarDetail(carId: Int) {
        guard let url = URL(string: API.car + "\(carId)") else {
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
        guard let url = URL(string: API.members_favorites) else { return }
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
        guard let url = URL(string: API.favorites + "\(carId)") else {
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
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    isFavorite = true
                } else {
                    errorMessage = "찜하기 실패: 서버 오류"
                }
            }
        }.resume()
    }
    
    private func removeFavorite(carId: Int) {
        guard let url = URL(string: API.favorites + "\(carId)") else {
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
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    isFavorite = false
                } else {
                    errorMessage = "찜하기 취소 실패: 서버 오류"
                }
            }
        }.resume()
    }
    
    private func deleteCar(carId: Int) {
        guard let url = URL(string: API.car + "\(carId)") else {
            errorMessage = "잘못된 URL입니다."
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "차량 삭제 실패: \(error.localizedDescription)"
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    presentationMode.wrappedValue.dismiss()
                } else {
                    errorMessage = "차량 삭제 실패: 서버 오류"
                }
            }
        }.resume()
    }
}
