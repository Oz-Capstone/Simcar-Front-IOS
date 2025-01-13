import SwiftUI

struct LogInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("로그인")) {
                    TextField("이메일", text: $email)
                        .keyboardType(.emailAddress)
                    SecureField("비밀번호", text: $password)
                    
                    Button(action: login) {
                        Text("로그인")
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("로그인")
            .overlay(isLoading ? ProgressView() : nil)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("알림"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("확인")))
            }
        }
    }

    private func login() {
        // API 요청을 위한 함수
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "모든 필드를 입력하세요."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // API 요청
        let url = URL(string: "http://localhost:8080/api/members/login")! // HTTP로 변경
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "email": email, // 아이디 대신 이메일로 변경
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
            
            // 응답 처리
            if let data = data, let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // 로그인 성공 처리
                    DispatchQueue.main.async {
                        alertMessage = "로그인 성공했습니다!"
                        showAlert = true
                    }

                } else {
                    // 서버에서 에러 메시지 파싱
                    if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let message = errorResponse["message"] as? String {
                        DispatchQueue.main.async {
                            errorMessage = "로그인 실패: \(message)"
                        }
                    } else {
                        DispatchQueue.main.async {
                            errorMessage = "로그인 실패"
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
}
