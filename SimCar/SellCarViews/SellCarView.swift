import SwiftUI

struct SellCarView: View {
    @EnvironmentObject var userSettings: UserSettings
    @Binding var selectedTab: Int // ContentView에서 전달받은 탭 상태
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToRegistration: Bool = false // 차량 등록 화면으로의 네비게이션 상태 변수
    @State private var navigateToMySellCar: Bool = false // 나의 판매 차량 화면으로의 네비게이션 상태 변수

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                Text("차량을 판매하세요!")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color(hex: "#9575CD"))
//                    .padding(.leading, 25)

                
                // 차량 등록 버튼
                Button(action: {
                    if userSettings.isLoggedIn {
                        navigateToRegistration = true
                    } else {
                        alertMessage = "로그인 후 차량을 등록할 수 있습니다."
                        showAlert = true
                    }
                }) {
                    Text("판매 차량 등록")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 300, height: 200)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(10)
                        .shadow(color: Color.blue.opacity(0.8), radius: 5, x: 0, y: 0)
                }
                .padding(5)

                // 구분선 추가
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 320, height: 10) // 원하는 두께와 너비로 조정
                    .cornerRadius(3)
                    

                
                
                
                // 내가 판매중인 차량 버튼
                Button(action: {
                    if userSettings.isLoggedIn {
                        navigateToMySellCar = true
                    } else {
                        alertMessage = "로그인 후 이용해주세요."
                        showAlert = true
                    }
                }) {
                    Text("판매중인 차량 조회")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 300, height: 200)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.indigo]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(10)
                        .shadow(color: Color.blue.opacity(0.8), radius: 5, x: 0, y: 0)
                }
                .padding(5)
                
                //빈 NavigationLink들을 이용하여 프로그래밍 방식의 네비게이션 구현
               NavigationLink(
                   destination: RegistrationCarView(),
                   isActive: $navigateToRegistration
               ) {
                   EmptyView()
               }
                
                NavigationLink(
                    destination: MySellCarView(selectedTab: $selectedTab),
                    isActive: $navigateToMySellCar
                ) {
                    EmptyView()
                }
                
            }
            .padding()
            // 네비게이션 타이틀 제거: .navigationTitle("내 차 팔기")를 삭제하거나 빈 문자열로 설정
            //.navigationTitle("차량을 판매하세요!")
            // 혹은 전체 네비게이션 바를 숨기려면:
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(""),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("확인"), action: {
                        // 확인 버튼 클릭 시 MyPageView로 이동 (탭 전환)
                        selectedTab = 2
                    })
                )
            }
        }
    }
}

struct ExtendedDiagonal: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // 예: 왼쪽 아래 → 오른쪽 위 → 오른쪽 아래 순으로 삼각형을 그립니다.
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}


//struct ContentView_Previews: PreviewProvider {
//    @StateObject static var userSettings = UserSettings()
//    static var previews: some View {
//        ContentView()
//            .environmentObject(userSettings)
//    }
//}
