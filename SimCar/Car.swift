import SwiftUI


struct Car: Identifiable, Codable {
    var id = UUID()
    var type: String // 차량 유형 추가
    var imageUrl: String // 이미지 URL
    var brand: String // 제조사
    var model: String // 모델
    var year: Int // 연식
    var mileage: Int // 주행거리
    var fuelType: String // 연료 종류
    var price: Int // 가격
    var carNumber: String // 차량 번호
    var insuranceHistory: Int // 보험 이력
    var inspectionHistory: Int // 검사 이력
    var color: String // 색상
    var transmission: String // 변속기 종류
    var region: String // 지역
    var contactNumber: String // 연락처
    var sellerName: String? // 판매자
    var createdAt: String?
    var updatedAt: String?
}

struct CarModel: Identifiable, Codable {
    var id: Int
    var type: String
    var price: Int
    var brand: String
    var model: String
    var year: Int
    var imageUrl: String       // 서버에서 받은 값 (예: "/uploads/cars/xxx.png")
    var region: String?
    var createdAt: String

    // 전체 URL을 반환하는 계산 프로퍼티
    var fullImageUrl: String {
        if imageUrl.hasPrefix("http") {
            return imageUrl
        } else {
            return "https://simcar.kro.kr" + imageUrl
        }
    }
}

struct CarImage: Identifiable, Codable {
    var id: Int
    var originalFileName: String
    var filePath: String
    var thumbnail: Bool  // JSON에서는 "thumbnail"으로 내려옴

    // 상대 경로에 base URL을 붙여 전체 URL 생성
    var fullImageUrl: String {
        return "https://simcar.kro.kr" + filePath
        // https://simcar.kro.kr
    }
}

struct CarDetail: Identifiable, Codable {
    var id: Int
    var type: String
    var images: [CarImage]?   // 여러 이미지
    var brand: String
    var model: String
    var year: Int
    var mileage: Int?
    var fuelType: String?
    var price: Int
    var carNumber: String
    var insuranceHistory: Int?
    var inspectionHistory: Int?
    var color: String
    var transmission: String
    var region: String?
    var contactNumber: String?
    var sellerName: String?
    var createdAt: String?
    var updatedAt: String?
    
    // 대표 이미지를 썸네일 우선으로 반환 (없으면 첫 번째 이미지 사용)
    var representativeImageUrl: String? {
        guard let images = images, !images.isEmpty else { return nil }
        if let thumb = images.first(where: { $0.thumbnail }) {
            return thumb.fullImageUrl
        }
        return images.first?.fullImageUrl
    }
}
