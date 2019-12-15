import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    // Example of configuring a controller
    let imageUpload = ImageUploadController()
    
//    router.post("imageUpload"
    router.post("imageUpload", use: imageUpload.postUpload)
}
