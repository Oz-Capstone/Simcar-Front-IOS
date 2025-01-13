import SwiftUI

struct ProfileView: View {
    @State private var member: MemberProfileResponse?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                } else if let member = member {
                    Form {
                        Section(header: Text("회원 정보")) {
                            Text("이메일: \(member.email)")
                            Text("이름: \(member.name)")
                            Text("전화번호: \(member.phone)")
                        }
                    }
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("회원 정보")
            .onAppear(perform: fetchMemberProfile)
        }
    }

    private func fetchMemberProfile() {
        isLoading = true
        errorMessage = nil
        
        // API 요청
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
                    member = try JSONDecoder().decode(MemberProfileResponse.self, from: data)
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
}

// 회원 프로필 응답 모델
struct MemberProfileResponse: Codable {
    let email: String
    let name: String
    let phone: String
    

}
