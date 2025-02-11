import SwiftUI

struct EditCarView: View {
    @Environment(\.presentationMode) var presentationMode  // 화면 닫기를 위한 변수
    @Binding var selectedTab: Int                            // ContentView에서 전달받은 탭 상태
    var car: CarDetail // 수정할 차량 정보
    var carId : Int

    // 입력 필드들을 위한 상태 변수 (초기값은 차량 정보로 미리 채움)
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
    
    @State private var updateMessage: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("차량 정보 수정")) {
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
                
                Button(action: updateCar) {
                    Text("차량 정보 수정")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                if !updateMessage.isEmpty {
                    Text(updateMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("차량 정보 수정")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("수정 완료"),
                    message: Text(updateMessage),
                    dismissButton: .default(Text("확인"), action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                )
            }
            .navigationBarHidden(true)
        }
        .onAppear(perform: loadInitialValues)
    }
    
    private func loadInitialValues() {
        // 전달받은 기존 차량 정보로 각 필드를 미리 채움
        type = car.type
        imageUrl = car.imageUrl
        brand = car.brand
        model = car.model
        year = "\(car.year)"
        mileage = "\(car.mileage ?? 0)"
        fuelType = car.fuelType ?? ""
        price = "\(car.price)"
        carNumber = car.carNumber
        insuranceHistory = "\(car.insuranceHistory ?? 0)"
        inspectionHistory = "\(car.inspectionHistory ?? 0)"
        color = car.color
        transmission = car.transmission
        region = car.region ?? ""
        contactNumber = car.contactNumber ?? ""
    }
    
    private func updateCar() {
        // 빈 칸 및 숫자 유효성 검사
        let requiredFields = [type, imageUrl, brand, model, fuelType, carNumber, insuranceHistory, inspectionHistory, color, transmission, region, contactNumber]
        if requiredFields.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            updateMessage = "모든 필드를 입력해주세요."
            return
        }
        
        guard let yearInt = Int(year),
              let mileageInt = Int(mileage),
              let priceInt = Int(price),
              let insuranceHistoryInt = Int(insuranceHistory),
              let inspectionHistoryInt = Int(inspectionHistory)
        else {
            updateMessage = "올바른 숫자를 입력하세요."
            return
        }
        
        // 수정할 차량 정보를 업데이트
        let updatedCar = Car(
            type: type,
            imageUrl: imageUrl,
            brand: brand,
            model: model,
            year: yearInt,
            mileage: mileageInt,
            fuelType: fuelType,
            price: priceInt,
            carNumber: carNumber,
            insuranceHistory: insuranceHistoryInt,
            inspectionHistory: inspectionHistoryInt,
            color: color,
            transmission: transmission,
            region: region,
            contactNumber: contactNumber
        )
        
        sendUpdateRequest(car: updatedCar)
    }
    
    private func sendUpdateRequest(car: Car) {
        guard let url = URL(string: "http://localhost:8080/api/cars/\(carId)") else {
            updateMessage = "잘못된 서버 주소입니다."
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT" // 차량 정보 수정은 PUT 메서드 사용
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(car)
            request.httpBody = jsonData
        } catch {
            updateMessage = "데이터 변환 오류"
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    updateMessage = "네트워크 오류: \(error.localizedDescription)"
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    updateMessage = "차량 정보가 성공적으로 수정되었습니다."
                    showAlert = true
                } else {
                    let errMsg = data.flatMap { String(data: $0, encoding: .utf8) } ?? "알 수 없는 오류"
                    updateMessage = "차량 정보 수정 실패: \(errMsg)"
                }
            }
        }.resume()
    }
}
