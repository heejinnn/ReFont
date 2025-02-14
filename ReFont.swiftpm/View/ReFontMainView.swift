import SwiftUI
import PDFKit
import Vision

struct ReFontMainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var showDocumentPicker = false
    @State private var showModifiedPdf = false
    @State private var selectedFont: String = "Helvetica"  // ✅ 기본 폰트 설정
    let fonts = ["Helvetica", "Courier", "MarkerFelt-Thin", "Times New Roman", "Arial"]
    
    var body: some View {
        NavigationStack{
            VStack {
                Button("Upload Your PDF") {
                    showDocumentPicker = true
                }
                .padding()
                
                if let pdfDocument = viewModel.pdfDocument {
                    PdfKitView(document: pdfDocument)
                        .frame(height: 500)
                }
                
                // ✅ 폰트 선택 Picker 추가
                Picker("폰트 선택", selection: $selectedFont) {
                    ForEach(fonts, id: \.self) { font in
                        Text(font).font(.custom(font, size: 16))  // 선택 UI에서 폰트 적용
                    }
                }
                .pickerStyle(MenuPickerStyle()) // ✅ 메뉴 스타일 적용
                .padding()
                
                Button("폰트 변경하여 PDF 저장") {
                    viewModel.createNewPDFWithModifiedFont(fontName: selectedFont)
                }
                .padding()
                
                if let pdfURL = viewModel.pdfURL {
                    ShareLink(item: pdfURL) {
                        Text("변환된 PDF 다운로드")
                    }
                    .padding()
                    
                    NavigationLink("변환된 PDF 보기", value: pdfURL)
                        .padding()
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker { url in
                    viewModel.loadPDF(from: url)
                }
            }
            .navigationDestination(for: URL.self) { url in
                ModifiedPdfView(pdfURL: url)
            }
        }
    }
}
