import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSettings: UserSettings // UserSettings 참조
    var body: some View {
        TabView {
            BuyCarView()
                .tabItem {
                    Label("내차사기", systemImage: "1.circle")
                }
            
            SellCarView()
                .tabItem {
                    Label("내차팔기", systemImage: "2.circle")
                }
            
            MyPageView()
                .tabItem {
                    Label("마이페이지", systemImage:
                        "3.circle")
                }
        }
    }
}

