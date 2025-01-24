import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var userSettings: UserSettings // UserSettings 참조
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("마이페이지 입니다")
                
                if userSettings.isLoggedIn {
                    Text("로그인 상태입니다.")
                } else {
                    Text("로그인하지 않은 상태입니다.")
                }
                
                // 로그인하지 않은 상태에서 보이는 버튼
                if !userSettings.isLoggedIn {
                    NavigationLink(destination: SignUpView()) {
                        Text("회원가입")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: LogInView()) {
                        Text("로그인")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                // 로그인한 상태에서만 보이는 버튼
                if userSettings.isLoggedIn {
                    NavigationLink(destination: EditProfileView()) {
                        Text("회원 정보 수정")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: DeleteAccountView()) {
                        Text("회원 탈퇴")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: FavoriteCarView()) {
                        Text("찜한 차량 조회")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: ProfileView()) {
                        Text("회원 정보 조회")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    // 로그아웃 버튼
                    Button(action: {
                        if userSettings.isLoggedIn {
                            logout()
                        } else {
                            alertMessage = "로그인이 필요합니다."
                            showAlert = true // 알림창 표시
                        }
                    }) {
                        Text("로그아웃")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
                    }
                }
            }
            .navigationTitle("마이페이지")
        }
    }
    
    // 로그아웃 API 요청 함수
    private func logout() {
        guard let url = URL(string: "http://localhost:8080/api/members/logout") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // 서버 응답 처리
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    userSettings.isLoggedIn = false // 로그인 상태 변경
                    alertMessage = "로그아웃이 완료되었습니다."
                    showAlert = true // 알림창 표시
                }
            }
        }
        
        task.resume()
    }
}
