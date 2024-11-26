import UIKit

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
   
   func setImage(_ image: UIImage?) {
       guard let image = image else { return }
       originalImage = image
       croppedImage = image.cropToSquare()
   }
}
