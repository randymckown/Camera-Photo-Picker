import UIKit

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
