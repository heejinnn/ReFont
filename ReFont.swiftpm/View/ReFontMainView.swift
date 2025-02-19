import SwiftUI
import PDFKit
import Vision

struct ReFontMainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var showDocumentPicker = false
    @State private var isLoading = false
    @State private var selectedImage: [UIImage]?
    @State private var showTextScanner = false
    @State private var showDocumentScanner = false
    @State private var showBottomSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Text("Transform Document Fonts")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.vertical, 10)
                    .foregroundStyle(.black)
                
                ScrollView{
                    Text("Upload your Document and choose from a variety of fonts to give your document a fresh look.")
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                    
                    Button(action: {
                        showDocumentPicker = true
                        isLoading = true
                        selectedImage = nil
                        viewModel.imageDocument = nil
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isLoading = false
                            }
                        }
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
                    
                    Button(action: {
                        showBottomSheet = true
                        isLoading = true
                        viewModel.pdfDocument = nil
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isLoading = false
                            }
                        }
                    }) {
                        Label("Scan Document & Text", systemImage: "camera.viewfinder")
                            .font(.system(size: 16, weight: .semibold))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.cyan)
                            .foregroundStyle(.white)
                            .cornerRadius(15)
                            .shadow(radius: 3)
                    }
                    .padding(.horizontal, 20)

                    if isLoading{
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundStyle(.gray)
                            .padding()
                    }else{
                        if let pdfDocument = viewModel.pdfDocument {
                            PdfKitView(document: pdfDocument)
                                .frame(height: 550)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 10)
                                .shadow(radius: 3)
                            
                            ConvertedDocumentButton
                        }
                        
                        if let text = viewModel.extractedText {
                            
                            HStack{
                                Text(text)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.black)
                                    .padding()
                            }
                            .frame(height: 550)
                            .frame(maxWidth: .infinity)
                            .border(.gray)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .shadow(radius: 3)
                            
                            ConvertedDocumentButton
                        }
                    }
                }
            }
            .padding(.vertical, 20)
            .background(Color.white)
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPickerView { url in
                    viewModel.extractTextFromDocument(url)
                }
            }
            .overlay(
                BottomSheetView(
                    isPresented: $showBottomSheet,
                    actions: [
                        ActionSheetButton(title: "Scan Document") {
                            showDocumentScanner = true
                        },
                        ActionSheetButton(title: "Scan Text") {
                            showTextScanner = true
                        }
                    ]
                )
            )
            .sheet(isPresented: $showTextScanner) {
                
                VStack{
                    TextScannerView(
                        didFinishScanning: { scannedText in
                            showTextScanner = false
                            viewModel.extractedText = scannedText
                        },
                        didCancelScanning: {
                            showTextScanner = false
                        }
                    )
                    
                    Text("Touch the text you want to scan")
                        .font(.system(size: 16, weight: .semibold))
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .sheet(isPresented: $showDocumentScanner) {
                DocumentScannerView(
                    didFinishScanning: { scannedImage in
                        showDocumentScanner = false
                        self.selectedImage = scannedImage
                        viewModel.extractTextFromDocument(scannedImage)
                    },
                    didCancelScanning: {
                        showDocumentScanner = false
                    }
                )
            }
        }
    }
    
    private var ConvertedDocumentButton: some View{
        NavigationLink(destination: ModifiedDocumentView(viewModel: viewModel)) {
            Text("View Converted Document →")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(15)
                .shadow(radius: 3)
            
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}



