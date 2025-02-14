import SwiftUI
import PDFKit
import Vision

struct ReFontMainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var showDocumentPicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Text("Transform Your PDF Fonts")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.vertical, 10)
                
                ScrollView{
                    Text("Upload your PDF and choose from a variety of fonts to give your document a fresh look.")
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                    
                    Button(action: {
                        showDocumentPicker = true
                    }) {
                        Label("Upload Your PDF", systemImage: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.cyan)
                            .foregroundStyle(.white)
                            .cornerRadius(15)
                            .shadow(radius: 3)
                    }
                    .padding(.horizontal, 20)

//                    if isLoading{
//                        ProgressView("Loading PDF...")
//                            .progressViewStyle(CircularProgressViewStyle())
//                            .padding()
//                    }
                    
                    if let pdfDocument = viewModel.pdfDocument {
                        PdfKitView(document: pdfDocument)
                            .frame(height: 550)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .shadow(radius: 3)
                        
                        NavigationLink(destination: ModifiedPdfView(viewModel: viewModel)) {
                            Text("View Converted PDF →")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.cyan)
                                .cornerRadius(15)
                                .shadow(radius: 3)
                            
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    }
                }
            }
            .padding(.vertical, 20)
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker { url in
                    viewModel.loadPDF(from: url)
                }
            }
        }
    }
}



