import SwiftUI

@main
struct MyApp: App {
    @State private var showSplash = true  // 스플래시 화면을 먼저 표시
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onAppear {
                        // 2초 후에 ReFontMainView로 전환
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                ReFontMainView()
            }
        }
    }
}
