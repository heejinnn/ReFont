
import SwiftUI
import VisionKit

struct TextScannerView: UIViewControllerRepresentable {
    var didFinishScanning: (String) -> Void
    var didCancelScanning: () -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        guard DataScannerViewController.isSupported && DataScannerViewController.isAvailable else {
            return DataScannerViewController()
        }
        
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text(languages: ["ko-KR", "en-US"])],
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        
        scanner.delegate = context.coordinator
        
        DispatchQueue.main.async {
            do {
                try scanner.startScanning()
                print("✅ Scanning started")
            } catch {
                print("❌ Failed to start scanning: \(error)")
            }
        }

        return scanner
    }


    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let parent: TextScannerView

        init(_ parent: TextScannerView) {
            self.parent = parent
        }

        func dataScanner(_ scanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            processItemsManually(item)
        }

        func processItemsManually(_ item: RecognizedItem) {

            guard case let .text(value) = item else {
                print("❌ No text recognized manually")
                return
            }
            
            print("✅ Recognized text manually: \(value.transcript)")
            self.parent.didFinishScanning(value.transcript)

        }

        func dataScannerDidCancel(_ scanner: DataScannerViewController) {
            parent.didCancelScanning()
        }
    }
}
