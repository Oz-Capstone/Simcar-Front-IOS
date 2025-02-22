import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSettings: UserSettings
    @State private var selectedTab = 0

    init() {
        configureTabBarAppearance()
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
    
    /// iOS 15+에서 Tab Bar Appearance를 커스터마이징하는 메서드
    private func configureTabBarAppearance() {
        // TabBarAppearance 인스턴스 생성
        let appearance = UITabBarAppearance()
        // 배경색/불투명도 설정
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        // 기본 테두리(Shadow) 제거
        appearance.shadowColor = .clear
        
        // 탭 아이콘 색상
        // (선택/비선택 상태는 StackedLayoutAppearance에 지정)
        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        appearance.stackedLayoutAppearance.selected.iconColor = .black
        
        // 텍스트 컬러
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        // TabBarAppearance를 적용
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        UITabBar.appearance().standardAppearance = appearance

    }
}

//struct ContentView_Previews: PreviewProvider {
//    @StateObject static var userSettings = UserSettings()
//    static var previews: some View {
//        ContentView()
//            .environmentObject(userSettings)
//    }
//}
