import SwiftUI
import PDFKit
import Vision

struct ContentView: View {
    @State private var recognizedText: String = "PDF에서 추출한 텍스트가 여기에 표시됩니다."
    @State private var pdfDocument: PDFDocument?
    @State private var showDocumentPicker = false
    @State private var pdfURL: URL?
    @State private var extractedElements: [(text: String, frame: CGRect, page: Int)] = []
    @State private var showModifiedPdf = false
    
    var body: some View {
        VStack {
            Button("PDF 파일 선택") {
                showDocumentPicker = true
            }
            .padding()
            
            if let pdfDocument = pdfDocument {
                PdfKitView(document: pdfDocument)
                    .frame(height: 500)
            }
            
            Button("폰트 변경하여 PDF 저장") {
                createNewPDFWithModifiedFont()
            }
            .padding()
            
            if let pdfURL = pdfURL {
                ShareLink(item: pdfURL) {
                    Text("변환된 PDF 다운로드")
                }
                .padding()
                
                Button("변환된 PDF 보기") {
                    showModifiedPdf = true
                }
                .padding()
                .sheet(isPresented: $showModifiedPdf) {
                    ModifiedPdfView(pdfURL: pdfURL)
                }
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker { url in
                loadPDF(from: url)
            }
        }
    }
    
    private func loadPDF(from url: URL) {
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
        extractedElements.removeAll() // 기존에 저장된 텍스트 요소를 초기화
        
        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else { continue }
            
            // 페이지 크기 가져오기
            let pageRect = page.bounds(for: .mediaBox)
            let originalSize = CGSize(width: pageRect.width, height: pageRect.height)
            
            // PDF 페이지를 고화질 이미지로 변환
            let pageImage = page.thumbnail(of: originalSize, for: .mediaBox)
            
            // Vision 프레임워크의 텍스트 인식 요청 생성
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                
                for observation in observations {
                    if let text = observation.topCandidates(1).first?.string {
                        // Vision이 반환하는 좌표를 PDF 좌표계로 변환
                        let boundingBox = observation.boundingBox
                        let frame = CGRect(
                            x: boundingBox.origin.x * originalSize.width,
                            y: (1 - boundingBox.origin.y - boundingBox.height) * originalSize.height,
                            width: boundingBox.width * originalSize.width,
                            height: boundingBox.height * originalSize.height
                        )
                        
                        // 인식된 텍스트와 좌표를 배열에 추가 (UI 업데이트를 위해 메인 스레드에서 실행)
                        DispatchQueue.main.async {
                            extractedElements.append((text: text, frame: frame, page: pageIndex))
                        }
                    }
                }
            }
            
            // 텍스트 인식 정확도를 높이고 언어 교정을 활성화
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            do {
                // Vision 프레임워크를 사용하여 이미지에서 텍스트 인식 실행
                try VNImageRequestHandler(cgImage: pageImage.cgImage!, options: [:])
                    .perform([request])
            } catch {
                print("❌ 텍스트 인식 실패: \(error)")
            }
        }
    }

    
    private func createNewPDFWithModifiedFont() {
        guard let document = pdfDocument else { return }
        
        let newDocument = PDFDocument()
        
        for pageIndex in 0..<document.pageCount {
            guard let originalPage = document.page(at: pageIndex) else { continue }
            
            let pageRect = originalPage.bounds(for: .mediaBox)
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
            
            let pdfData = renderer.pdfData { context in
                context.beginPage()
                
                // 원본 PDF 페이지 그리기
                if let pageRef = originalPage.pageRef,
                   let cgContext = UIGraphicsGetCurrentContext() {
                    cgContext.saveGState()
                    cgContext.translateBy(x: 0, y: pageRect.height)
                    cgContext.scaleBy(x: 1.0, y: -1.0)
                    cgContext.drawPDFPage(pageRef)
                    cgContext.restoreGState()
                }
                
                // 변경된 폰트 적용하여 텍스트 다시 그리기
                let pageElements = extractedElements.filter { $0.page == pageIndex }
                for element in pageElements {
                    let attributedText = NSAttributedString(
                        string: element.text,
                        attributes: [
                            .font: UIFont(name: "MarkerFelt-Thin", size: 18) ?? UIFont.systemFont(ofSize: 18),
                            .foregroundColor: UIColor.black
                        ]
                    )
                    
                    // 기존 텍스트를 덮는 흰색 박스
                    context.cgContext.setFillColor(UIColor.white.cgColor)
                    context.cgContext.fill(element.frame)
                    
                    // 새로운 폰트 적용된 텍스트 그리기
                    attributedText.draw(in: element.frame)
                }
            }
            
            // `PDFDocument`를 생성하여 데이터를 로드한 후, `PDFPage`를 가져오기
            if let newPDFDocument = PDFDocument(data: pdfData),
               let newPage = newPDFDocument.page(at: 0) {
                newDocument.insert(newPage, at: pageIndex)
            }
        }
        
        // 🔹 새로운 PDF 저장
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("ModifiedFont.pdf")
        newDocument.write(to: outputURL)
        
        DispatchQueue.main.async {
            self.pdfURL = outputURL
            print("✅ 새로운 PDF 저장 완료: \(outputURL)")
        }
    }

}
