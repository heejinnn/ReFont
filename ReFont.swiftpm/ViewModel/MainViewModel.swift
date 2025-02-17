
import SwiftUI
import PDFKit
import Vision

class MainViewModel: ObservableObject {
    @Published var pdfDocument: PDFDocument?
    @Published var extractedElements: [(text: String, frame: CGRect, page: Int)] = []

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
    
    /// Extract text from PDF
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
            request.revision = VNRecognizeTextRequestRevision3
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            request.recognitionLanguages = ["ko-KR", "en-US"]
            
            do {
                try VNImageRequestHandler(cgImage: pageImage.cgImage!, options: [:])
                    .perform([request])
            } catch {
                print("❌ 텍스트 인식 실패: \(error)")
            }
        }
    }
    
    /// Create a new PDF
    func createNewPDFWithModifiedFont(fontName: String, color: UIColor, includeOriginalLayout: Bool, completion: @escaping (PDFDocument?) -> Void) {
        guard let document = pdfDocument else { return completion(nil) }
        
        let newDocument = PDFDocument()
        
        for pageIndex in 0..<document.pageCount {
            guard let originalPage = document.page(at: pageIndex) else { continue }
            
            let pageRect = originalPage.bounds(for: .mediaBox)
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
            
            let pdfData = renderer.pdfData { context in
                context.beginPage()
                
                if includeOriginalLayout {
                    drawOriginalPage(originalPage, in: context, with: pageRect)
                    drawTextWithOriginalLayout(on: context, pageIndex: pageIndex, fontName: fontName, color: color)
                } else {
                    drawTextWithoutLayout(on: context, pageIndex: pageIndex, fontName: fontName, color: color, pageRect: pageRect)
                }
            }
            
            if let newPDFDocument = PDFDocument(data: pdfData),
               let newPage = newPDFDocument.page(at: 0) {
                newDocument.insert(newPage, at: pageIndex)
            }
        }
        
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("ModifiedFont.pdf")
        newDocument.write(to: outputURL)
        completion(PDFDocument(url: outputURL))
    }
    
    /// Draw on an existing PDF page
    private func drawOriginalPage(_ page: PDFPage, in context: UIGraphicsPDFRendererContext, with rect: CGRect) {
        guard let pageRef = page.pageRef, let cgContext = UIGraphicsGetCurrentContext() else { return }
        
        cgContext.saveGState()
        cgContext.translateBy(x: 0, y: rect.height)
        cgContext.scaleBy(x: 1.0, y: -1.0)
        cgContext.drawPDFPage(pageRef)
        cgContext.restoreGState()
    }
    
    /// Apply text while maintaining existing layout
    private func drawTextWithOriginalLayout(on context: UIGraphicsPDFRendererContext, pageIndex: Int, fontName: String, color: UIColor) {
        let elements = extractedElements.filter { $0.page == pageIndex }
        
        for element in elements {
            let fontSize = adjustFontSizeToFit(element, fontName: fontName, fontSize: max(element.frame.height * 0.8, 10))
            
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
    
    /// List text in new format
    private func drawTextWithoutLayout(on context: UIGraphicsPDFRendererContext, pageIndex: Int, fontName: String, color: UIColor, pageRect: CGRect) {
        let elements = extractedElements.filter { $0.page == pageIndex }
        var yOffset: CGFloat = pageRect.height - 50
        
        let lineHeight: CGFloat = 20
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        for element in elements {
            let attributedText = NSAttributedString(
                string: element.text,
                attributes: [
                    .font: UIFont(name: fontName, size: 16) ?? UIFont.systemFont(ofSize: 16),
                    .foregroundColor: color,
                    .paragraphStyle: paragraphStyle
                ]
            )
            
            let textFrame = CGRect(x: 20, y: yOffset, width: pageRect.width - 40, height: lineHeight)
            attributedText.draw(in: textFrame)
            
            yOffset -= lineHeight
            
            if yOffset < 50 {
                context.beginPage()
                yOffset = pageRect.height - 50
            }
        }
    }
    
    /// Auto adjust font size
    private func adjustFontSizeToFit(_ element: (text: String, frame: CGRect, page: Int), fontName: String, fontSize: CGFloat) -> CGFloat {
        let testString = element.text as NSString
        var minFontSize: CGFloat = 10
        var maxFontSize: CGFloat = fontSize
        var bestFontSize: CGFloat = fontSize
        
        while minFontSize <= maxFontSize {
            let currentFontSize = (minFontSize + maxFontSize) / 2
            let testFont = UIFont(name: fontName, size: currentFontSize) ?? UIFont.systemFont(ofSize: currentFontSize)
            let rect = testString.boundingRect(
                with: CGSize(width: element.frame.width, height: CGFloat.greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [.font: testFont],
                context: nil
            )
            
            if rect.height > element.frame.height {
                maxFontSize = currentFontSize - 0.5
            } else {
                bestFontSize = currentFontSize
                minFontSize = currentFontSize + 0.5
            }
        }
        
        return bestFontSize
    }

}
