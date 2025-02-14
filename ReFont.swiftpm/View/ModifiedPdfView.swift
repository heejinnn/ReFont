
import SwiftUI
import PDFKit

struct ModifiedPdfView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showFontPicker = false
    @State private var selectedFont: String = "Helvetica"  // 기본 폰트 설정
    @State private var temporaryURL: URL? = nil
    
    private let fonts = ["Helvetica", "Courier", "MarkerFelt-Thin", "Times New Roman", "Arial"]
    
    var body: some View {
        ScrollView{
            VStack {
                Text("변환된 PDF 미리보기")
                    .font(.headline)
                    .padding()
                
                HStack{
                    Button(action: {
                        showFontPicker.toggle()
                    }) {
                        Text("선택한 폰트: \(selectedFont)")
                            .font(.custom(selectedFont, size: 20))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Button("폰트 변경") {
                        viewModel.createNewPDFWithModifiedFont(fontName: selectedFont)
                        createTemporaryURL()
                    }
                    .padding()
                }
                
                if viewModel.isProcessing {
                    ProgressView("PDF 생성 중...")
                        .padding()
                }
                
                if let modifiedDocument = viewModel.modifiedPdfDocument {
                    PdfKitView(document: modifiedDocument)
                        .frame(height: 500)
                        .transition(.opacity)
                    
                    if let url = temporaryURL {
                        ShareLink(item: url) {
                            Text("변환된 PDF 다운로드")
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $showFontPicker) {  // 폰트 선택 바텀시트
            FontPickerView(selectedFont: $selectedFont, showFontPicker: $showFontPicker, fonts: fonts)
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
