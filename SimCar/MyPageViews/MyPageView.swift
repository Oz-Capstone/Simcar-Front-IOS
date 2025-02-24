import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var userSettings: UserSettings
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
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
                        .foregroundColor(Color(hex: "#9575CD"))
                    
                    VStack(spacing: 20) {
                        // 찜한 차량 조회
                        NavigationLink(destination: FavoriteCarView(selectedTab: $selectedTab)) {
                            gradientButtonLabel("찜한 차량 조회")
                        }
                        .padding(.top)
                        .padding(.horizontal)

                        // 회원 정보 수정
                        NavigationLink(destination: EditProfileView()) {
                            gradientButtonLabel("회원 정보 수정",
                                                colors: [Color.purple, Color.pink])
                        }
                        .padding(.horizontal)

                        // 회원 정보 조회
                        NavigationLink(destination: ProfileView()) {
                            gradientButtonLabel("회원 정보 조회",
                                                colors: [Color.purple, Color.pink])
                        }
                        .padding(.horizontal)

                        // 회원 탈퇴
                        NavigationLink(destination: DeleteAccountView()) {
                            gradientButtonLabel("회원 탈퇴",
                                                colors: [Color.black, Color.black])
                        }
                        .padding(.horizontal)

                        // 로그아웃 (빨간색 계열 그라데이션 예시)
                        Button(action: logout) {
                            gradientButtonLabel("로그아웃",
                                                colors: [Color.red, Color.red])
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
                    Image("SimCarLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                    
                    VStack(spacing: 20) {
                        TextField("  이메일", text: $email)
                            .padding(.vertical, 10)
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray)
                                    .padding(.top, 35),
                                alignment: .bottom
                            )
                            .padding(.horizontal, 30)

                        SecureField("  비밀번호", text: $password)
                            .padding(.vertical, 10)
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray)
                                    .padding(.top, 35),
                                alignment: .bottom
                            )
                            .padding(.horizontal, 30)
                        
                        // 로그인 버튼
                        Button(action: login) {
                            gradientButtonLabel("로그인")
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("심카가 처음이시라면?")
                                .font(.system(size: 15))
                                .padding(.leading, 20)
                            
                            // 회원가입 버튼 (기본 검은색 단색)
                            NavigationLink(destination: SignUpView()) {
                                Text("회원가입")
                                    .font(.system(size: 17))
                                    .bold()
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
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
                Alert(title: Text(""),
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
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.blue.opacity(0.8), radius: 5, x: 0, y: 0)
    }
    
    
    // MARK: - 로그인
    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "모든 필드를 입력하세요."
            showAlert = true
            return
        }
        
        isLoading = true
        
        guard let url = URL(string: API.login) else {
            alertMessage = "잘못된 URL입니다."
            showAlert = true
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
            alertMessage = "데이터 변환 오류"
            showAlert = true
            isLoading = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "로그인 실패: \(error.localizedDescription)"
                    showAlert = true
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
                        alertMessage = "로그인 실패"
                        showAlert = true
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

struct ContentView_Previews: PreviewProvider {
    @StateObject static var userSettings = UserSettings()
    static var previews: some View {
        ContentView()
            .environmentObject(userSettings)
    }
}
