
import SwiftUI
import PDFKit

struct ModifiedPdfView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showFontPicker = false
    @State private var showColorPicker = false
    @State private var selectedFont: FontType? = nil
    @State private var selectedColor: UIColor = .black
    @State private var temporaryURL: URL? = nil

    var body: some View {
        VStack {
            Text("Convert Your PDF")
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical, 10)

            ScrollView {
                VStack(spacing: 20) {
                    // 폰트 선택 섹션
                    VStack(alignment: .leading, spacing: 10) {
                        
                        VStack{
                            Text("Choose a Font")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.black)
                            
                            Button(action: { showFontPicker.toggle() }) {
                                HStack {
                                    Text("Selected Font: \(selectedFont?.displayName ?? "None")")
                                        .font(.custom(selectedFont?.rawValue ?? "System", size: 16))
                                        .foregroundStyle(.black)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(.gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(15)
                            }
                        }
                        
                        VStack{
                            Text("Choose a Color")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.black)
                            
                            Button(action: { showColorPicker.toggle() }) {
                                HStack {
                                    Text("Selected Color: \(colorName(color: selectedColor))")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color(selectedColor))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(.gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(15)
                            }
                        }
                        
                        Button(action: {
                            if let font = selectedFont {
                                viewModel.createNewPDFWithModifiedFont(fontName: font.rawValue, color: selectedColor)
                                createTemporaryURL()
                            }
                        }) {
                            Text("Apply Font")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedFont == nil ? Color.gray : Color.cyan)
                            
                                .cornerRadius(15)
                                .shadow(radius: 3)
                        }
                        .disabled(selectedFont == nil)
                    }
                    .padding(.horizontal, 20)

                    // 변환된 PDF 미리보기
                    if let modifiedDocument = viewModel.modifiedPdfDocument {
                        PdfKitView(document: modifiedDocument)
                            .frame(height: 550)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .shadow(radius: 3)
                            .transition(.opacity)

                        // 다운로드 버튼
                        if let url = temporaryURL {
                            ShareLink(item: url) {
                                Text("Download Converted PDF")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.cyan)
                                    .cornerRadius(15)
                                    .shadow(radius: 3)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.vertical, 20)
            }

            Spacer()
        }
        .sheet(isPresented: $showFontPicker) {
            FontPickerView(selectedFont: $selectedFont, showFontPicker: $showFontPicker, fonts: FontType.allCases)
        }
        .sheet(isPresented: $showColorPicker) {
            ColorPickerView(selectedColor: $selectedColor, showColorPicker: $showColorPicker)
        }
        
        .onAppear {
            viewModel.modifiedPdfDocument = nil
        }
    }
    
    private func createTemporaryURL() {
        guard let modifiedDocument = viewModel.modifiedPdfDocument,
              let documentData = modifiedDocument.dataRepresentation() else {
            return
        }
        
        do {
            let url = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("ModifiedFont.pdf")
            
            try documentData.write(to: url)
            temporaryURL = url
        } catch {
            print("❌ Error creating temporary URL: \(error)")
        }
    }
    
    private func colorName(color: UIColor) -> String{
        let colorOption =  ColorOption(from: color)
        return colorOption?.rawValue ?? "Black"
    }
}
