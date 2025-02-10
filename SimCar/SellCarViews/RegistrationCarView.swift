import SwiftUI

struct RegistrationCarView: View {
    @Environment(\.presentationMode) var presentationMode  // ✅ 화면을 닫기 위한 변수 추가
    
    @State private var type: String = ""
    @State private var imageUrl: String = ""
    @State private var brand: String = ""
    @State private var model: String = ""
    @State private var year: String = ""
    @State private var mileage: String = ""
    @State private var fuelType: String = ""
    @State private var price: String = ""
    @State private var carNumber: String = ""
    @State private var insuranceHistory: String = ""
    @State private var inspectionHistory: String = ""
    @State private var color: String = ""
    @State private var transmission: String = ""
    @State private var region: String = ""
    @State private var contactNumber: String = ""
    
    @State private var registrationMessage: String = ""
    @State private var showAlert: Bool = false // ✅ 알림창 표시 여부 추가

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("차량 정보 입력")) {
                    VStack {
                        TextField("차량 유형", text: $type)
                        TextField("이미지 URL", text: $imageUrl)
                        TextField("제조사", text: $brand)
                        TextField("모델", text: $model)
                        TextField("연식", text: $year)
                            .keyboardType(.numberPad)
                        TextField("주행거리", text: $mileage)
                            .keyboardType(.numberPad)
                        TextField("연료 종류", text: $fuelType)
                        TextField("가격", text: $price)
                            .keyboardType(.numberPad)
                    }
                    VStack {
                        TextField("차량 번호", text: $carNumber)
                        TextField("보험 이력", text: $insuranceHistory)
                        TextField("검사 이력", text: $inspectionHistory)
                        TextField("색상", text: $color)
                        TextField("변속기 종류", text: $transmission)
                        TextField("지역", text: $region)
                        TextField("연락처", text: $contactNumber)
                    }
                }
                
                Button(action: registerCar) {
                    Text("차량 등록")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                if let registrationMessage = registrationMessage {
                    Text(registrationMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("차량 등록")
            .alert(isPresented: $showAlert) { // ✅ 차량 등록 성공 시 알림창 표시
                Alert(
                    title: Text("등록 완료"),
                    message: Text(registrationMessage),
                    dismissButton: .default(Text("확인"), action: {
                        presentationMode.wrappedValue.dismiss() // ✅ 확인 버튼을 누르면 화면 닫기
                    })
                )
            }
        }
    }
    
    private func registerCar() {
        // 1️⃣ 빈 칸 검사
        let requiredFields = [type, imageUrl, brand, model, fuelType, carNumber, insuranceHistory, inspectionHistory, color, transmission, region, contactNumber]
        
        if requiredFields.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            registrationMessage = "모든 필드를 입력해주세요."
            return
        }
        
        // 2️⃣ 숫자 입력 검사
        guard let yearInt = Int(year),
              let mileageInt = Int(mileage),
              let priceInt = Int(price),
              let insuranceHistory = Int(insuranceHistory),
              let inspectionHistory = Int(inspectionHistory)
                else {
            registrationMessage = "올바른 숫자를 입력하세요."
            return
        }
        
        let newCar = Car(
            type: type,
            imageUrl: imageUrl,
            brand: brand,
            model: model,
            year: yearInt,
            mileage: mileageInt,
            fuelType: fuelType,
            price: priceInt,
            carNumber: carNumber,
            insuranceHistory: insuranceHistory,
            inspectionHistory: inspectionHistory,
            color: color,
            transmission: transmission,
            region: region,
            contactNumber: contactNumber
        )
        
        sendCarRegistrationRequest(car: newCar)
    }

    
    private func sendCarRegistrationRequest(car: Car) {
        guard let url = URL(string: "http://localhost:8080/api/cars") else {
            registrationMessage = "잘못된 서버 주소입니다."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(car)
            request.httpBody = jsonData
        } catch {
            registrationMessage = "데이터 변환 오류"
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    registrationMessage = "네트워크 오류: \(error.localizedDescription)"
                    print("🚨 네트워크 오류: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    registrationMessage = "차량이 성공적으로 등록되었습니다."
                    print("✅ 차량 등록 성공")
                    
                    showAlert = true // ✅ 차량 등록 성공 시 알림창 표시
                    
                } else {
                    let errorMessage = data.flatMap { String(data: $0, encoding: .utf8) } ?? "알 수 없는 오류"
                    registrationMessage = "차량 등록 실패: \(errorMessage)"
                    print("🚨 서버 오류: \(errorMessage)")
                }
            }
        }
        
        task.resume()
    }
}

