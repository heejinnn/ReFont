
import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: UIColor
    @Binding var showColorPicker: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Color")
                .font(.headline)
                .padding()
                .foregroundStyle(.black)
            
            ScrollView {
                VStack {
                    ForEach(ColorType.allCases, id: \.self) { type in
                        Button(action: {
                            selectedColor = type.uiColor
                            showColorPicker = false
                        }) {
                            Text(type.rawValue)
                                .font(.system(size: 20))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(Color(uiColor: type.uiColor))
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .frame(maxHeight: 350)
            
            Button("Close") {
                showColorPicker = false
            }
            .foregroundStyle(.black)
            .padding()
        }
        .background(Color.white)
        .padding()
        .presentationDetents([.medium, .large])
    }
}
