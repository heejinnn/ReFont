import SwiftUI
import PDFKit
import Vision

struct ReFontMainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var showDocumentPicker = false
    @State private var showModifiedPdf = false
    @State private var selectedFont: String = "Helvetica"  // ✅ 기본 폰트 설정
    @State private var showFontPicker = false // ✅ 바텀시트 표시 여부

    let fonts = ["Helvetica", "Courier", "MarkerFelt-Thin", "Times New Roman", "Arial"]
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack {
                    Button("Upload Your PDF") {
                        showDocumentPicker = true
                    }
                    .padding()
                    
                    if let pdfDocument = viewModel.pdfDocument {
                        PdfKitView(document: pdfDocument)
                            .frame(height: 500)
                    }
                    
                    // ✅ 폰트 선택 버튼
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
                    
                    Button("폰트 변경하여 PDF 저장") {
                        viewModel.createNewPDFWithModifiedFont(fontName: selectedFont)
                    }
                    .padding()
                    
                    if let pdfURL = viewModel.pdfURL {
                        NavigationLink("변환된 PDF 보기", value: pdfURL)
                            .padding()
                    }
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker { url in
                    viewModel.loadPDF(from: url)
                }
            }
            .sheet(isPresented: $showFontPicker) {  // 폰트 선택 바텀시트
                FontPickerView(selectedFont: $selectedFont, showFontPicker: $showFontPicker, fonts: fonts)
            }
            .navigationDestination(for: URL.self) { url in
                ModifiedPdfView(pdfURL: url)
            }
        }
    }
}

// ✅ 폰트 선택 바텀시트 뷰
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
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .frame(maxHeight: 300)
            
            Button("닫기") {
                showFontPicker = false
            }
            .padding()
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
}

