import SwiftUI

struct SellCarView: View {
    @EnvironmentObject var userSettings: UserSettings
    @Binding var selectedTab: Int // binding으로 selectedTab을 받아옴
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToRegistration: Bool = false // 차량 등록 화면으로의 네비게이션 상태 변수
    @State private var navigateToMySellCar: Bool = false // 나의 판매 차량 화면으로의 네비게이션 상태 변수
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: RegistrationCarView(), isActive: $navigateToRegistration) {
                    Button(action: {
                        if userSettings.isLoggedIn {
                            // 로그인된 경우, 차량 등록 화면으로 이동
                            navigateToRegistration = true
                        } else {
                            // 로그인되지 않은 경우, 알림을 띄움
                            alertMessage = "로그인 후 차량을 등록할 수 있습니다."
                            showAlert = true
                        }
                    }) {
                        Text("차량 등록")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인"), action: {
                        // 확인 버튼 클릭 시 MyPageView로 이동
                        selectedTab = 2 // MyPageView로 이동
                    }))
                }
                
                NavigationLink(destination: MySellCarView(selectedTab: $selectedTab), isActive: $navigateToMySellCar) {
                    Button(action: {
                        if userSettings.isLoggedIn {
                            // 로그인된 경우, 차량 등록 화면으로 이동
                            navigateToMySellCar = true
                        } else {
                            // 로그인되지 않은 경우, 알림을 띄움
                            alertMessage = "로그인 후 이용해주세요."
                            showAlert = true
                        }
                    }) {
                        Text("내가 판매중인 차량")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인"), action: {
                        // 확인 버튼 클릭 시 MyPageView로 이동
                        selectedTab = 2 // MyPageView로 이동
                    }))
                }
                
            }
            .navigationTitle("내 차 팔기")
        }
    }
}
