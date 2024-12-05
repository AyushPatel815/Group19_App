//
//  ImagePickerView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/22/24.
//

import SwiftUI
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Binding var selectedVideoURLs: [URL]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5  // Allows multiple selections (0 means unlimited)
        configuration.filter = .any(of: [.images, .videos])  // Allows both images and videos
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    // Load and append images
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                        DispatchQueue.main.async {
                            if let image = image as? UIImage {
                                self?.parent.selectedImages.append(image)
                            }
                        }
                    }
                } else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    // Load and append video URLs
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] (url, error) in
                        DispatchQueue.main.async {
                            if let url = url {
                                self?.parent.selectedVideoURLs.append(url)
                            }
                        }
                    }
                }
            }
        }
    }
}
