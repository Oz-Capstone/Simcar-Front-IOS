import SwiftUI
import PhotosUI

struct EditCarView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentRepresentativeImageUrl: String? = nil
    @Binding var selectedTab: Int
    var car: CarDetail  // 기존 차량 정보
    var carId: Int

    // 차량 정보 입력 필드
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
    
    // 이미지 관련 상태 변수
    @State private var currentImages: [CarImage] = []    // 기존 이미지들
    @State private var newImages: [UIImage] = []           // 새로 추가할 이미지들
    @State private var showImagePicker: Bool = false
    
    // 이미지 순서 변경 관련 상태 변수
    @State private var reorderMode: Bool = false
    @State private var imageOrder: [CarImage] = []
    
    // 업데이트 결과 메시지 및 Alert
    @State private var updateMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var updateSuccess: Bool = false  // 업데이트 성공 여부

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // 헤더
                    Text("차량 정보 수정")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color(hex: "#9575CD"))
                        .padding(.top, 20)
                    
                    // 차량 정보 입력 필드 그룹
                    VStack(alignment: .leading, spacing: 20) {
                        Text("기본 정보")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal, 30)
                        
                        // 기존 customTextField 대신 AnimatedTextField 사용
                        AnimatedTextField(placeholder: "차량 유형", text: $type)
                        AnimatedTextField(placeholder: "제조사", text: $brand)
                        AnimatedTextField(placeholder: "모델", text: $model)
                        AnimatedTextField(placeholder: "연식", text: $year, keyboardType: .numberPad)
                        AnimatedTextField(placeholder: "주행거리", text: $mileage, keyboardType: .numberPad)
                        AnimatedTextField(placeholder: "연료 종류", text: $fuelType)
                        AnimatedTextField(placeholder: "가격", text: $price, keyboardType: .numberPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("추가 정보")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal, 30)
                        
                        AnimatedTextField(placeholder: "차량 번호", text: $carNumber)
                        AnimatedTextField(placeholder: "보험 이력", text: $insuranceHistory, keyboardType: .numberPad)
                        AnimatedTextField(placeholder: "검사 이력", text: $inspectionHistory, keyboardType: .numberPad)
                        AnimatedTextField(placeholder: "색상", text: $color)
                        AnimatedTextField(placeholder: "변속기 종류", text: $transmission)
                        AnimatedTextField(placeholder: "지역", text: $region)
                        AnimatedTextField(placeholder: "연락처", text: $contactNumber)
                    }
                    
                    // 이미지 관리 섹션
                    VStack(alignment: .leading, spacing: 20) {
                        Text("이미지 관리")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal, 30)
                        
                        // 순서 변경 모드 토글
                        Toggle("이미지 순서 변경 모드", isOn: $reorderMode)
                            .padding(.horizontal, 30)
                        
                        if reorderMode {
                            VStack {
                                List {
                                    ForEach(imageOrder) { image in
                                        HStack {
                                            if let url = URL(string: image.fullImageUrl) {
                                                AsyncImage(url: url) { img in
                                                    img
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 60, height: 60)
                                                        .cornerRadius(8)
                                                } placeholder: {
                                                    ProgressView()
                                                        .frame(width: 60, height: 60)
                                                }
                                            } else {
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 60, height: 60)
                                                    .cornerRadius(8)
                                            }
                                            Text("ID: \(image.id)")
                                            Spacer()
                                            if currentRepresentativeImageUrl == image.fullImageUrl {
                                                Text("대표")
                                                    .foregroundColor(.blue)
                                                    .font(.caption)
                                            } else {
                                                Button("대표 설정") {
                                                    updateThumbnail(imageId: image.id)
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                                .font(.caption)
                                            }
                                            Button {
                                                deleteImage(imageId: image.id)
                                            } label: {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                        }
                                    }
                                    .onMove(perform: moveImage)
                                }
                                .environment(\.editMode, .constant(.active))
                                .listStyle(PlainListStyle())
                                .frame(height: max(CGFloat(imageOrder.count) * 70, 200))
                                
                                Button(action: updateImageOrder) {
                                    gradientButtonLabel("순서 저장", colors: [Color.green, Color.blue])
                                }
                                .buttonStyle(PressableButtonStyle())
                            }
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(currentImages) { image in
                                        ZStack(alignment: .topTrailing) {
                                            if let url = URL(string: image.fullImageUrl) {
                                                AsyncImage(url: url) { img in
                                                    img
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 100, height: 100)
                                                        .clipped()
                                                        .cornerRadius(8)
                                                } placeholder: {
                                                    ProgressView()
                                                        .frame(width: 100, height: 100)
                                                }
                                            } else {
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .clipped()
                                                    .cornerRadius(8)
                                            }
                                            VStack {
                                                if currentRepresentativeImageUrl == image.fullImageUrl {
                                                    Text("대표")
                                                        .font(.caption2)
                                                        .padding(4)
                                                        .background(Color.blue.opacity(0.7))
                                                        .cornerRadius(4)
                                                        .foregroundColor(.white)
                                                } else {
                                                    Button {
                                                        updateThumbnail(imageId: image.id)
                                                    } label: {
                                                        Text("대표 설정")
                                                            .font(.caption2)
                                                            .padding(4)
                                                            .background(Color.gray.opacity(0.7))
                                                            .cornerRadius(4)
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                                Spacer()
                                                Button {
                                                    deleteImage(imageId: image.id)
                                                } label: {
                                                    Image(systemName: "minus.circle.fill")
                                                        .foregroundColor(.red)
                                                }
                                            }
                                            .padding(4)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // 새로 추가한 이미지 미리보기
                        if !newImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(newImages, id: \.self) { uiImage in
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        // 이미지 추가 버튼
                        Button(action: { showImagePicker = true }) {
                            gradientButtonLabel("이미지 추가", colors: [Color.gray, Color.gray])
                        }
                        .buttonStyle(PressableButtonStyle())
                        
                        if !newImages.isEmpty {
                            Button(action: addNewImages) {
                                gradientButtonLabel("새 이미지 업로드", colors: [Color.black, Color.black])
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                    }
                    
                    // 최종 차량 정보 수정 버튼
                    Button(action: updateCarInfo) {
                        gradientButtonLabel("차량 정보 수정 완료", colors: [Color.purple, Color.indigo])
                    }
                    .buttonStyle(PressableButtonStyle())
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("차량 정보 수정")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(""),
                    message: Text(updateMessage),
                    dismissButton: .default(Text("확인"), action: {
                        // 차량 정보 수정 성공 메시지일 때만 뒤로가기
                        if updateMessage == "차량 정보가 성공적으로 수정되었습니다." {
                            presentationMode.wrappedValue.dismiss()
                        }
                    })
                )
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImages: $newImages)
            }
        }
        .onAppear(perform: loadInitialValues)
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
    
    // MARK: - API 호출 및 기타 함수들
    private func loadInitialValues() {
        type = car.type
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
        currentImages = car.images ?? []
        imageOrder = currentImages
        currentRepresentativeImageUrl = car.representativeImageUrl
    }
    
    private func refreshCarImages() {
        guard let url = URL(string: API.car + "\(carId)") else {
            updateMessage = "잘못된 서버 주소입니다."
            showAlert = true
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    updateMessage = "새 이미지 목록 불러오기 실패: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }
            if let data = data,
               let updatedCar = try? JSONDecoder().decode(CarDetail.self, from: data) {
                DispatchQueue.main.async {
                    currentImages = updatedCar.images ?? []
                    imageOrder = currentImages
                    currentRepresentativeImageUrl = updatedCar.representativeImageUrl
                }
            }
        }.resume()
    }
    
    private func moveImage(from source: IndexSet, to destination: Int) {
        imageOrder.move(fromOffsets: source, toOffset: destination)
    }
    
    private func updateImageOrder() {
        let order = imageOrder.map { $0.id }
        guard let url = URL(string: API.car + "\(carId)/images/order") else {
            updateMessage = "잘못된 서버 주소입니다."
            showAlert = true
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: order, options: [])
            request.httpBody = jsonData
        } catch {
            updateMessage = "데이터 변환 오류"
            showAlert = true
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    updateMessage = "이미지 순서 변경 실패: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    updateMessage = "이미지 순서가 변경되었습니다."
                    currentImages = imageOrder
                    updateSuccess = true
                    showAlert = true
                } else {
                    updateMessage = "이미지 순서 변경 실패: 서버 오류"
                    showAlert = true
                }
            }
        }.resume()
    }
    
    private func updateCarInfo() {
        let requiredFields = [type, brand, model, fuelType, carNumber, insuranceHistory, inspectionHistory, color, transmission, region, contactNumber]
        if requiredFields.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            updateMessage = "모든 필드를 입력해주세요."
            updateSuccess = false
            showAlert = true
            return
        }
        guard let yearInt = Int(year),
              let mileageInt = Int(mileage),
              let priceInt = Int(price),
              let insuranceHistoryInt = Int(insuranceHistory),
              let inspectionHistoryInt = Int(inspectionHistory) else {
            updateMessage = "올바른 숫자를 입력하세요."
            updateSuccess = false
            showAlert = true
            return
        }
        let carDetails: [String: Any] = [
            "type": type,
            "brand": brand,
            "model": model,
            "year": yearInt,
            "mileage": mileageInt,
            "fuelType": fuelType,
            "price": priceInt,
            "carNumber": carNumber,
            "insuranceHistory": insuranceHistoryInt,
            "inspectionHistory": inspectionHistoryInt,
            "color": color,
            "transmission": transmission,
            "region": region,
            "contactNumber": contactNumber
        ]
        guard let url = URL(string: API.car + "\(carId)") else {
            updateMessage = "잘못된 서버 주소입니다."
            updateSuccess = false
            showAlert = true
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: carDetails, options: [])
            request.httpBody = jsonData
        } catch {
            updateMessage = "데이터 변환 오류"
            updateSuccess = false
            showAlert = true
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    updateMessage = "네트워크 오류: \(error.localizedDescription)"
                    updateSuccess = false
                    showAlert = true
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    updateMessage = "차량 정보가 성공적으로 수정되었습니다."
                    updateSuccess = true
                    showAlert = true
                } else {
                    let errMsg = data.flatMap { String(data: $0, encoding: .utf8) } ?? "알 수 없는 오류"
                    updateMessage = "차량 정보 수정 실패: \(errMsg)"
                    updateSuccess = false
                    showAlert = true
                }
            }
        }.resume()
    }
    
    private func updateThumbnail(imageId: Int) {
        guard let url = URL(string: API.car + "\(carId)/thumbnail/\(imageId)") else {
            updateMessage = "잘못된 서버 주소입니다."
            updateSuccess = false
            showAlert = true
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    updateMessage = "대표 이미지 변경 실패: \(error.localizedDescription)"
                    updateSuccess = false
                    showAlert = true
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    updateMessage = "대표 이미지가 변경되었습니다."
                    if let idx = currentImages.firstIndex(where: { $0.id == imageId }) {
                        currentRepresentativeImageUrl = currentImages[idx].fullImageUrl
                    }
                    updateSuccess = true
                    showAlert = true
                } else {
                    updateMessage = "대표 이미지 변경 실패: 서버 오류"
                    updateSuccess = false
                    showAlert = true
                }
            }
        }.resume()
    }
    
    private func addNewImages() {
        guard let url = URL(string: API.car + "\(carId)/images") else {
            updateMessage = "잘못된 서버 주소입니다."
            updateSuccess = false
            showAlert = true
            return
        }
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        for (index, image) in newImages.enumerated() {
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
                    updateMessage = "이미지 업로드 실패: \(error.localizedDescription)"
                    updateSuccess = false
                    showAlert = true
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    updateMessage = "새 이미지가 업로드되었습니다."
                    newImages.removeAll()
                    refreshCarImages()
                    updateSuccess = true
                    showAlert = true
                } else {
                    updateMessage = "이미지 업로드 실패: 서버 오류"
                    updateSuccess = false
                    showAlert = true
                }
            }
        }.resume()
    }
    
    private func deleteImage(imageId: Int) {
        if let idx = currentImages.firstIndex(where: { $0.id == imageId }),
           currentImages[idx].fullImageUrl == currentRepresentativeImageUrl {
            updateMessage = "대표 이미지는 제거할 수 없습니다"
            updateSuccess = false
            showAlert = true
            return
        }
        
        guard let url = URL(string: API.car + "\(carId)/images/\(imageId)") else {
            updateMessage = "잘못된 서버 주소입니다."
            updateSuccess = false
            showAlert = true
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    updateMessage = "이미지 삭제 실패: \(error.localizedDescription)"
                    updateSuccess = false
                    showAlert = true
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    updateMessage = "이미지가 삭제되었습니다."
                    if let idx = currentImages.firstIndex(where: { $0.id == imageId }) {
                        currentImages.remove(at: idx)
                    }
                    if let idx = imageOrder.firstIndex(where: { $0.id == imageId }) {
                        imageOrder.remove(at: idx)
                    }
                    updateSuccess = true
                    showAlert = true
                } else {
                    updateMessage = "이미지 삭제 실패: 서버 오류"
                    updateSuccess = false
                    showAlert = true
                }
            }
        }.resume()
    }
}

// MARK: - 공용 그라데이션 버튼 라벨
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
