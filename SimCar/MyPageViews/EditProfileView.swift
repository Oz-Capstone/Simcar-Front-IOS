import SwiftUI

struct EditProfileView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("회원 정보 수정")) {
                    TextField("이메일", text: $email)
                        .keyboardType(.emailAddress)
                    SecureField("비밀번호", text: $password)
                    TextField("이름", text: $name)
                    TextField("전화번호", text: $phone)
                        .keyboardType(.phonePad)
                    
                    Button(action: updateProfile) {
                        Text("수정하기")
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                }
            }
            .navigationTitle("회원 정보 수정")
            .overlay(isLoading ? ProgressView() : nil)
            .onAppear(perform: fetchProfile)
        }
    }

    private func fetchProfile() {
        isLoading = true
        
        let url = URL(string: "http://localhost:8080/api/members/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "회원 정보 조회 실패: \(error.localizedDescription)"
                }
                return
            }
            
            // 응답 처리
            if let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    // JSON 데이터 파싱
                    let memberProfile = try JSONDecoder().decode(MemberProfileResponse.self, from: data)
                    DispatchQueue.main.async {
                        email = memberProfile.email
                        name = memberProfile.name
                        phone = memberProfile.phone
                    }
                } catch {
                    DispatchQueue.main.async {
                        errorMessage = "데이터 변환 오류"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = "회원 정보 조회 실패"
                }
            }
        }
        
        task.resume()
    }

    private func updateProfile() {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        // API 요청
        let url = URL(string: "http://localhost:8080/api/members/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password.isEmpty ? nil : password,
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
                    errorMessage = "회원 정보 수정 실패: \(error.localizedDescription)"
                }
                return
            }
            
            // 응답 처리
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        successMessage = "회원 정보가 수정되었습니다."
                    }
                } else {
                    DispatchQueue.main.async {
                        errorMessage = "회원 정보 수정 실패"
                    }
                }
            }
        }
        
        task.resume()
    }
}

