import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSettings: UserSettings
    @State private var selectedTab = 0

    init() {
        // 탭 바의 배경색을 흰색으로 설정
        UITabBar.appearance().backgroundColor = UIColor.white
        // barTintColor 도 설정할 수 있습니다.
        UITabBar.appearance().barTintColor = UIColor.white
        // 선택되지 않은 아이콘 색상 (원하는 색으로 조정)
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        // 선택된 탭의 아이콘 및 텍스트 색상
        UITabBar.appearance().tintColor = UIColor.black
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            BuyCarView(selectedTab: $selectedTab)
                .tabItem {
                    Label("내차사기", systemImage: "car.fill")
                }
                .tag(0)
            
            SellCarView(selectedTab: $selectedTab)
                .tabItem {
                    Label("내차팔기", systemImage: "dollarsign.circle.fill")
                }
                .tag(1)
            
            MyPageView(selectedTab: $selectedTab)
                .tabItem {
                    Label("마이페이지", systemImage: "person.crop.circle.fill")
                }
                .tag(2)
        }
    }
}
//
//struct ContentView_Previews: PreviewProvider {
//    @StateObject static var userSettings = UserSettings()
//    static var previews: some View {
//        ContentView()
//            .environmentObject(userSettings)
//    }
//}
