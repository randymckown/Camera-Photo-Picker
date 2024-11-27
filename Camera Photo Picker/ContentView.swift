import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: Model  // Access model from the environment
    @StateObject private var imagePickerVM = ImagePickerVM()  // Initialize ImagePickerVM
    @State private var isCroppingActive = false  // State to track whether the cropping view is shown

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Display original image if available
                if let profileImage = model.profileImage.flatMap({ UIImage(data: $0) }) {
                    VStack {
                        Text("Original Image")
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .clipShape(Rectangle())  // Crop to square shape
                            .border(Color.gray, width: 1)  // Border to indicate crop
                    }
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .foregroundColor(.gray)
                }
                
                // Display cropped image if available
                if let croppedImageData = model.croppedImage,
                   let croppedImage = UIImage(data: croppedImageData) {
                    VStack {
                        Text("Cropped Image")
                        Image(uiImage: croppedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .clipShape(Rectangle())
                            .overlay(
                                Rectangle()
                                    .stroke(Color.red, lineWidth: 2)  // Adding a border for cropped area
                            )
                            .border(Color.gray, width: 1)
                    }
                } else {
                    Text("No cropped image available.")
                }
                
                // Buttons to open camera or photo library
                HStack {
                    Button(action: imagePickerVM.takePhoto) {
                        Text("Take Photo")
                    }
                    .padding()
                    
                    Button(action: imagePickerVM.selectPhoto) {
                        Text("Select Photo")
                    }
                    .padding()
                    
                    // New "Crop Image" button
                    Button(action: {
                        isCroppingActive.toggle()  // Show or hide the cropping view
                    }) {
                        Text("Crop Image")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .fullScreenCover(isPresented: $imagePickerVM.isShowingImagePicker) {
                            ImagePicker(
                                image: Binding(
                                    get: { imagePickerVM.originalImage },
                                    set: { imagePickerVM.setImage($0, model: model) }  // Pass model to setImage
                                ),
                                sourceType: imagePickerVM.sourceType
                            )
                        }
            .sheet(isPresented: $isCroppingActive) {
                if let profileImage = model.profileImage.flatMap({ UIImage(data: $0) }) {
                    CustomCropView(
                        originalImage: profileImage,
                        croppedImageData: $model.croppedImage // Provide a Binding to model.croppedImage
                    )
                    .interactiveDismissDisabled(true) // Disable the swipe-to-dismiss gesture
                } else {
                    Text("No image available to crop.")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

