import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var userSettings: UserSettings
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @Binding var selectedTab: Int  // ContentView에서 전달받은 바텀 탭 상태

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if userSettings.isLoggedIn {
                    // 로그인된 상태
                    Text("마이페이지")
                        .font(.largeTitle)
                        .bold()
                    
                    VStack(spacing: 20) {
                        // 찜한 차량 조회
                        NavigationLink(destination: FavoriteCarView(selectedTab: $selectedTab)) {
                            gradientButtonLabel("찜한 차량 조회")
                        }
                        .padding(.top)
                        .padding(.horizontal)

                        // 회원 정보 수정
                        NavigationLink(destination: EditProfileView()) {
                            gradientButtonLabel("회원 정보 수정")
                        }
                        .padding(.horizontal)

                        // 회원 정보 조회
                        NavigationLink(destination: ProfileView()) {
                            gradientButtonLabel("회원 정보 조회")
                        }
                        .padding(.horizontal)

                        // 회원 탈퇴
                        NavigationLink(destination: DeleteAccountView()) {
                            gradientButtonLabel("회원 탈퇴")
                        }
                        .padding(.horizontal)

                        // 로그아웃 (빨간색 계열 그라데이션 예시)
                        Button(action: logout) {
                            gradientButtonLabel("로그아웃",
                                                colors: [Color.red, Color.orange])
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 25)) // 둥근 테두리 적용
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding()
                    
                } else {
                    // 로그인되지 않은 상태
                    Text("SIM Car")
                        .font(.largeTitle)
                        .bold()
                    
                    VStack(spacing: 20) {
                        TextField("이메일", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding(.top)
                            .padding(.horizontal)
                        
                        SecureField("비밀번호", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        // 로그인 버튼
                        Button(action: login) {
                            gradientButtonLabel("로그인")
                        }
                        .padding(.horizontal)
                        
                        // 회원가입 버튼
                        NavigationLink(destination: SignUpView()) {
                            gradientButtonLabel("회원가입")
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding()
                }
            }
            .padding()
            .overlay(isLoading ? ProgressView() : nil)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("알림"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("확인")))
            }
        }
    }
    
    // MARK: - 공용 그라데이션 버튼 라벨
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
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.gray.opacity(0.8), radius: 5, x: 0, y: 0)
    }
    
    // MARK: - 로그인
    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "모든 필드를 입력하세요."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: API.login) else {
            errorMessage = "잘못된 URL입니다."
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            errorMessage = "데이터 변환 오류"
            isLoading = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "로그인 실패: \(error.localizedDescription)"
                }
                return
            }
            
            if let data = data, let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        userSettings.isLoggedIn = true
                        alertMessage = "로그인 성공했습니다!"
                        showAlert = true
                    }
                } else {
                    DispatchQueue.main.async {
                        errorMessage = "로그인 실패"
                    }
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - 로그아웃
    private func logout() {
        guard let url = URL(string: API.logout) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    userSettings.isLoggedIn = false
                    alertMessage = "로그아웃이 완료되었습니다."
                    showAlert = true
                }
            }
        }
        
        task.resume()
    }
}


//struct ContentView_Previews: PreviewProvider {
//    @StateObject static var userSettings = UserSettings()
//    static var previews: some View {
//        ContentView()
//            .environmentObject(userSettings)
//    }
//}
