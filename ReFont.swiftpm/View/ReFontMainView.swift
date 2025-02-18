import SwiftUI
import PDFKit
import Vision

struct ReFontMainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var showDocumentPicker = false
    @State private var showImagePicker = false
    @State private var isLoading = false
    @State private var selectedImage: UIImage?
    @State private var showSourceSelection = false
    @State private var selectedSourceType: UIImagePickerController.SourceType = .photoLibrary
    
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
                        showImagePicker = true
                        isLoading = true
                        viewModel.pdfDocument = nil
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isLoading = false
                            }
                        }
                    }) {
                        Label("Upload Your Image", systemImage: "square.and.arrow.up")
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
                        ProgressView("Loading File...")
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
                        
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 550)
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
            .actionSheet(isPresented: $showImagePicker) {
                ActionSheet(
                    title: Text("Choose an option"),
                    buttons: [
                        .default(Text("Photo Library")) {
                            selectedSourceType = .photoLibrary
                            showSourceSelection = true
                        },
                        .default(Text("Camera")) {
                            selectedSourceType = .camera
                            showSourceSelection = true
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showSourceSelection) {
                ImagePickerController(sourceType: selectedSourceType) { selectedImage in
                    showImagePicker = false
                    self.selectedImage = selectedImage
                    viewModel.extractTextFromDocument(selectedImage)
                }
            }
        }
    }
    
    private var ConvertedDocumentButton: some View{
        NavigationLink(destination: ModifiedPdfView(viewModel: viewModel)) {
            Text("View Converted Document →")
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



