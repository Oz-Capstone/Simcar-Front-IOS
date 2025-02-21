import SwiftUI
import PhotosUI

struct RegistrationCarView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // 차량 정보 입력 필드들
    @State private var type: String = ""
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
    
    // 새로 추가할 이미지들 (로컬 선택)
    @State private var newImages: [UIImage] = []
    @State private var showImagePicker: Bool = false
    
    // 등록 결과 메시지 및 알림창 표시
    @State private var registrationMessage: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("차량 정보 입력")) {
                    VStack {
                        TextField("차량 유형 (SUV, 세단 등)", text: $type)
                        TextField("제조사 (brand)", text: $brand)
                        TextField("모델 (model)", text: $model)
                        TextField("연식 (year)", text: $year)
                            .keyboardType(.numberPad)
                        TextField("주행거리 (mileage)", text: $mileage)
                            .keyboardType(.numberPad)
                        TextField("연료 종류 (fuelType)", text: $fuelType)
                        TextField("가격 (price)", text: $price)
                            .keyboardType(.numberPad)
                    }
                    VStack {
                        TextField("차량 번호 (carNumber)", text: $carNumber)
                        TextField("보험 이력 (insuranceHistory)", text: $insuranceHistory)
                            .keyboardType(.numberPad)
                        TextField("검사 이력 (inspectionHistory)", text: $inspectionHistory)
                            .keyboardType(.numberPad)
                        TextField("색상 (color)", text: $color)
                        TextField("변속기 (transmission)", text: $transmission)
                        TextField("지역 (region)", text: $region)
                        TextField("연락처 (contactNumber)", text: $contactNumber)
                    }
                }
                
                Section(header: Text("이미지 추가")) {
                    // 새로 추가할 이미지를 보여줌 (제거 버튼 포함)
                    if !newImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                // newImages 배열의 인덱스를 사용하여 ForEach
                                ForEach(newImages.indices, id: \.self) { index in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: newImages[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                        
                                        // 제거 버튼: 누르면 해당 이미지 삭제
                                        Button(action: {
                                            newImages.remove(at: index)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                        }
                                        .offset(x: 5, y: -5)
                                    }
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("이미지 선택")
                        }
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
                
                if !registrationMessage.isEmpty {
                    Text(registrationMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("차량 등록")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("등록 결과"),
                    message: Text(registrationMessage),
                    dismissButton: .default(Text("확인"), action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImages: $newImages)
            }
        }
    }
    
    // MARK: - 차량 등록 버튼 액션
    private func registerCar() {
        // 필수 입력 항목 체크
        let requiredFields = [
            type, brand, model, fuelType, carNumber,
            insuranceHistory, inspectionHistory, color,
            transmission, region, contactNumber
        ]
        if requiredFields.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            registrationMessage = "모든 필드를 입력해주세요."
            return
        }
        
        // 숫자 필드 변환
        guard let yearInt = Int(year),
              let mileageInt = Int(mileage),
              let priceInt = Int(price),
              let insuranceHistoryInt = Int(insuranceHistory),
              let inspectionHistoryInt = Int(inspectionHistory)
        else {
            registrationMessage = "올바른 숫자를 입력하세요."
            return
        }
        
        // JSON 부분(차량 정보) 준비
        let carData: [String: Any] = [
            "type": type,
            "price": priceInt,
            "brand": brand,
            "model": model,
            "year": yearInt,
            "mileage": mileageInt,
            "fuelType": fuelType,
            "carNumber": carNumber,
            "insuranceHistory": insuranceHistoryInt,
            "inspectionHistory": inspectionHistoryInt,
            "color": color,
            "transmission": transmission,
            "region": region,
            "contactNumber": contactNumber
        ]
        
        sendCarRegistrationRequest(carData: carData, images: newImages)
    }
    
    // MARK: - 서버 전송 함수 (multipart/form-data)
    private func sendCarRegistrationRequest(carData: [String: Any], images: [UIImage]) {
        guard let url = URL(string: "http://13.124.141.50:8080/api/cars") else {
            registrationMessage = "잘못된 서버 주소입니다."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // multipart/form-data 전송을 위한 boundary
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Part 1: 차량 정보(JSON) 파트
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: carData, options: [])
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"request\"\r\n")
            body.append("Content-Type: application/json\r\n\r\n")
            body.append(jsonData)
            body.append("\r\n")
        } catch {
            registrationMessage = "데이터 변환 오류"
            return
        }
        
        // Part 2: 이미지 파일 첨부
        for (index, image) in images.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"images\"; filename=\"image\(index).jpg\"\r\n")
                body.append("Content-Type: image/jpeg\r\n\r\n")
                body.append(imageData)
                body.append("\r\n")
            }
        }
        
        // 파트 종료
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        // URLSession 전송
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    registrationMessage = "네트워크 오류: \(error.localizedDescription)"
                    print("🚨 네트워크 오류: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    registrationMessage = "차량이 성공적으로 등록되었습니다."
                    print("✅ 차량 등록 성공")
                    showAlert = true  // 성공 시 알림창 표시
                } else {
                    let errorMessage = data.flatMap { String(data: $0, encoding: .utf8) } ?? "알 수 없는 오류"
                    registrationMessage = "차량 등록 실패: \(errorMessage)"
                    print("🚨 서버 오류: \(errorMessage)")
                }
            }
        }.resume()
    }
}

// MARK: - ImagePicker (PHPicker 사용)
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImages: [UIImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0 // 여러 장 선택 가능
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // 별도 업데이트 없음
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                        if let image = object as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.selectedImages.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}

//// MARK: - Data Extension (multipart/form-data 조합 편의를 위해)
//extension Data {
//    mutating func append(_ string: String) {
//        if let data = string.data(using: .utf8) {
//            append(data)
//        }
//    }
//}
