
import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: UIColor
    @Binding var showColorPicker: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Color")
                .font(.headline)
                .padding()
            
            ScrollView {
                VStack {
                    ForEach(ColorOption.allCases, id: \.self) { colorOption in
                        Button(action: {
                            selectedColor = colorOption.uiColor
                            showColorPicker = false
                        }) {
                            Text(colorOption.rawValue)
                                .font(.system(size: 20))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(Color(uiColor: colorOption.uiColor))
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
        .padding()
        .presentationDetents([.medium, .large])
    }
}
