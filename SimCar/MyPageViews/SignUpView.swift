import SwiftUI

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    @Environment(\.presentationMode) var presentationMode // 현재 화면을 닫기 위해 추가

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("회원가입")) {
                    TextField("이메일", text: $email)
                        .keyboardType(.emailAddress)
                    SecureField("비밀번호", text: $password)
                    TextField("이름", text: $name)
                    TextField("전화번호", text: $phone)
                        .keyboardType(.phonePad)
                    
                    Button(action: register) {
                        Text("회원가입")
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("회원가입")
            .overlay(isLoading ? ProgressView() : nil)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("알림"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("확인")) {
                          presentationMode.wrappedValue.dismiss() // 회원가입 성공 후 마이페이지로 이동
                      })
            }
        }
    }

    private func register() {
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty, !phone.isEmpty else {
            errorMessage = "모든 필드를 입력하세요."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let url = URL(string: "http://13.124.141.50:8080/api/members/join")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password,
            "name": name,
            "phone": phone
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
                    errorMessage = "회원가입 실패: \(error.localizedDescription)"
                }
                return
            }
            
            if let data = data, let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        alertMessage = "회원가입 성공했습니다!"
                        showAlert = true
                    }
                } else {
                    DispatchQueue.main.async {
                        errorMessage = "회원가입 실패"
                    }
                }
            }
        }
        
        task.resume()
    }
}


