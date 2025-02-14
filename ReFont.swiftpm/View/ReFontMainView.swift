import SwiftUI
import PDFKit
import Vision

struct ReFontMainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var showDocumentPicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack {
                    Text("Transform Your PDF Fonts")
                        .font(.title)
                        .padding(.vertical, 5)
                    
                    Text("Upload your PDF and choose from a variety of fonts to give your document a fresh look.")
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .padding(.vertical, 5)
                    
                    Button(action: {
                        showDocumentPicker = true
                    }) {
                        Label("Upload Your PDF", systemImage: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(25)
                            .shadow(radius: 3)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    
                    if let pdfDocument = viewModel.pdfDocument {
                        PdfKitView(document: pdfDocument)
                            .frame(height: 500)
                        NavigationLink("변환된 PDF 보기", destination: ModifiedPdfView(viewModel: viewModel))
                        .padding()
                    }   
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker { url in
                    viewModel.loadPDF(from: url)
                }
            }
        }
    }
}



