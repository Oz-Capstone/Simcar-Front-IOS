import SwiftUI

struct DeleteAccountView: View {
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("회원을 탈퇴하시겠습니까?")
                    .font(.largeTitle)
                    .padding()

                Button(action: deleteAccount) {
                    Text("회원 탈퇴")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .border(Color.red, width: 2)
                }
                .padding()
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("알림"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("확인")))
            }
            .navigationTitle("회원 탈퇴")
            .overlay(isLoading ? ProgressView() : nil)
        }
    }

    private func deleteAccount() {
        isLoading = true
        errorMessage = nil
        
        // API 요청
        let memberId = 1 // 실제 회원 ID로 변경해야 함
        let url = URL(string: "http://localhost:8080/api/members/profile")! // 회원 탈퇴 API URL
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 필요한 경우 인증 토큰 등을 헤더에 추가
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "회원 탈퇴 실패: \(error.localizedDescription)"
                }
                return
            }
            
            // 응답 처리
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        alertMessage = "회원 탈퇴가 완료되었습니다."
                        showAlert = true
                    }
                } else {
                    DispatchQueue.main.async {
                        errorMessage = "회원 탈퇴 실패"
                    }
                }
            }
        }
        
        task.resume()
    }
}

