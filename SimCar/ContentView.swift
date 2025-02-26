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
    
    /// 선택된 탭의 아이콘과 텍스트 색상을 hex 문자열로 지정
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        // 기본 그림자(테두리) 제거
        appearance.shadowColor = .clear
        
        // 선택되지 않은 상태: 아이콘, 텍스트 색상
        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        // 선택된 상태: 아이콘, 텍스트를 사용자가 지정한 hex 색상 (예: "#FF0000")
        let selectedColor = UIColor(Color(hex: "#9575CD"))
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor,
            .font: UIFont.boldSystemFont(ofSize: 12)]
        
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        UITabBar.appearance().standardAppearance = appearance
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


