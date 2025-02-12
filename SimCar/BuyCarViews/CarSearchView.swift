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
                VStack(alignment: .leading) {
                    Text("차량 검색")
                        .font(.largeTitle)
                        .padding()
                    
                    // 검색 조건 입력 필드 그룹
                    VStack {
                        TextField("제조사", text: $manufacturer)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        TextField("모델명", text: $model)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        TextField("연식", text: $year)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        TextField("차량 유형 (예: SUV, 세단)", text: $type)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        TextField("지역", text: $region)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }
                    .padding(.bottom)
                    
                    // 가격 선택 슬라이더
                    VStack {
                        Text("가격")
                            .padding(.horizontal)
                        Slider(value: $price, in: 0...200000000, step: 100000)
                        Text("가격: \(Int(price)) 원")
                            .padding(.horizontal)
                    }
                    .padding(.bottom)
                    
                    // 검색 버튼: 조건을 설정한 후 뷰를 닫음
                    Button(action: {
                        dismiss()
                    }) {
                        Text("검색")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}
