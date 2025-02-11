import SwiftUI

struct CarModel: Identifiable, Codable {
    var id: Int
    var type: String
    var price: Int
    var brand: String
    var model: String
    var year: Int
    var imageUrl: String
    var region: String?      // 지역은 옵셔널
    var mileage: Int?        // 차량의 키로수는 옵셔널
    var fuelType: String?    // 연료 타입은 옵셔널
    var createdAt: String    // 생성일 (예: "2025-01-25T17:49:35.446236")
}

struct BuyCarView: View {
    @State private var cars: [CarModel] = []       // 서버에서 가져온 데이터 저장
    @State private var isLoading = true            // 로딩 상태 관리
    @State private var errorMessage: String?       // 오류 메시지 관리
    @Binding var selectedTab: Int                  // ContentView에서 전달받은 바텀 탭 상태

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("SIM Car")
                    .font(.largeTitle)
                    .bold()
                
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
                
                // 데이터 로딩 중이면 ProgressView 표시
                if isLoading {
                    ProgressView("차량 목록 불러오는 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    // 오류 발생 시 오류 메시지 표시
                    Text("오류: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // 차량 리스트 표시
                    List(cars) { car in
                        // CarRow에 selectedTab 바인딩 전달
                        CarRow(car: car, selectedTab: $selectedTab)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .padding(.horizontal)
            .onAppear {
                fetchCars() // 화면이 나타날 때 데이터 로드
            }
        }
    }
    
    // 🚀 서버에서 차량 목록을 가져오는 함수
    private func fetchCars() {
        guard let url = URL(string: "http://localhost:8080/api/cars") else {
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
                    let decodedCars = try JSONDecoder().decode([CarModel].self, from: data)
                    // 최신순으로 표시하기 위해 배열을 뒤집음
                    self.cars = decodedCars.reversed()
                } catch {
                    errorMessage = "데이터 파싱 오류: \(error.localizedDescription)"
                }
                
                isLoading = false
            }
        }.resume()
    }
}

struct CarRow: View {
    var car: CarModel
    @Binding var selectedTab: Int  // ContentView에서 전달받은 바인딩

    var body: some View {
        // DetailCarView에도 selectedTab 바인딩을 전달해야 함
        NavigationLink(destination: DetailCarView(carId: car.id, selectedTab: $selectedTab)) {
            HStack {
                AsyncImage(url: URL(string: car.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .frame(width: 100, height: 100)
                } placeholder: {
                    ProgressView()
                }
                
                VStack(alignment: .leading) {
                    Text(car.brand + " " + car.model)
                        .font(.headline)

                    Text("\(car.year) · \(car.type) · \(car.region ?? "정보 없음") · \(car.price) 원")
                        .font(.subheadline)
                }
            }
        }
    }
}
