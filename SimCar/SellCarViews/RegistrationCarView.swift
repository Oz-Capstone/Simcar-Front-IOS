import SwiftUI

struct RegistrationCarView: View {
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
                    VStack() {
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
        
            }
            .navigationTitle("차량 등록")
        }
    }
    
    private func registerCar() {
        // 입력값 검증
        guard let yearInt = Int(year),
              let mileageInt = Int(mileage),
              let priceInt = Int(price) else {
            DispatchQueue.main.async {
                registrationMessage = "올바른 숫자를 입력하세요."
            }
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
        
        SimCar.registerCar(car: newCar) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    registrationMessage = "차량이 성공적으로 등록되었습니다."
                case .failure(let error):
                    registrationMessage = "차량 등록 실패: \(error.localizedDescription)"
                }
            }
        }
    }
}

func registerCar(car: Car, completion: @escaping (Result<Void, Error>) -> Void) {
    // 서버 URL
    guard let url = URL(string: "http://localhost:8080/api/cars") else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // 차량 정보를 JSON으로 변환
    do {
        let jsonData = try JSONEncoder().encode(car)
        request.httpBody = jsonData
    } catch {
        completion(.failure(error))
        return
    }
    
    // 네트워크 요청
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            return
        }
        
        completion(.success(()))
    }
    
    task.resume()
}


