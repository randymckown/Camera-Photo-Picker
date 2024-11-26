import UIKit
import SwiftUI

class ImagePickerVM: ObservableObject {
    @Published var originalImage: UIImage?
    @Published var croppedImage: UIImage?
    @Published var isShowingImagePicker = false
    @Published var sourceType: UIImagePickerController.SourceType = .camera

    func takePhoto() {
        sourceType = .camera
        isShowingImagePicker = true
    }

    func selectPhoto() {
        sourceType = .photoLibrary
        isShowingImagePicker = true
    }

    // Updated setImage method to accept 'model' as a parameter
    func setImage(_ image: UIImage?, model: Model) {
        guard let image = image else { return }
        originalImage = image
        croppedImage = image.cropToSquare()

        // Convert UIImage to Data and store it in the model
        if let profileImageData = image.jpegData(compressionQuality: 1.0) {
            // Store the profile image in the environment object (Model)
            model.profileImage = profileImageData
        }

        if let croppedImageData = croppedImage?.jpegData(compressionQuality: 1.0) {
            // Store the cropped image in the environment object (Model)
            model.croppedImage = croppedImageData
        }
    }
}

extension UIImage {
    func cropToSquare() -> UIImage? {
        let originalWidth = self.size.width
        let originalHeight = self.size.height

        let squareSize = min(originalWidth, originalHeight)
        let x = (originalWidth - squareSize) / 2
        let y = (originalHeight - squareSize) / 2

        let cropRect = CGRect(x: x, y: y, width: squareSize, height: squareSize)
        guard let croppedCGImage = self.cgImage?.cropping(to: cropRect) else {
            return nil
        }

        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
}
