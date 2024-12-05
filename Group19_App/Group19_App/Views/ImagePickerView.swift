//
//  ImagePickerView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/22/24.
//

import SwiftUI
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]  // Binds to the selected images in the parent view
    @Binding var selectedVideoURLs: [URL]   // Binds to the selected video URLs in the parent view
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        
        // Configure the PHPicker to allow selection of images (and optionally videos)
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5  // Allows multiple selections (0 means unlimited)
        configuration.filter = .any(of: [.images, .videos])  // Allows both images and videos
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator    // Set the delegate to handle user selections
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No updates are required in this implementation

    }
    
    func makeCoordinator() -> Coordinator {
        // Create and return a coordinator to handle picker events

        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePickerView   // Reference to the parent `ImagePickerView`
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            // Loop through the selected results
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    // Load and append images
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                        DispatchQueue.main.async {
                            if let image = image as? UIImage {
                                // Append the image to the parent's selectedImages
                                self?.parent.selectedImages.append(image)
                            }
                        }
                    }
                } else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    // Load and append video URLs
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] (url, error) in
                        DispatchQueue.main.async {
                            if let url = url {
                                // Append the video URL to the parent's selectedVideoURLs
                                self?.parent.selectedVideoURLs.append(url)
                            }
                        }
                    }
                }
            }
        }
    }
}
