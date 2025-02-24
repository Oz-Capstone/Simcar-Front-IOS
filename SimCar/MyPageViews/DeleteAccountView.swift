import SwiftUI

struct DeleteAccountView: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode

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
                    Text("오류: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("알림"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("확인"), action: {
                          // 회원 탈퇴 성공 후 뒤로 가기 (로그인 화면으로 돌아감)
                          presentationMode.wrappedValue.dismiss()
                      }))
            }
            .navigationTitle("회원 탈퇴")
            .overlay(isLoading ? ProgressView() : nil)
        }
    }

    private func deleteAccount() {
        isLoading = true
        errorMessage = nil
        
        // 실제 회원 ID로 변경해야 함
        let memberId = 1
        
        guard let url = URL(string: API.profile) else {
            errorMessage = "잘못된 URL입니다."
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // 필요한 경우 인증 토큰 등을 헤더에 추가

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "회원 탈퇴 실패: \(error.localizedDescription)"
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        // 탈퇴 성공 시 로그아웃 처리 및 로그인 화면으로 이동
                        userSettings.isLoggedIn = false
                        alertMessage = "회원 탈퇴가 완료되었습니다."
                        showAlert = true
                    }
                } else {
                    DispatchQueue.main.async {
                        errorMessage = "회원 탈퇴 실패"
                    }
                }
            }
        }.resume()
    }
}
