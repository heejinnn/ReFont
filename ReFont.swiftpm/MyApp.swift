import SwiftUI

@main
struct MyApp: App {
    @State private var showSplash = true 
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
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
