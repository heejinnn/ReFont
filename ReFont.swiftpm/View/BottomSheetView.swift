import SwiftUI

struct BottomSheetView: View {
    @Binding var isPresented: Bool
    let actions: [ActionSheetButton]

    var body: some View {
        if isPresented {
            VStack {
                Spacer()
                VStack(spacing: 0) {
                    ForEach(actions, id: \.title) { action in
                        Button(action: {
                            action.action()
                            isPresented = false
                        }) {
                            Text(action.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                        }
                        Divider()
                    }
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.red)
                    }
                }
                .background(Color(.lightGray))
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding()
            }
            .background(Color.black.opacity(0.4).ignoresSafeArea())
            .onTapGesture {
                isPresented = false
            }
        }
    }
}

struct ActionSheetButton {
    let title: String
    let action: () -> Void
}

