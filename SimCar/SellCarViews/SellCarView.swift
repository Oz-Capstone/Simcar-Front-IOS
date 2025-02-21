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
                // 빈 NavigationLink들을 이용하여 프로그래밍 방식의 네비게이션 구현
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
                
                Button(action: {
                    if userSettings.isLoggedIn {
                        navigateToRegistration = true
                    } else {
                        alertMessage = "로그인 후 차량을 등록할 수 있습니다."
                        showAlert = true
                    }
                }) {
                    Text("차량 등록")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    if userSettings.isLoggedIn {
                        navigateToMySellCar = true
                    } else {
                        alertMessage = "로그인 후 이용해주세요."
                        showAlert = true
                    }
                }) {
                    Text("내가 판매중인 차량")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .navigationTitle("내 차 팔기")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("알림"),
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
