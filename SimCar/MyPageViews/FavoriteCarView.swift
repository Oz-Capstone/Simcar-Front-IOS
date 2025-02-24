import SwiftUI

struct FavoriteCarView: View {
    @State private var favorites: [CarModel] = []     // 서버에서 가져온 찜한 차량 목록 저장
    @State private var isLoading = true               // 로딩 상태 관리
    @State private var errorMessage: String?          // 오류 메시지 관리
    @Binding var selectedTab: Int                     // ContentView에서 전달받은 탭 상태

    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer()
                        Text("찜한 차량 조회")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color(hex: "#9575CD"))
                            .padding()
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 400, height: 2) // 원하는 두께와 너비로 조정
                        Spacer()
                    }

                    
                    // 콘텐츠 영역
                    if isLoading {
                        ProgressView("찜한 차량 목록 불러오는 중...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let errorMessage = errorMessage {
                        Text("오류: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    } else if favorites.isEmpty {
                        Text("찜한 차량이 없습니다")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(favorites) { car in
                            NavigationLink(destination: DetailCarView(carId: car.id, selectedTab: $selectedTab)) {
                                HStack {
                                    Spacer()
                                    CarRow(car: car, selectedTab: $selectedTab)
                                    Spacer()
                                }
                            }
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(PlainListStyle())
                        .scrollIndicators(.hidden)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchFavorites()
            }
        }
    }
    
    /// 찜한 차량 목록을 서버에서 가져오는 함수
    private func fetchFavorites() {
        guard let url = URL(string: API.members_favorites) else {
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
                    let decodedFavorites = try JSONDecoder().decode([CarModel].self, from: data)
                    // 최신순으로 표시하려면 배열을 뒤집습니다.
                    self.favorites = decodedFavorites.reversed()
                } catch {
                    errorMessage = "데이터 파싱 오류: \(error.localizedDescription)"
                }
                
                isLoading = false
            }
        }.resume()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    @StateObject static var userSettings = UserSettings()
//    static var previews: some View {
//        ContentView()
//            .environmentObject(userSettings)
//    }
//}
