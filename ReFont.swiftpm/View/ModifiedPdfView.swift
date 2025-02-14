
import SwiftUI
import PDFKit

struct ModifiedPdfView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showFontPicker = false
    @State private var selectedFont: String = ""
    @State private var temporaryURL: URL? = nil

    private let fonts = ["Helvetica", "Courier", "MarkerFelt-Thin", "Times New Roman", "SnellRoundhand", "BradleyHandITCTT-Bold"]

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
                        Text("Choose a Font")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                        
                        Button(action: { showFontPicker.toggle() }) {
                            HStack {
                                Text("Selected Font: \(selectedFont.isEmpty ? "None" : selectedFont)")
                                    .font(.custom(selectedFont.isEmpty ? "System" : selectedFont, size: 16))
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(15)
                        }

                        Button(action: {
                            if !selectedFont.isEmpty {
                                viewModel.createNewPDFWithModifiedFont(fontName: selectedFont)
                                createTemporaryURL()
                            }
                        }) {
                            Text("Apply Font")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedFont.isEmpty ? Color.gray : Color.cyan)
                                .cornerRadius(15)
                                .shadow(radius: 3)
                        }
                        .disabled(selectedFont.isEmpty)
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
                                    .foregroundColor(.white)
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
            FontPickerView(selectedFont: $selectedFont, showFontPicker: $showFontPicker, fonts: fonts)
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
}
