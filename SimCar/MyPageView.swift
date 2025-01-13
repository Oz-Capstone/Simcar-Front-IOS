import SwiftUI

struct MyPageView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("마이페이지 입니다")
                
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
            }
            .navigationTitle("마이페이지")
        }
    }
}


