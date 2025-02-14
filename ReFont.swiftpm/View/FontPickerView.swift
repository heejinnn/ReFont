
import SwiftUI

struct FontPickerView: View {
    @Binding var selectedFont: String
    @Binding var showFontPicker: Bool
    let fonts: [String]

    var body: some View {
        VStack(spacing: 20) {
            Text("폰트 선택")
                .font(.headline)
                .padding()
            
            ScrollView {
                VStack {
                    ForEach(fonts, id: \.self) { font in
                        Button(action: {
                            selectedFont = font
                            showFontPicker = false
                        }) {
                            Text(font)
                                .font(.custom(font, size: 20))
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
            
            Button("닫기") {
                showFontPicker = false
            }
            .foregroundStyle(.black)
            .padding()
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
}
