import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var userSettings: UserSettings
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @Binding var selectedTab: Int  // ContentView에서 전달받은 바텀 탭 상태
    
    // 포커스 상태 추적
    @FocusState private var emailFieldIsFocused: Bool
    @FocusState private var passwordFieldIsFocused: Bool
    
    // 서버에서 가져온 회원 정보
    @State private var memberProfile: MemberProfileResponse?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if userSettings.isLoggedIn {
                    // 로그인된 상태
                    if let profile = memberProfile {
                        Text("\(profile.name)님 반갑습니다!")
                            .font(.title)
                            .bold()
                            .foregroundColor(Color(hex: "#9575CD"))
                    } else {
                        Text("마이페이지")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color(hex: "#9575CD"))
                    }
                    
                    VStack(spacing: 20) {
                        NavigationLink(destination: FavoriteCarView(selectedTab: $selectedTab)) {
                            gradientMyPageButtonLabel("찜한 차량 조회")
                        }
                        .buttonStyle(PressableButtonStyle())
                        .padding(.top)
                        .padding(.horizontal)

                        NavigationLink(destination: EditProfileView()) {
                            gradientMyPageButtonLabel("회원 정보 수정", colors: [Color.purple, Color.pink])
                        }
                        .buttonStyle(PressableButtonStyle())
                        .padding(.horizontal)

                        NavigationLink(destination: ProfileView()) {
                            gradientMyPageButtonLabel("회원 정보 조회", colors: [Color.purple, Color.pink])
                        }
                        .buttonStyle(PressableButtonStyle())
                        .padding(.horizontal)
                        .padding(.bottom)

                        NavigationLink(destination: DeleteAccountView()) {
                            gradientButtonLabel("회원 탈퇴", colors: [Color.black, Color.black])
                        }
                        .buttonStyle(PressableButtonStyle())
                        .padding(.horizontal)
                        .padding(.top)

                        Button(action: logout) {
                            gradientButtonLabel("로그아웃", colors: [Color.gray, Color.gray])
                        }
                        .buttonStyle(PressableButtonStyle())
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding()
                    
                } else {
                    Image("SimCarLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                    
                    VStack(spacing: 20) {
                        TextField("  이메일", text: $email)
                            .focused($emailFieldIsFocused)
                            .font(.title3)
                            .padding(.vertical, 20)
                            .overlay(
                                AnimatedUnderline(isFocused: emailFieldIsFocused, gradientColors: [Color.blue, Color.purple])
                                    .padding(.top, 35),
                                alignment: .bottom
                            )
                            .padding(.horizontal, 30)

                        SecureField("  비밀번호", text: $password)
                            .focused($passwordFieldIsFocused)
                            .font(.title3)
                            .padding(.vertical, 20)
                            .overlay(
                                AnimatedUnderline(isFocused: passwordFieldIsFocused, gradientColors: [Color.blue, Color.purple])
                                    .padding(.top, 35),
                                alignment: .bottom
                            )
                            .padding(.horizontal, 30)
                        
                        Button(action: login) {
                            gradientButtonLabel("로그인")
                        }
                        .buttonStyle(PressableButtonStyle())
                        .padding(.horizontal)
                        
                        HStack {
                            Text("심카가 처음이시라면?")
                                .font(.system(size: 15))
                                .padding(.leading, 20)
                            
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
                            .buttonStyle(PressableButtonStyle())
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
                Alert(
                    title: Text(""),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("확인"), action: {
                        if alertMessage == "로그인 성공했습니다!" {
                            userSettings.isLoggedIn = true
                            fetchMemberProfile()
                        }
                    })
                )
            }
            .onAppear {
                if userSettings.isLoggedIn {
                    fetchMemberProfile()
                }
            }
        }
    }
    
    // MARK: - 공용 그라데이션 버튼 라벨
    private func gradientButtonLabel(_ title: String, colors: [Color] = [Color.blue, Color.purple]) -> some View {
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
    
    // MARK: - 공용 그라데이션 버튼 라벨
    private func gradientMyPageButtonLabel(_ title: String, colors: [Color] = [Color.blue, Color.purple]) -> some View {
        Text(title)
            .font(.title2)
            .bold()
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 80) // 고정 높이 80 포인트 지정
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

    
    // MARK: - 회원 정보 조회 (GET /api/members/profile)
    private func fetchMemberProfile() {
        isLoading = true
        alertMessage = ""
        
        guard let url = URL(string: API.profile) else {
            alertMessage = "잘못된 URL입니다."
            isLoading = false
            showAlert = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { isLoading = false }
            
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "회원 정보 조회 실패: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }
            
            if let data = data,
               let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                do {
                    let decodedMember = try JSONDecoder().decode(MemberProfileResponse.self, from: data)
                    DispatchQueue.main.async {
                        memberProfile = decodedMember
                    }
                } catch {
                    DispatchQueue.main.async {
                        alertMessage = "데이터 변환 오류"
                        showAlert = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    alertMessage = "회원 정보 조회 실패"
                    showAlert = true
                }
            }
        }.resume()
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
                    memberProfile = nil
                }
            }
        }
        
        task.resume()
    }
}

// MARK: - Animated Underline View
struct AnimatedUnderline: View {
    var isFocused: Bool
    var gradientColors: [Color] = [Color.blue, Color.purple]
    @State private var animatedWidth: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: isFocused ? 1 : 1)
                
                if isFocused {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: gradientColors),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: animatedWidth, height: 5)
                        .onAppear {
                            animatedWidth = 0
                            withAnimation(.easeInOut(duration: 0.3)) {
                                animatedWidth = geometry.size.width
                            }
                        }
                        .onChange(of: isFocused) { newValue in
                            if newValue {
                                animatedWidth = 0
                                withAnimation(.easeInOut(duration: 1.5)) {
                                    animatedWidth = geometry.size.width
                                }
                            } else {
                                animatedWidth = 0
                            }
                        }
                }
            }
        }
        .frame(height: isFocused ? 3 : 1)
    }
}

// MARK: - Animated Button View
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: configuration.isPressed)
    }
}
