
import SwiftUI
import PDFKit

struct ModifiedPdfView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showFontPicker = false
    @State private var showColorPicker = false
    @State private var selectedFont: FontType? = nil
    @State private var selectedColor: UIColor = .black
    @State private var temporaryURL: URL? = nil
    @State private var modifiedPdfDocument: PDFDocument?
    @State private var includeOriginalLayout = true

    var body: some View {
        VStack {
            Text("Convert Your PDF")
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical, 10)
                .foregroundStyle(.black)

            ScrollView {
                VStack(spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 15) {
                        
                        // Font selection section
                        VStack(alignment: .leading){
                            Text("Choose a Font")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.gray)
                            
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
                        
                        // Color selection section
                        VStack(alignment: .leading){
                            Text("Choose a Color")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.gray)
                            
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
                        
                        Toggle("Maintain original layout", isOn: $includeOriginalLayout)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.gray)
                        
                        Button(action: {
                            if let font = selectedFont {
                                viewModel.createNewPDFWithModifiedFont(fontName: font.rawValue, color: selectedColor, includeOriginalLayout: includeOriginalLayout){ document in
                                    if document != nil{
                                        self.modifiedPdfDocument = document
                                        createTemporaryURL()
                                    }
                                }
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

                    // Preview converted PDF
                    if let modifiedDocument = self.modifiedPdfDocument {
                        PdfKitView(document: modifiedDocument)
                            .frame(height: 550)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .shadow(radius: 3)
                            .transition(.opacity)

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
        .background(Color.white)
        .sheet(isPresented: $showFontPicker) {
            FontPickerView(selectedFont: $selectedFont, showFontPicker: $showFontPicker, fonts: FontType.allCases)
        }
        .sheet(isPresented: $showColorPicker) {
            ColorPickerView(selectedColor: $selectedColor, showColorPicker: $showColorPicker)
        }
    }
    
    private func createTemporaryURL() {
        guard let modifiedDocument = self.modifiedPdfDocument,
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
    
    private func colorName(color: UIColor) -> String {
        let colorOption =  ColorType(from: color)
        return colorOption?.rawValue ?? "Black"
    }
}
