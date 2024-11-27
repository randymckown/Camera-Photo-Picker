import SwiftUI

struct CustomCropView: View {
    let originalImage: UIImage
    @Binding var croppedImageData: Data?
    @Environment(\.dismiss) private var dismiss

    @State private var cropBoxPosition: CGPoint = CGPoint(x: 100, y: 100) // Initial position
    @State private var cropBoxSize: CGSize = CGSize(width: 200, height: 200) // Fixed crop box size (1:1 aspect ratio)

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
                    Rectangle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: cropBoxSize.width, height: cropBoxSize.height)
                        .position(cropBoxPosition)
                        .contentShape(Rectangle()) // Ensure the gesture works across the whole crop box area
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // Debug print to check if the gesture is being recognized
                                    print("Drag Gesture Changed - Location: \(value.location)")

                                    // Ensure that the crop box is within bounds
                                    let minX = cropBoxSize.width / 2
                                    let maxX = imageSize.width - minX
                                    let minY = cropBoxSize.height / 2
                                    let maxY = imageSize.height - minY

                                    // Update the crop box position
                                    cropBoxPosition = CGPoint(
                                        x: min(max(value.location.x, minX), maxX),
                                        y: min(max(value.location.y, minY), maxY)
                                    )

                                    // Debug print to check if crop box position is updated
                                    print("Updated Crop Box Position: \(cropBoxPosition)")
                                }
                                .onEnded { _ in
                                    // Debug print to check if drag has ended
                                    print("Drag Gesture Ended - Final Position: \(cropBoxPosition)")
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

        // Calculate the scale factor for width and height
        let scaleX = originalImage.size.width / imageSize.width
        let scaleY = originalImage.size.height / imageSize.height

        // Use the larger scale to ensure proper scaling for both dimensions
        let scale = max(scaleX, scaleY)

        // Calculate the origin of the crop area relative to the image
        let cropOriginX = (cropBoxPosition.x - cropBoxSize.width / 2) * scale
        let cropOriginY = (cropBoxPosition.y - cropBoxSize.height / 2) * scale

        // Ensure the crop box size maintains a 1:1 aspect ratio
        let cropWidth = cropBoxSize.width * scale
        let cropHeight = cropBoxSize.height * scale

        // Ensure the crop box is within the bounds of the image
        let cropRect = CGRect(
            x: cropOriginX,
            y: cropOriginY,
            width: cropWidth,
            height: cropHeight
        )

        // Print debug information
        print("Image Size: \(originalImage.size.width) x \(originalImage.size.height)")
        print("Crop Box Position: \(cropOriginX), \(cropOriginY)")
        print("Crop Box Size: \(cropWidth), \(cropHeight)")

        // Perform cropping operation
        if let croppedCGImage = cgImage.cropping(to: cropRect) {
            let croppedUIImage = UIImage(cgImage: croppedCGImage)

            // Print the size of the cropped image to verify it matches expectations
            print("Cropped Image Size: \(croppedUIImage.size.width) x \(croppedUIImage.size.height)")

            // Save the cropped image data
            croppedImageData = croppedUIImage.pngData()
        }
    }
}
