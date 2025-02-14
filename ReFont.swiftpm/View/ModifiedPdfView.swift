
import SwiftUI
import PDFKit

struct ModifiedPdfView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showFontPicker = false
    @State private var selectedFont: String = ""  // 기본 폰트 설정
    @State private var temporaryURL: URL? = nil
    
    private let fonts = ["Helvetica", "Courier", "MarkerFelt-Thin", "Times New Roman", "Arial"]
    
    var body: some View {
        ScrollView{
            VStack {
                
                Spacer()

                HStack{
                    Button(action: {
                        showFontPicker.toggle()
                    }) {
                        Text("Selected Font: \(selectedFont)")
                            .font(.custom(selectedFont, size: 20))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.black)
                    }
                    
                    Button("Change Font") {
                        if selectedFont != "" {
                            viewModel.createNewPDFWithModifiedFont(fontName: selectedFont)
                            createTemporaryURL()
                        }
                    }
                    .padding()
                    .foregroundStyle(.white)
                    .background(.cyan)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 10)
                
                if viewModel.isProcessing {
                    ProgressView("Generating PDF...")
                        .padding()
                }
                
                if let modifiedDocument = viewModel.modifiedPdfDocument {
                    PdfKitView(document: modifiedDocument)
                        .frame(height: 500)
                        .transition(.opacity)
                    
                    if let url = temporaryURL {
                        ShareLink(item: url) {
                            Text("Download Converted PDF")
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
        }
        .navigationTitle("Preview of Converted PDF")
        .sheet(isPresented: $showFontPicker) {  // 폰트 선택 바텀시트
            FontPickerView(selectedFont: $selectedFont, showFontPicker: $showFontPicker, fonts: fonts)
        }
        .onAppear{
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
