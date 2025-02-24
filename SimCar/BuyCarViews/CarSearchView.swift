import SwiftUI

struct CarSearchView: View {
    // 부모 뷰(BuyCarView)에서 전달받은 검색 조건 바인딩
    @Binding var manufacturer: String
    @Binding var model: String
    @Binding var year: String
    @Binding var type: String
    @Binding var region: String
    @Binding var price: Double
    
    // 현재 뷰를 닫기 위한 환경 변수
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer()
                        Text("차량 검색")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color(hex: "#9575CD"))
                            .padding()
                        Spacer()
                    }
                    
                    // 검색 조건 입력 필드 그룹 (아래쪽 선 스타일)
                    VStack(spacing: 20) {
                        customTextField(placeholder: "제조사", text: $manufacturer)
                        customTextField(placeholder: "모델명", text: $model)
                        customTextField(placeholder: "연식", text: $year)
                        customTextField(placeholder: "차량 유형 (예: SUV, 세단)", text: $type)
                        customTextField(placeholder: "지역", text: $region)
                    }
                    
                    // 가격 선택 슬라이더 (그라데이션 스타일)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("가격")
                            .font(.title3)
                            .foregroundColor(Color(hex: "#9575CD"))
                            .padding(.horizontal, 30)
                        
                        // 기본 Slider의 accentColor를 지우고, 오버레이로 그라데이션을 마스크 처리
                        Slider(value: $price, in: 0...200000000, step: 100000)
                            .accentColor(.clear)
                            .padding(.horizontal, 30)
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .mask(
                                    Slider(value: $price, in: 0...200000000, step: 100000)
                                        .padding(.horizontal, 30)
                                )
                                .allowsHitTesting(false)
                            )
                        HStack {
                            Spacer()
                            Text("~ \(Int(price)) 원")
                                .font(.title3)
                                .foregroundColor(Color(hex: "#9575CD"))
                                .padding(.horizontal, 30)
                            Spacer()
                        }
                        
                    }
                    
                    // 검색 버튼 (그라데이션 스타일)
                    Button(action: {
                        dismiss()
                    }) {
                        gradientButtonLabel("검색")
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    // 커스텀 텍스트필드 (아래쪽 선 스타일)
    private func customTextField(placeholder: String, text: Binding<String>) -> some View {
        TextField("  \(placeholder)", text: text)
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
    }
    
    // 그라데이션 버튼 스타일 (MyPageView와 유사)
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
            .shadow(color: Color.blue.opacity(0.8), radius: 5, x: 0, y: 0)
    }
}


struct ContentView_Previews: PreviewProvider {
    @StateObject static var userSettings = UserSettings()
    static var previews: some View {
        ContentView()
            .environmentObject(userSettings)
    }
}
