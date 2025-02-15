
import SwiftUI
import PDFKit
import Vision

class MainViewModel: ObservableObject {
    @Published var pdfDocument: PDFDocument?
    @Published var pdfURL: URL?
    @Published var extractedElements: [(text: String, frame: CGRect, page: Int)] = []
    @Published var modifiedPdfDocument: PDFDocument?

    func loadPDF(from url: URL) {
        let _ = url.startAccessingSecurityScopedResource()
        defer { url.stopAccessingSecurityScopedResource() }
        
        guard let document = PDFDocument(url: url) else {
            print("❌ PDF 로드 실패")
            return
        }
        
        self.pdfDocument = document
        extractTextFromPDF(document)
    }

    private func extractTextFromPDF(_ document: PDFDocument) {
        extractedElements.removeAll()

        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else { continue }

            let pageRect = page.bounds(for: .mediaBox)
            let originalSize = CGSize(width: pageRect.width, height: pageRect.height)
            let pageImage = page.thumbnail(of: originalSize, for: .mediaBox)

            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

                for observation in observations {
                    if let text = observation.topCandidates(1).first?.string {
                        let boundingBox = observation.boundingBox
                        let frame = CGRect(
                            x: boundingBox.origin.x * originalSize.width,
                            y: (1 - boundingBox.origin.y - boundingBox.height) * originalSize.height,
                            width: boundingBox.width * originalSize.width,
                            height: boundingBox.height * originalSize.height
                        )
                        
                        self.extractedElements.append((text: text, frame: frame, page: pageIndex))
                    }
                }
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            do {
                try VNImageRequestHandler(cgImage: pageImage.cgImage!, options: [:])
                    .perform([request])
            } catch {
                print("❌ 텍스트 인식 실패: \(error)")
            }
        }
    }
    
    func createNewPDFWithModifiedFont(fontName: String, color: UIColor) {
        
        guard let document = pdfDocument else {return}
        
        let newDocument = PDFDocument()
        
        for pageIndex in 0..<document.pageCount {
            guard let originalPage = document.page(at: pageIndex) else { continue }
            
            let pageRect = originalPage.bounds(for: .mediaBox)
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
            
            let pdfData = renderer.pdfData { context in
                context.beginPage()
                
                if let pageRef = originalPage.pageRef,
                   let cgContext = UIGraphicsGetCurrentContext() {
                    cgContext.saveGState()
                    cgContext.translateBy(x: 0, y: pageRect.height)
                    cgContext.scaleBy(x: 1.0, y: -1.0)
                    cgContext.drawPDFPage(pageRef)
                    cgContext.restoreGState()
                }
                
                let pageElements = extractedElements.filter { $0.page == pageIndex }
                for element in pageElements {
                    let textHeight = element.frame.height
                    let fontSize = max(textHeight * 0.8, 10)
                    
                    let attributedText = NSAttributedString(
                        string: element.text,
                        attributes: [
                            .font: UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
                            .foregroundColor: color
                        ]
                    )
                    
                    context.cgContext.setFillColor(UIColor.white.cgColor)
                    context.cgContext.fill(element.frame)
                    
                    attributedText.draw(in: element.frame)
                }
            }
            
            if let newPDFDocument = PDFDocument(data: pdfData),
               let newPage = newPDFDocument.page(at: 0) {
                newDocument.insert(newPage, at: pageIndex)
            }
        }
        
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("ModifiedFont.pdf")
        newDocument.write(to: outputURL)
        
        self.modifiedPdfDocument = PDFDocument(url: outputURL)
    }
}
