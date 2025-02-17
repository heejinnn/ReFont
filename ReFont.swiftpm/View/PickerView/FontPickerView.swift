
import SwiftUI

struct FontPickerView: View {
    @Binding var selectedFont: FontType?
    @Binding var showFontPicker: Bool
    let fonts: [FontType]

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Font")
                .font(.headline)
                .padding()
                .foregroundStyle(.black)
            
            ScrollView {
                VStack {
                    ForEach(fonts, id: \.self) { font in
                        Button(action: {
                            selectedFont = font
                            showFontPicker = false
                        }) {
                            Text(font.rawValue)
                                .font(.custom(font.rawValue, size: 20))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.black)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .frame(maxHeight: 350)
            
            Button("Close") {
                showFontPicker = false
            }
            .foregroundStyle(.black)
            .padding()
        }
        .background(Color.white)
        .padding()
        .presentationDetents([.medium, .large])
    }
}
