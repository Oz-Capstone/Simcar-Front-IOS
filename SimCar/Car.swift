import SwiftUI

struct Car: Identifiable {
    var id = UUID()
    var imageUrl: String // 이미지 URL
    var manufacturer: String
    var model: String
    var year: Int
    var mileage: Int
    var fuel: String
    var price: Int
}

// 예시 데이터
let carList = [
    Car(imageUrl: "https://ci.encar.com/carpicture/carpicture03/pic3883/38835215_001.jpg?impolicy=heightRate&rh=384&cw=640&ch=384&cg=Center&wtmk=https://ci.encar.com/wt_mark/w_mark_04.png&t=20250108175335", manufacturer: "현대", model: "아반떼", year: 2020, mileage: 15000, fuel: "가솔린", price: 15000000),
    Car(imageUrl: "https://ci.encar.com/carpicture/carpicture04/pic3874/38743332_001.jpg?impolicy=heightRate&rh=384&cw=640&ch=384&cg=Center&wtmk=https://ci.encar.com/wt_mark/w_mark_04.png&t=20241220165532", manufacturer: "기아", model: "모닝", year: 2019, mileage: 20000, fuel: "가솔린", price: 9000000),
    Car(imageUrl: "https://ci.encar.com/carpicture/carpicture06/pic3866/38662076_001.jpg?impolicy=heightRate&rh=384&cw=640&ch=384&cg=Center&wtmk=https://ci.encar.com/wt_mark/w_mark_04.png&t=20241205180052", manufacturer: "BMW", model: "i8", year: 2016, mileage: 79601, fuel: "하이브리드", price: 69500000),
    Car(imageUrl: "https://ci.encar.com/carpicture/carpicture04/pic3814/38147222_001.jpg?impolicy=heightRate&rh=384&cw=640&ch=384&cg=Center&wtmk=https://ci.encar.com/wt_mark/w_mark_04.png&t=20241002155231", manufacturer: "벤츠", model: "G-클래스", year: 2021, mileage: 10426, fuel: "가솔린", price: 229000000),
    Car(imageUrl: "https://ci.encar.com/carpicture/carpicture05/pic3795/37952132_001.jpg?impolicy=heightRate&rh=384&cw=640&ch=384&cg=Center&wtmk=https://ci.encar.com/wt_mark/w_mark_04.png&t=20240807151846", manufacturer: "아우디", model: "RS7", year: 2022, mileage: 24954, fuel: "가솔린", price: 125000000),

]

