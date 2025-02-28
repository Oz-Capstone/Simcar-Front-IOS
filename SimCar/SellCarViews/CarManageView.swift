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
                    // 차량 이미지 영역
                    ZStack(alignment: .topTrailing) {
                        if let images = car.images, !images.isEmpty {
                            TabView {
                                ForEach(images) { image in
                                    if let url = URL(string: image.fullImageUrl) {
                                        AsyncImage(url: url) { img in
                                            img
                                                .resizable()
                                                .frame(height: 230)
                                                .cornerRadius(20)
                                                .clipped()
                                        } placeholder: {
                                            ProgressView()
                                                .frame(height: 230)
                                        }
                                    } else {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 230)
                                    }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .frame(height: 230)
                        } else if let urlString = car.representativeImageUrl,
                                  let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .frame(height: 230)
                                    .cornerRadius(20)
                                    .clipped()
                            } placeholder: {
                                ProgressView()
                                    .frame(height: 230)
                            }
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 230)
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
                        .buttonStyle(PressableButtonStyle())
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                    }
                    
                    // 제조사와 모델명: 색상 #9575CD 적용
                    Text("\(car.brand) \(car.model)")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color(hex: "#9575CD"))
                        .padding(.leading, 8)
                    
                    // 차량 정보 표시
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("연식:")
                                .bold()
                            Spacer()
                            Text("\(car.year)")
                        }
                        HStack {
                            Text("키로수:")
                                .bold()
                            Spacer()
                            Text("\(car.mileage ?? 0) km")
                        }
                        HStack {
                            Text("연료:")
                                .bold()
                            Spacer()
                            Text(car.fuelType ?? "정보 없음")
                        }
                        HStack {
                            Text("가격:")
                                .bold()
                            Spacer()
                            Text("\(car.price) 원")
                        }
                        HStack {
                            Text("차량 번호:")
                                .bold()
                            Spacer()
                            Text(car.carNumber)
                        }
                        HStack {
                            Text("유형:")
                                .bold()
                            Spacer()
                            Text(car.type)
                        }
                        HStack {
                            Text("색상:")
                                .bold()
                            Spacer()
                            Text(car.color)
                        }
                        HStack {
                            Text("변속기:")
                                .bold()
                            Spacer()
                            Text(car.transmission)
                        }
                        HStack {
                            Text("지역:")
                                .bold()
                            Spacer()
                            Text(car.region ?? "미등록")
                        }
                        HStack {
                            Text("연락처:")
                                .bold()
                            Spacer()
                            Text(car.contactNumber ?? "없음")
                        }
                    }
                    .font(.system(size: 18))
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 0)
                    
                    // AI 차량 진단 버튼
                    Button(action: {
                        showDiagnosisModal = true
                    }) {
                        gradientButtonLabel("AI 차량 진단")
                    }
                    .buttonStyle(PressableButtonStyle())
                    .sheet(isPresented: $showDiagnosisModal) {
                        AICarDiagnosisView(carId: car.id)
                    }


                    
                    // 차량 수정 및 삭제 버튼
                    HStack(spacing: 20) {
                        NavigationLink(destination: EditCarView(selectedTab: $selectedTab, car: car, carId: car.id)) {
                            Text("차량 수정")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.orange, Color.yellow]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.orange.opacity(0.8), radius: 5, x: 0, y: 0)
                        }
                        .buttonStyle(PressableButtonStyle())
                        
                        Button(action: {
                            deleteCar(carId: car.id)
                        }) {
                            Text("차량 제거")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red, Color.pink]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.red.opacity(0.8), radius: 5, x: 0, y: 0)
                        }
                        .buttonStyle(PressableButtonStyle())
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
    
    // MARK: - 공용 그라데이션 버튼 라벨 (기존 스타일)
    private func gradientButtonLabel(_ title: String,
                                     colors: [Color] = [Color.blue, Color.purple]) -> some View {
        Text(title)
            .font(.title2)
            .bold()
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.gray.opacity(0.8), radius: 5, x: 0, y: 0)
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
                    } catch {
                        // 오류 처리 생략
                    }
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
        URLSession.shared.dataTask(with: request) { data, response, error in
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

