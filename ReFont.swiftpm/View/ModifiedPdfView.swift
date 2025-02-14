
import SwiftUI
import PDFKit

struct ModifiedPdfView: View {
    let pdfURL: URL
    
    var body: some View {
        VStack {
            Text("변환된 PDF 미리보기")
                .font(.headline)
                .padding()
            
            PdfKitView(document: PDFDocument(url: pdfURL)!)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
