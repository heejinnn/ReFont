//
//  ImagePickerView.swift
//  ReFont
//
//  Created by 최희진 on 2/18/25.
//

import SwiftUI

import SwiftUI

struct ImagePickerView: View {
    @Binding var showImagePicker: Bool
    var onImageSelected: (UIImage) -> Void // 클로저를 통한 이미지 전달
    
    @State private var showSourceSelection = false
    @State private var selectedSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        VStack {
            
        }
        .actionSheet(isPresented: .constant(true)) {
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
        
        // Display ImagePickerController with the selected source type
        .sheet(isPresented: $showSourceSelection) {
            ImagePickerController(sourceType: selectedSourceType) { selectedImage in
                onImageSelected(selectedImage) // 이미지 선택 후 클로저 호출
                showImagePicker = false
            }
        }
    }
}

struct ImagePickerController: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var onImageSelected: (UIImage) -> Void
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePickerController
        
        init(parent: ImagePickerController) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageSelected(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
