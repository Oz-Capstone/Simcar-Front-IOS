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
            ScrollView {
                VStack(spacing: 30) {
                    // 헤더
                    Text("차량 등록")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color(hex: "#9575CD"))
                        .padding(.top, 20)
                    
                    // 차량 정보 입력 섹션
                    VStack(alignment: .leading, spacing: 20) {
                        Text("차량 정보 입력")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal, 30)
                        
                        VStack {
                            AnimatedTextField(placeholder: "차량 유형 (SUV, 세단 등)", text: $type)
                            AnimatedTextField(placeholder: "제조사", text: $brand)
                            AnimatedTextField(placeholder: "모델", text: $model)
                            AnimatedTextField(placeholder: "연식", text: $year, keyboardType: .numberPad)
                            AnimatedTextField(placeholder: "주행거리", text: $mileage, keyboardType: .numberPad)
                            AnimatedTextField(placeholder: "연료 종류", text: $fuelType)
                            AnimatedTextField(placeholder: "가격", text: $price, keyboardType: .numberPad)
                            VStack{
                                AnimatedTextField(placeholder: "차량 번호", text: $carNumber)
                                AnimatedTextField(placeholder: "보험 이력", text: $insuranceHistory, keyboardType: .numberPad)
                                AnimatedTextField(placeholder: "검사 이력", text: $inspectionHistory, keyboardType: .numberPad)
                                AnimatedTextField(placeholder: "색상", text: $color)
                                AnimatedTextField(placeholder: "변속기", text: $transmission)
                                AnimatedTextField(placeholder: "지역", text: $region)
                                AnimatedTextField(placeholder: "연락처", text: $contactNumber)
                            }
                            
                        }
                    }
                    
                    // 이미지 추가 섹션
                    VStack(alignment: .leading, spacing: 20) {
                        Text("이미지 추가")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal, 30)
                        
                        if !newImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(newImages.indices, id: \.self) { index in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: newImages[index])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipped()
                                                .cornerRadius(8)
                                            Button(action: {
                                                newImages.remove(at: index)
                                            }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                            }
                                            .offset(x: -5, y: 5)
                                        }
                                    }
                                }
                            }
                        }
                        
                        gradientButtonLabel("이미지 선택", colors: [Color.gray, Color.gray])
                            .onTapGesture {
                                showImagePicker = true
                            }
                    }
                    
                    // 최종 차량 등록 버튼
                    gradientButtonLabel("차량 등록", colors: [Color.blue, Color.purple])
                        .onTapGesture {
                            registerCar()
                        }
                }
                .padding()
            }
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
    
    // MARK: - Animated TextField View
    /// TextField에 포커스 시 AnimatedUnderline을 오버레이하여 밑줄이 왼쪽에서 오른쪽으로 확장되는 효과 적용
    struct AnimatedTextField: View {
        var placeholder: String
        @Binding var text: String
        var keyboardType: UIKeyboardType = .default
        @FocusState private var isFocused: Bool

        var body: some View {
            TextField("  \(placeholder)", text: $text)
                .font(.title3)
                .keyboardType(keyboardType)
                .focused($isFocused)
                .padding(.vertical, 20)
                .overlay(
                    AnimatedUnderline(isFocused: isFocused, gradientColors: [Color.blue, Color.purple])
                        .padding(.top, 35),
                    alignment: .bottom
                )
                .padding(.horizontal, 30)
        }
    }
    
    // MARK: - 그라데이션 버튼
    private func gradientButtonLabel(_ title: String, colors: [Color] = [Color.blue, Color.purple]) -> some View {
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
    
    // MARK: - 차량 등록 함수
    private func registerCar() {
        // 필수 입력 체크
        let requiredFields = [
            type, brand, model, fuelType, carNumber,
            insuranceHistory, inspectionHistory, color,
            transmission, region, contactNumber
        ]
        if requiredFields.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            registrationMessage = "모든 필드를 입력해주세요."
            showAlert = true
            return
        }
        
        guard let yearInt = Int(year),
              let mileageInt = Int(mileage),
              let priceInt = Int(price),
              let insuranceHistoryInt = Int(insuranceHistory),
              let inspectionHistoryInt = Int(inspectionHistory)
        else {
            registrationMessage = "올바른 숫자를 입력하세요."
            showAlert = true
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
    
    // MARK: - 서버 전송 (multipart/form-data)
    private func sendCarRegistrationRequest(carData: [String: Any], images: [UIImage]) {
        guard let url = URL(string: API.cars) else {
            registrationMessage = "잘못된 서버 주소입니다."
            showAlert = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
            showAlert = true
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
        
        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    registrationMessage = "네트워크 오류: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    registrationMessage = "차량이 성공적으로 등록되었습니다."
                    showAlert = true
                } else {
                    let errMsg = data.flatMap { String(data: $0, encoding: .utf8) } ?? "알 수 없는 오류"
                    registrationMessage = "차량 등록 실패: \(errMsg)"
                    showAlert = true
                }
            }
        }.resume()
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
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
        // 업데이트 없음
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

//struct ContentView_Previews: PreviewProvider {
//    @StateObject static var userSettings = UserSettings()
//    static var previews: some View {
//        ContentView()
//            .environmentObject(userSettings)
//    }
//}
