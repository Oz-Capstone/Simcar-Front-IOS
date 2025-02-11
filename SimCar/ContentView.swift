import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSettings: UserSettings // UserSettings 참조
    @State private var selectedTab = 0 // 현재 선택된 탭 인덱스

    var body: some View {
        TabView(selection: $selectedTab) {
            // BuyCarView에 selectedTab binding 전달
            BuyCarView(selectedTab: $selectedTab)
                .tabItem {
                    Label("내차사기", systemImage: "1.circle")
                }
                .tag(0)
            
            // SellCarView에 selectedTab binding 전달 (이미 구현된 코드)
            SellCarView(selectedTab: $selectedTab)
                .tabItem {
                    Label("내차팔기", systemImage: "2.circle")
                }
                .tag(1)
            
            MyPageView(selectedTab: $selectedTab)
                .tabItem {
                    Label("마이페이지", systemImage: "3.circle")
                }
                .tag(2)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    @StateObject static var userSettings = UserSettings() // UserSettings 인스턴스 생성
    static var previews: some View {
        ContentView()
            .environmentObject(userSettings)
    }
}
