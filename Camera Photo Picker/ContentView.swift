import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ImagePickerVM()
    
    var body: some View {
        VStack(spacing: 20) {
            // Display the original image if available
            if let originalImage = viewModel.originalImage {
                VStack {
                    Text("Original Image")
                    Image(uiImage: originalImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(Rectangle())
                        .border(Color.gray, width: 1)
                }
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray)
            }

            // Display the cropped image if available
            if let croppedImage = viewModel.croppedImage {
                VStack {
                    Text("Cropped Image (1:1)")
                    Image(uiImage: croppedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(Rectangle())
                        .border(Color.gray, width: 1)
                }
            }

            // Buttons to open camera or photo library
            HStack {
                Button(action: viewModel.takePhoto) {
                    Text("Take Photo")
                }
                .padding()
                
                Button(action: viewModel.selectPhoto) {
                    Text("Select Photo")
                }
                .padding()
            }
        }
        .sheet(isPresented: $viewModel.isShowingImagePicker) {
            ImagePicker(
                image: Binding(
                    get: { viewModel.originalImage },
                    set: { viewModel.setImage($0) }
                ),
                sourceType: viewModel.sourceType
            )
        }
    }
}

#Preview {
    ContentView()
}
