import Foundation
import SwiftData

@Model
class Model: ObservableObject {  // Conform to ObservableObject
    var id: UUID = UUID()
    var profileImage: Data?
    var croppedImage: Data?

    init(profileImage: Data? = nil, croppedImage: Data? = nil) {
        self.profileImage = profileImage
        self.croppedImage = croppedImage
    }
}
