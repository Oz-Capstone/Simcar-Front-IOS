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
