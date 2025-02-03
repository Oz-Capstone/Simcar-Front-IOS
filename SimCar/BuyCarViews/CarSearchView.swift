import SwiftUI

struct CarSearchView: View {
    @State private var manufacturer: String = ""
    @State private var model: String = ""
    @State private var year: String = ""
    @State private var mileage: Double = 0.0
    @State private var price: Double = 0.0
    @State private var region: String = ""
    @State private var fuelType: String = ""
    @State private var transmission: String = ""
    @State private var exteriorColor: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView { // ScrollView 추가
                VStack(alignment: .leading) {
                    Text("차량 검색")
                        .font(.largeTitle)
                        .padding()
                    
                    // 첫 번째 그룹: 제조사, 모델, 연식
                    VStack {
                        TextField("제조사", text: $manufacturer)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        TextField("모델", text: $model)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        TextField("연식", text: $year)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }
                    .padding(.bottom) // 두 그룹 사이의 여백 추가
                    
                    // 두 번째 그룹: 주행거리, 가격, 지역, 연료, 변속기, 외부 색상
                    VStack {
                        // 주행거리 선택
                        Text("주행거리")
                            .padding(.horizontal)
                        Slider(value: $mileage, in: 0...100000, step: 1000)
                        Text("주행거리: \(Int(mileage)) km")
                            .padding(.horizontal)
                        
                        Spacer().frame(height: 20) // 주행거리와 가격 사이의 여백 추가
                        
                        // 가격 선택
                        Text("가격")
                            .padding(.horizontal)
                        Slider(value: $price, in: 0...10000000, step: 100000)
                        Text("가격: \(Int(price)) 원")
                            .padding(.horizontal)
                        
                        VStack {
                            // 지역 입력
                            TextField("지역", text: $region)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            
                            // 연료 입력
                            TextField("연료", text: $fuelType)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            
                            // 변속기 입력
                            TextField("변속기", text: $transmission)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            
                            // 외부 색상 입력
                            TextField("외부 색상", text: $exteriorColor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                        }
                    }
                    .padding(.bottom) // 마지막 그룹과 버튼 사이의 여백 추가
                    
                    // 검색 버튼
                    Button(action: {
                        // 검색 로직 추가
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
                    
                    Spacer() // 아래쪽 여백을 추가
                }
                .padding()
            }
        }
    }
}
