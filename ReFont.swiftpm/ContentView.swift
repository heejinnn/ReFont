import SwiftUI
import PDFKit
import Vision

struct ContentView: View {
    @State private var recognizedText: String = "PDF에서 추출한 텍스트가 여기에 표시됩니다."
    @State private var extractedTexts: [(text: String, frame: CGRect)] = []
    @State private var showDocumentPicker = false
    @State private var pdfURL: URL?

    var body: some View {
        VStack {
            Button("PDF 파일 선택") {
                showDocumentPicker = true
            }
            .padding()

            ScrollView {
                Text(recognizedText)
                    .font(.custom("MarkerFelt-Thin", size: 20))
                    .padding()
            }

            Button("PDF로 저장") {
                saveAsPDF()
            }
            .padding()

            Button("폰트 변경 후 PDF 저장") {
                saveHandwrittenTextAsPDF(extractedTexts: extractedTexts)
            }
            .padding()

            if let pdfURL = pdfURL {
                ShareLink(item: pdfURL) {
                    Text("PDF 다운로드")
                }
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker { url in
                extractHandwrittenTextWithPosition(from: url)
            }
        }
    }

    // 🔹 PDF에서 텍스트 + 위치 추출
    func extractHandwrittenTextWithPosition(from pdfURL: URL) {
        print("📂 선택된 파일 URL: \(pdfURL)")
        
        // 🔹 보안 접근 권한 활성화 (필요할 경우)
        let _ = pdfURL.startAccessingSecurityScopedResource()
        
        guard let pdfDocument = PDFDocument(url: pdfURL) else {
            print("❌ PDF 파일을 열 수 없습니다: \(pdfURL)")
            pdfURL.stopAccessingSecurityScopedResource()
            return
        }

        var extractedTexts: [(text: String, frame: CGRect)] = []

        for i in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: i) else { continue }
            let image = page.thumbnail(of: CGSize(width: 1000, height: 1400), for: .artBox)

            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

                for observation in observations {
                    let text = observation.topCandidates(1).first?.string ?? ""
                    let boundingBox = observation.boundingBox

                    // 🔹 PDF 좌표 변환
                    let convertedFrame = CGRect(
                        x: boundingBox.origin.x * 1000,
                        y: (1 - boundingBox.origin.y) * 1400, // Y축 반전 필요
                        width: boundingBox.width * 1000,
                        height: boundingBox.height * 1400
                    )

                    extractedTexts.append((text: text, frame: convertedFrame))
                }
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!)
            try? requestHandler.perform([request])
        }

        DispatchQueue.main.async {
            self.extractedTexts = extractedTexts
            self.recognizedText = extractedTexts.map { $0.text }.joined(separator: "\n")
        }
    }

    // 🔹 OCR 결과를 PDF로 저장하는 함수 (위치 유지)
    func saveHandwrittenTextAsPDF() {
        let pdfFilename = FileManager.default.temporaryDirectory.appendingPathComponent("FormattedText.pdf")

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 1000, height: 1400))

        try? renderer.writePDF(to: pdfFilename) { context in
            context.beginPage()

            for item in extractedTexts {
                let attributedText = NSAttributedString(
                    string: item.text,
                    attributes: [
                        .font: UIFont(name: "MarkerFelt-Thin", size: 18) ?? UIFont.systemFont(ofSize: 18),
                        .foregroundColor: UIColor.black
                    ]
                )

                attributedText.draw(in: item.frame)
            }
        }

        DispatchQueue.main.async {
            self.pdfURL = pdfFilename
            print("✅ PDF 저장 완료: \(pdfFilename)")
        }
    }
    // 🔹 OCR 결과를 PDF로 저장하는 함수
    func saveAsPDF() {
        let pdfFilename = FileManager.default.temporaryDirectory.appendingPathComponent("ConvertedText.pdf")
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792)) // A4 크기
        try? renderer.writePDF(to: pdfFilename) { context in
            context.beginPage()
            let textRect = CGRect(x: 20, y: 20, width: 572, height: 752)
            
            let attributedText = NSAttributedString(
                string: recognizedText,
                attributes: [
                    .font: UIFont(name: "MarkerFelt-Thin", size: 18) ?? UIFont.systemFont(ofSize: 18)
                ]
            )
            attributedText.draw(in: textRect)
        }
        
        DispatchQueue.main.async {
            self.pdfURL = pdfFilename
        }
    }
    
    func saveHandwrittenTextAsPDF(extractedTexts: [(text: String, frame: CGRect)]) {
        let pdfFilename = FileManager.default.temporaryDirectory.appendingPathComponent("FormattedText.pdf")

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))

        try? renderer.writePDF(to: pdfFilename) { context in
            context.beginPage()

            for item in extractedTexts {
                let attributedText = NSAttributedString(
                    string: item.text,
                    attributes: [
                        .font: UIFont(name: "MarkerFelt-Thin", size: 18) ?? UIFont.systemFont(ofSize: 18),
                        .foregroundColor: UIColor.black
                    ]
                )

                attributedText.draw(in: item.frame)
            }
        }

        DispatchQueue.main.async {
            self.pdfURL = pdfFilename
            print("✅ PDF 저장 완료: \(pdfFilename)")
        }
    }
}

