
import SwiftUI
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {
    class Coordinator: NSObject, @preconcurrency VNDocumentCameraViewControllerDelegate {
        var parent: DocumentScannerView
        
        init(parent: DocumentScannerView) {
            self.parent = parent
        }
        
        @MainActor func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var scannedImages: [UIImage] = []
            
            for pageIndex in 0..<scan.pageCount {
                let scannedImage = scan.imageOfPage(at: pageIndex)
                scannedImages.append(scannedImage)
            }
            
            parent.didFinishScanning(scannedImages)
            controller.dismiss(animated: true)
        }
        
        @MainActor func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.didCancelScanning()
            controller.dismiss(animated: true)
        }
    }
    
    var didFinishScanning: ([UIImage]) -> Void
    var didCancelScanning: () -> Void
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let cameraViewController = VNDocumentCameraViewController()
        cameraViewController.delegate = context.coordinator
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
       
    }
}
