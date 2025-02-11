import SwiftUI

struct MySellCarView: View {
    @State private var cars: [CarModel] = []       // 서버에서 가져온 본인 등록 차량 데이터 저장
    @State private var isLoading = true            // 로딩 상태 관리
    @State private var errorMessage: String?       // 오류 메시지 관리
    @Binding var selectedTab: Int                  // ContentView에서 전달받은 탭 상태
    
    init(selectedTab: Binding<Int>) {
        _selectedTab = selectedTab
        UITableView.appearance().tableHeaderView = UIView(frame: .zero)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
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
                        NavigationLink(destination: CarManageView(carId: car.id, selectedTab: $selectedTab)) {
                            CarRow(car: car, selectedTab: $selectedTab)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .padding(.horizontal)
            .navigationTitle("내가 등록한 차량")
            .onAppear {
                fetchMySellCars()
            }
            .navigationBarHidden(true)
        }
    }
    
    /// 본인이 등록한 차량 목록을 서버에서 가져오는 함수
    private func fetchMySellCars() {
        guard let url = URL(string: "http://localhost:8080/api/members/sales") else {
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
                    // 최신순으로 표시하려면 배열을 뒤집습니다.
                    self.cars = decodedCars.reversed()
                } catch {
                    errorMessage = "데이터 파싱 오류: \(error.localizedDescription)"
                }
                
                isLoading = false
            }
        }.resume()
    }
}
