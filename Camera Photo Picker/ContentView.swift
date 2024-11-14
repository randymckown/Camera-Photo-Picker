//
//  ContentView.swift
//  Camera Photo Picker
//
//  Created by Randy McKown on 11/14/24.
//

import SwiftUI
import UIKit

// Image Picker Wrapper for SwiftUI
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// SwiftUI View with Camera and Photo Library Options
struct ContentView: View {
    @State private var profileImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary // Default to photo library
    
    var body: some View {
        VStack {
            // Display the profile image if available
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray)
            }
            
            // Buttons to open camera or photo library
            HStack {
                Button(action: {
                    sourceType = .camera // Set the source to camera
                    isShowingImagePicker = true
                }) {
                    Text("Take Photo")
                }
                .padding()
                
                Button(action: {
                    sourceType = .photoLibrary // Set the source to photo library
                    isShowingImagePicker = true
                }) {
                    Text("Select Photo")
                }
                .padding()
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $profileImage, sourceType: sourceType)
        }
    }
}


#Preview {
    ContentView()
}
