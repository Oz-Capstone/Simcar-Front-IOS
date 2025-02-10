import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSettings: UserSettings // UserSettings 참조
    @State private var selectedTab = 0 // 현재 선택된 탭 인덱스

    var body: some View {
        TabView(selection: $selectedTab) {
            BuyCarView()
                .tabItem {
                    Label("내차사기", systemImage: "1.circle")
                }
                .tag(0) // 태그 추가

            SellCarView(selectedTab: $selectedTab) // SellCarView에 selectedTab 전달
                .tabItem {
                    Label("내차팔기", systemImage: "2.circle")
                }
                .tag(1) // 태그 추가

            MyPageView()
                .tabItem {
                    Label("마이페이지", systemImage: "3.circle")
                }
                .tag(2) // 태그 추가
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    @StateObject private var userSettings = UserSettings() // UserSettings 인스턴스 생성
    static var previews: some View {
        ContentView().environmentObject(UserSettings())
    }
}
