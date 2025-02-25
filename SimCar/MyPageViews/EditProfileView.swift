import SwiftUI

struct EditProfileView: View {
    // 이메일은 수정 API에 필요 없으므로 제거
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    // 뷰를 닫기 위한 dismiss 환경 변수
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("회원 정보 수정")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                    .foregroundColor(Color(hex: "#9575CD"))
                
                VStack(spacing: 20) {
                    // 비밀번호 입력 (변경 시 입력)
                    SecureField("  비밀번호 (변경 시 입력)", text: $password)
                        .font(.title3)
                        .padding(.vertical, 20)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray)
                                .padding(.top, 35),
                            alignment: .bottom
                        )
                        .padding(.horizontal, 30)
                    
                    // 이름 입력
                    TextField("  이름", text: $name)
                        .font(.title3)
                        .padding(.vertical, 20)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray)
                                .padding(.top, 35),
                            alignment: .bottom
                        )
                        .padding(.horizontal, 30)
                    
                    // 전화번호 입력
                    TextField("  전화번호", text: $phone)
                        .font(.title3)
                        .keyboardType(.phonePad)
                        .padding(.vertical, 20)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray)
                                .padding(.top, 35),
                            alignment: .bottom
                        )
                        .padding(.horizontal, 30)
                    
                    // 수정 버튼 (그라데이션 버튼)
                    Button(action: updateProfile) {
                        gradientButtonLabel("수정하기")
                    }
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
            .onAppear(perform: fetchProfile)
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(""),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("확인"), action: {
                        // 수정 성공 메시지일 경우에만 뒤로가기
                        if alertMessage == "회원 정보가 수정되었습니다." {
                            dismiss()
                        }
                    })
                )
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
            .shadow(color: Color.gray.opacity(0.8), radius: 5, x: 0, y: 0)
    }
    
    // 회원 정보 조회 (GET /api/members/profile)
    private func fetchProfile() {
        isLoading = true
        
        guard let url = URL(string: API.profile) else {
            alertMessage = "잘못된 URL입니다."
            showAlert = true
            isLoading = false
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
                    let memberProfile = try JSONDecoder().decode(MemberProfileResponse.self, from: data)
                    DispatchQueue.main.async {
                        // 이름과 전화번호 업데이트
                        name = memberProfile.name
                        phone = memberProfile.phone
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
    
    // 회원 정보 수정 (PUT /api/members/profile)
    private func updateProfile() {
        isLoading = true
        alertMessage = ""
        
        guard let url = URL(string: API.profile) else {
            alertMessage = "잘못된 URL입니다."
            showAlert = true
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 스웨거 API에 맞게 "name", "phone", (비밀번호가 있으면 "password") 전송
        var parameters: [String: Any] = [
            "name": name,
            "phone": phone
        ]
        if !password.isEmpty {
            parameters["password"] = password
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            alertMessage = "데이터 변환 오류"
            showAlert = true
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { isLoading = false }
            
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "회원 정보 수정 실패: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    if httpResponse.statusCode == 200 {
                        alertMessage = "회원 정보가 수정되었습니다."
                    } else {
                        alertMessage = "회원 정보 수정 실패"
                    }
                    showAlert = true
                }
            }
        }.resume()
    }
}
