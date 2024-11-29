import SwiftUI

struct CustomCropView: View {
    let originalImage: UIImage
    @Binding var croppedImageData: Data?
    @Environment(\.dismiss) private var dismiss

    @State private var cropBoxPosition: CGPoint = CGPoint(x: 100, y: 100) // Initial position
    @State private var cropBoxSize: CGSize = CGSize(width: 200, height: 200) // Fixed crop box size (1:1 aspect ratio)
    
    @State private var cropBoxScale: CGFloat = 1.0 // Tracks the zoom scale
    @State private var cropBoxBaseSize: CGSize = CGSize(width: 200, height: 200) // The original crop box size
    @State private var cropBoxActualSize: CGSize = CGSize(width: 200, height: 200) // The dynamically resized size


    var body: some View {
        VStack {
            Text("Custom Crop View")
                .font(.headline)
                .padding()

            GeometryReader { geometry in
                let imageSize = CGSize(
                    width: geometry.size.width,
                    height: geometry.size.height
                )

                ZStack {
                    // Display the image
                    Image(uiImage: originalImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize.width, height: imageSize.height)

                    // Draggable crop box (1:1 aspect ratio)
                    // Draggable and resizable crop box (1:1 aspect ratio)
                    Rectangle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: cropBoxActualSize.width, height: cropBoxActualSize.height)
                        .position(cropBoxPosition)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // Bounds for dragging
                                    let minX = cropBoxActualSize.width / 2
                                    let maxX = imageSize.width - minX
                                    let minY = cropBoxActualSize.height / 2
                                    let maxY = imageSize.height - minY

                                    // Update position while ensuring it stays within bounds
                                    cropBoxPosition = CGPoint(
                                        x: min(max(value.location.x, minX), maxX),
                                        y: min(max(value.location.y, minY), maxY)
                                    )
                                }
                        )
                        .gesture(
                                MagnificationGesture()
                                    .onChanged { scale in
                                        // Calculate new size dynamically during the gesture
                                        let newWidth = cropBoxBaseSize.width * scale
                                        let newHeight = cropBoxBaseSize.height * scale

                                        // Clamp the size to a reasonable range (e.g., 100x100 to 400x400)
                                        let clampedWidth = min(max(newWidth, 100), 400)
                                        let clampedHeight = min(max(newHeight, 100), 400)

                                        cropBoxActualSize = CGSize(width: clampedWidth, height: clampedHeight)
                                    }
                                    .onEnded { _ in
                                        // Save the final size as the new base size
                                        cropBoxBaseSize = cropBoxActualSize
                                    }
                            )

                }
            }
            .aspectRatio(originalImage.size, contentMode: .fit)

            // Crop and Save Button
            Button("Crop and Save") {
                cropImage(imageSize: UIScreen.main.bounds.size)
                dismiss() // Dismiss the view after saving the cropped image
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
    
    // Function to fix the orientation of the image based on its EXIF data
    private func fixImageOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }

        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let correctedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return correctedImage
    }

    private func cropImage(imageSize: CGSize) {
        guard let cgImage = fixImageOrientation(originalImage).cgImage else { return }

        // Calculate scale factors for converting view coordinates to image coordinates
        let scaleX = originalImage.size.width / imageSize.width
        let scaleY = originalImage.size.height / imageSize.height
        let scale = max(scaleX, scaleY)

        // Calculate the crop box origin and size relative to the image
        let cropOriginX = (cropBoxPosition.x - cropBoxActualSize.width / 2) * scale
        let cropOriginY = (cropBoxPosition.y - cropBoxActualSize.height / 2) * scale
        let cropWidth = cropBoxActualSize.width * scale
        let cropHeight = cropBoxActualSize.height * scale

        let cropRect = CGRect(
            x: max(0, cropOriginX),
            y: max(0, cropOriginY),
            width: min(originalImage.size.width - cropOriginX, cropWidth),
            height: min(originalImage.size.height - cropOriginY, cropHeight)
        )

        if let croppedCGImage = cgImage.cropping(to: cropRect) {
            let croppedUIImage = UIImage(cgImage: croppedCGImage)
            croppedImageData = croppedUIImage.pngData()
        }
    }

}
