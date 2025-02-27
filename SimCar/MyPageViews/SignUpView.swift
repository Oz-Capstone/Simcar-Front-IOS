import SwiftUI


// MARK: - Custom Underlined TextField using AnimatedUnderline
struct UnderlinedTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            TextField("  \(placeholder)", text: $text)
                .font(.title3)
                .keyboardType(keyboardType)
                .focused($isFocused)
                .padding(.vertical, 20)
                .padding(.horizontal, 30)
            AnimatedUnderline(isFocused: isFocused)
                .padding(.horizontal, 30)
        }
    }
}

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("회원가입")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                    .foregroundColor(Color(hex: "#9575CD"))
                
                VStack(spacing: 20) {
                    UnderlinedTextField(placeholder: "이메일", text: $email, keyboardType: .emailAddress)
                    UnderlinedTextField(placeholder: "비밀번호", text: $password)
                    UnderlinedTextField(placeholder: "이름", text: $name)
                    UnderlinedTextField(placeholder: "전화번호", text: $phone, keyboardType: .phonePad)
                    
                    Button(action: register) {
                        gradientButtonLabel("회원가입")
                    }
                    .buttonStyle(PressableButtonStyle())
                    .padding(.horizontal, 30)
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                .padding()

                Spacer()
            }
            .padding()
            .overlay(isLoading ? ProgressView() : nil)
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(""),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("확인"), action: {
                        // 회원가입 성공 메시지일 때 화면을 닫음
                        if alertMessage == "회원가입 성공했습니다!" {
                            presentationMode.wrappedValue.dismiss()
                        }
                    })
                )
            }
        }
    }
    
    // MARK: - 그라데이션 버튼 라벨
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
            .shadow(color: Color.gray.opacity(0.8), radius: 5, x: 0, y: 0)
    }
    
    private func register() {
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty, !phone.isEmpty else {
            alertMessage = "모든 필드를 입력하세요."
            showAlert = true
            return
        }
        
        isLoading = true
        
        guard let url = URL(string: API.join) else {
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
            "password": password,
            "name": name,
            "phone": phone
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
                    alertMessage = "회원가입 실패: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }
            
            if let data = data, let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    if httpResponse.statusCode == 200 {
                        alertMessage = "회원가입 성공했습니다!"
                    } else {
                        alertMessage = "회원가입 실패"
                    }
                    showAlert = true
                }
            }
        }
        
        task.resume()
    }
}
