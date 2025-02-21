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

    var body: some View {
        NavigationView {
            Form {
                // MARK: - 차량 정보 수정 섹션
                Section(header: Text("차량 정보 수정")) {
                    VStack(spacing: 8) {
                        TextField("차량 유형", text: $type)
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
                    VStack(spacing: 8) {
                        TextField("차량 번호", text: $carNumber)
                        TextField("보험 이력", text: $insuranceHistory)
                        TextField("검사 이력", text: $inspectionHistory)
                        TextField("색상", text: $color)
                        TextField("변속기 종류", text: $transmission)
                        TextField("지역", text: $region)
                        TextField("연락처", text: $contactNumber)
                    }
                }
                
                // MARK: - 이미지 관리 섹션
                Section(header: Text("이미지 관리")) {
                    // 순서 변경 모드 토글
                    Toggle("이미지 순서 변경 모드", isOn: $reorderMode)
                        .padding(.vertical, 4)
                    
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
                            
                            Button("순서 저장") {
                                updateImageOrder()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(6)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
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
                    
                    Button {
                        showImagePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("이미지 추가")
                        }
                    }
                    
                    if !newImages.isEmpty {
                        Button("새 이미지 업로드") {
                            addNewImages()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                
                // MARK: - 최종 차량 정보 수정 버튼
                Button(action: updateCarInfo) {
                    Text("차량 정보 수정 완료")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                if !updateMessage.isEmpty {
                    Text(updateMessage)
                        .foregroundColor(.black)
                        .padding(.vertical, 4)
                }
            }
            .navigationTitle("차량 정보 수정")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("알림"),
                    message: Text(updateMessage),
                    dismissButton: .default(Text("확인"), action: {
                        if updateMessage != "대표 이미지는 제거할 수 없습니다" {
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
    
    // 기존 차량 정보 및 이미지를 할당하는 함수
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
    
    // 서버로부터 최신 차량 정보를 받아와 이미지 목록을 업데이트하는 함수
    private func refreshCarImages() {
        guard let url = URL(string: API.car + "\(carId)") else {
            updateMessage = "잘못된 서버 주소입니다."
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    updateMessage = "새 이미지 목록 불러오기 실패: \(error.localizedDescription)"
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
    
    // MARK: - 이미지 재정렬 관련 함수
    private func moveImage(from source: IndexSet, to destination: Int) {
        imageOrder.move(fromOffsets: source, toOffset: destination)
    }
    
    private func updateImageOrder() {
        let order = imageOrder.map { $0.id }
        guard let url = URL(string: API.car + "\(carId)/images/order") else {
            updateMessage = "잘못된 서버 주소입니다."
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
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    updateMessage = "이미지 순서 변경 실패: \(error.localizedDescription)"
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    updateMessage = "이미지 순서가 변경되었습니다."
                    currentImages = imageOrder
                } else {
                    updateMessage = "이미지 순서 변경 실패: 서버 오류"
                }
            }
        }.resume()
    }
    
    // MARK: - 차량 정보 수정 API
    private func updateCarInfo() {
        let requiredFields = [type, brand, model, fuelType, carNumber, insuranceHistory, inspectionHistory, color, transmission, region, contactNumber]
        if requiredFields.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            updateMessage = "모든 필드를 입력해주세요."
            return
        }
        guard let yearInt = Int(year),
              let mileageInt = Int(mileage),
              let priceInt = Int(price),
              let insuranceHistoryInt = Int(insuranceHistory),
              let inspectionHistoryInt = Int(inspectionHistory) else {
            updateMessage = "올바른 숫자를 입력하세요."
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
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    updateMessage = "네트워크 오류: \(error.localizedDescription)"
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    updateMessage = "차량 정보가 성공적으로 수정되었습니다."
                    showAlert = true
                } else {
                    let errMsg = data.flatMap { String(data: $0, encoding: .utf8) } ?? "알 수 없는 오류"
                    updateMessage = "차량 정보 수정 실패: \(errMsg)"
                }
            }
        }.resume()
    }
    
    // MARK: - 썸네일 변경 API
    private func updateThumbnail(imageId: Int) {
        guard let url = URL(string: API.car + "\(carId)/thumbnail/\(imageId)") else {
            updateMessage = "잘못된 서버 주소입니다."
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    updateMessage = "대표 이미지 변경 실패: \(error.localizedDescription)"
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    updateMessage = "대표 이미지가 변경되었습니다."
                    if let idx = currentImages.firstIndex(where: { $0.id == imageId }) {
                        currentRepresentativeImageUrl = currentImages[idx].fullImageUrl
                    }
                } else {
                    updateMessage = "대표 이미지 변경 실패: 서버 오류"
                }
            }
        }.resume()
    }
    
    // MARK: - 새 이미지 추가 API
    private func addNewImages() {
        guard let url = URL(string: API.car + "\(carId)/images") else {
            updateMessage = "잘못된 서버 주소입니다."
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
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    updateMessage = "새 이미지가 업로드되었습니다."
                    newImages.removeAll()
                    refreshCarImages()
                } else {
                    updateMessage = "이미지 업로드 실패: 서버 오류"
                }
            }
        }.resume()
    }
    
    // MARK: - 이미지 삭제 API
    private func deleteImage(imageId: Int) {
        if let idx = currentImages.firstIndex(where: { $0.id == imageId }),
           currentImages[idx].fullImageUrl == currentRepresentativeImageUrl {
            updateMessage = "대표 이미지는 제거할 수 없습니다"
            showAlert = true
            return
        }
        
        guard let url = URL(string: API.car + "\(carId)/images/\(imageId)") else {
            updateMessage = "잘못된 서버 주소입니다."
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    updateMessage = "이미지 삭제 실패: \(error.localizedDescription)"
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
                } else {
                    updateMessage = "이미지 삭제 실패: 서버 오류"
                }
            }
        }.resume()
    }
}
