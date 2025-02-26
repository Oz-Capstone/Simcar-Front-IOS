//
//  SimCarApp.swift
//  SimCar
//
//  Created by 김건우 on 2025/01/13.
//

import SwiftUI

@main
struct SimCarApp: App {
    @StateObject private var userSettings = UserSettings() // UserSettings 인스턴스 생성
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(UserSettings())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    @StateObject static var userSettings = UserSettings()
    static var previews: some View {
        ContentView()
            .environmentObject(userSettings)
    }
}
