import SwiftUI

struct BuyCarView: View {
    @State private var cars: [CarModel] = []       // 서버에서 받아온 전체 차량 데이터
    @State private var isLoading = true            // 로딩 상태 관리
    @State private var errorMessage: String?       // 오류 메시지 관리
    @Binding var selectedTab: Int                  // ContentView에서 전달받은 탭 상태

    // 검색 조건 상태 변수들
    @State private var searchManufacturer: String = ""
    @State private var searchModel: String = ""
    @State private var searchYear: String = ""
    @State private var searchType: String = ""       // 차량 유형 (예: SUV, 세단 등)
    @State private var searchRegion: String = ""
    @State private var searchPrice: Double = 200000000 // 최대값으로 초기화 (전체 검색)

    // 검색 조건에 따라 차량 데이터를 필터링하는 계산 프로퍼티
    var filteredCars: [CarModel] {
        cars.filter { car in
            let matchesManufacturer = searchManufacturer.isEmpty ||
                car.brand.localizedCaseInsensitiveContains(searchManufacturer)
            let matchesModel = searchModel.isEmpty ||
                car.model.localizedCaseInsensitiveContains(searchModel)
            let matchesYear = searchYear.isEmpty ||
                String(car.year) == searchYear
            let matchesType = searchType.isEmpty ||
                car.type.localizedCaseInsensitiveContains(searchType)
            let matchesRegion = searchRegion.isEmpty ||
                (car.region?.localizedCaseInsensitiveContains(searchRegion) ?? false)
            let matchesPrice = (searchPrice < 200000000) ? Double(car.price) <= searchPrice : true

            return matchesManufacturer &&
                   matchesModel &&
                   matchesYear &&
                   matchesType &&
                   matchesRegion &&
                   matchesPrice
        }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                HStack {
                        Image("SimCarLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 70)
                        
                        Spacer()
                        
                    // 돋보기 아이콘 버튼: 차량 검색 화면으로 네비게이트
                    NavigationLink(destination: CarSearchView(
                        manufacturer: $searchManufacturer,
                        model: $searchModel,
                        year: $searchYear,
                        type: $searchType,
                        region: $searchRegion,
                        price: $searchPrice
                    )) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.system(size: 27, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding(.trailing, 10)
                    }

                        
                    // 하트 아이콘 버튼: 찜한 차량 목록으로 네비게이트
                    NavigationLink(destination: FavoriteCarView(selectedTab: $selectedTab)) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 27, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.purple, Color.indigo]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding(.trailing, 10)
                    }

                }
                    
                // 차량 검색 버튼: 검색 조건의 바인딩을 CarSearchView로 전달
                NavigationLink(destination: CarSearchView(
                    manufacturer: $searchManufacturer,
                    model: $searchModel,
                    year: $searchYear,
                    type: $searchType,
                    region: $searchRegion,
                    price: $searchPrice
                )) {
                    HStack {
                        Text("   어떤 차를 찾고 있나요?")
                            .font(.system(size: 22))
                            .foregroundColor(.gray)
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .font(.system(size:30, weight: .bold))
                            .foregroundColor(.purple)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 20
                            )
                    )
                    .cornerRadius(30)
                    .shadow(color: Color.blue.opacity(0.8), radius: 5, x: 0, y: 0)
                }
                .padding(5)



                // 로딩 중, 오류 발생, 또는 필터링된 차량 리스트 표시
                if isLoading {
                    ProgressView("차량 목록 불러오는 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    Text("오류: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(filteredCars) { car in
                        CarRow(car: car, selectedTab: $selectedTab)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                    .scrollIndicators(.hidden)
                }
            }
            .padding(.horizontal)
            .onAppear {
                fetchCars()  // 화면이 나타날 때 서버에서 데이터 로드
            }
        }
    }
    
    // 차량 데이터를 서버에서 받아오는 함수 (async/await 사용)
    private func fetchCars() {
        guard let url = URL(string: API.cars) else {
            errorMessage = "잘못된 URL입니다."
            isLoading = false
            return
        }
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    DispatchQueue.main.async {
                        errorMessage = "서버 오류"
                        isLoading = false
                    }
                    return
                }
                
                let decodedCars = try JSONDecoder().decode([CarModel].self, from: data)
                DispatchQueue.main.async {
                    self.cars = decodedCars.reversed()
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "네트워크 오류: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

// CarRow 뷰 추가
struct CarRow: View {
    var car: CarModel
    @Binding var selectedTab: Int

    var body: some View {
        NavigationLink(destination: DetailCarView(carId: car.id, selectedTab: $selectedTab)) {
            HStack {
                if let url = URL(string: car.fullImageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .frame(width: 130, height: 100)
                            .padding(5)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 100, height: 100)
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading) {
                    Text("\(car.brand) \(car.model)")
                        .font(.headline)
                    Text("\(car.year) · \(car.type) · \(car.region ?? "정보 없음") · \(car.price) 원")
                        .font(.subheadline)
                }
            }
        }
    }
}


//struct ContentView_Previews: PreviewProvider {
//    @StateObject static var userSettings = UserSettings()
//    static var previews: some View {
//        ContentView()
//            .environmentObject(userSettings)
//    }
//}
