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
    var insuranceHistory: String // 보험 이력
    var inspectionHistory: String // 검사 이력
    var color: String // 색상
    var transmission: String // 변속기 종류
    var region: String // 지역
    var contactNumber: String // 연락처
}

// 예시 데이터
let carList = [
    Car(type: "세단", imageUrl: "https://ci.encar.com/carpicture/carpicture03/pic3883/38835215_001.jpg?impolicy=heightRate&rh=384&cw=640&ch=384&cg=Center&wtmk=https://ci.encar.com/wt_mark/w_mark_04.png&t=20250108175335", brand: "현대", model: "아반떼", year: 2020, mileage: 15000, fuelType: "가솔린", price: 15000000, carNumber: "12가 3456", insuranceHistory: "보험 이력 없음", inspectionHistory: "검사 이력 없음", color: "흰색", transmission: "자동", region: "서울", contactNumber: "010-1234-5678"),
    
    Car(type: "경차", imageUrl: "https://ci.encar.com/carpicture/carpicture04/pic3874/38743332_001.jpg?impolicy=heightRate&rh=384&cw=640&ch=384&cg=Center&wtmk=https://ci.encar.com/wt_mark/w_mark_04.png&t=20241220165532", brand: "기아", model: "모닝", year: 2019, mileage: 20000, fuelType: "가솔린", price: 9000000, carNumber: "34나 5678", insuranceHistory: "보험 이력 있음", inspectionHistory: "검사 이력 있음", color: "노란색", transmission: "자동", region: "부산", contactNumber: "010-8765-4321"),
    
    Car(type: "스포츠카", imageUrl: "https://ci.encar.com/carpicture/carpicture06/pic3866/38662076_001.jpg?impolicy=heightRate&rh=384&cw=640&ch=384&cg=Center&wtmk=https://ci.encar.com/wt_mark/w_mark_04.png&t=20241205180052", brand: "BMW", model: "i8", year: 2016, mileage: 79601, fuelType: "하이브리드", price: 69500000, carNumber: "56다 7890", insuranceHistory: "보험 이력 있음", inspectionHistory: "검사 이력 있음", color: "파란색", transmission: "자동", region: "대구", contactNumber: "010-1111-2222"),
    
    Car(type: "SUV", imageUrl: "https://ci.encar.com/carpicture/carpicture04/pic3814/38147222_001.jpg?impolicy=heightRate&rh=384&cw=640&ch=384&cg=Center&wtmk=https://ci.encar.com/wt_mark/w_mark_04.png&t=20241002155231", brand: "벤츠", model: "G-클래스", year: 2021, mileage: 10426, fuelType: "가솔린", price: 229000000, carNumber: "78라 9012", insuranceHistory: "보험 이력 없음", inspectionHistory: "검사 이력 없음", color: "검정", transmission: "자동", region: "인천", contactNumber: "010-3333-4444"),
    
    Car(type: "스포츠카", imageUrl: "https://ci.encar.com/carpicture/carpicture05/pic3795/37952132_001.jpg?impolicy=heightRate&rh=384&cw=640&ch=384&cg=Center&wtmk=https://ci.encar.com/wt_mark/w_mark_04.png&t=20240807151846", brand: "아우디", model: "RS7", year: 2022, mileage: 24954, fuelType: "가솔린", price: 125000000, carNumber: "90마 1234", insuranceHistory: "보험 이력 있음", inspectionHistory: "검사 이력 있음", color: "회색", transmission: "자동", region: "광주", contactNumber: "010-5555-6666")
]
