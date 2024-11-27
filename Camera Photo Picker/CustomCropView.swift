import UIKit
import SwiftUI
import Foundation

struct CustomCropView: View {
    let originalImage: UIImage
    @Binding var croppedImageData: Data?
    @Environment(\.dismiss) private var dismiss

    @State private var cropBoxPosition: CGPoint = CGPoint(x: 100, y: 100) // Center position of the crop box
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
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // Update the crop box position while ensuring it stays within bounds
                                    let minX = cropBoxSize.width / 2
                                    let maxX = imageSize.width - minX
                                    let minY = cropBoxSize.height / 2
                                    let maxY = imageSize.height - minY

                                    cropBoxPosition = CGPoint(
                                        x: min(max(value.location.x, minX), maxX),
                                        y: min(max(value.location.y, minY), maxY)
                                    )
                                }
                        )
                }
            }
            .aspectRatio(originalImage.size, contentMode: .fit)

            // Crop and Save Button
            Button("Crop and Save") {
                cropImage()
                dismiss() // Dismiss the view after saving the cropped image
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }

    private func cropImage() {
        guard let cgImage = originalImage.cgImage else { return }

        // Calculate scale factor for width and height
        let scaleX = originalImage.size.width / UIScreen.main.bounds.width
        let scaleY = originalImage.size.height / UIScreen.main.bounds.height

        // Use the larger scale to ensure proper scaling for both dimensions
        let scale = max(scaleX, scaleY)

        // Scale the crop box's position and size to the image's coordinate system
        let cropOriginX = (cropBoxPosition.x - cropBoxSize.width / 2) * scale
        let cropOriginY = (cropBoxPosition.y - cropBoxSize.height / 2) * scale

        // Ensure the size of the crop box maintains a 1:1 aspect ratio
        let cropWidth = cropBoxSize.width * scale
        let cropHeight = cropBoxSize.height * scale

        // Ensure the crop box is within the bounds of the image
        let cropRect = CGRect(
            x: cropOriginX,
            y: cropOriginY,
            width: cropWidth,
            height: cropHeight
        )

        // Print to verify
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
