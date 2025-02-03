import SwiftUI

struct FavoriteCarView: View {
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("찜한 차량 조회")
                        .font(.largeTitle)
                        .padding()
                    
                    // 차량 리스트
                    List(carList) { car in
                        NavigationLink(destination: DetailCarView(car: car)) {
                            CarRow(car: car)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarTitleDisplayMode(.inline) // 제목을 인라인으로 표시
        }
    }
}


