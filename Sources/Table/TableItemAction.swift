import UIKit

public class TableItemAction {
    
    public let title: String
    public let image: UIImage?
    public let color: UIColor?
    public private(set) var isDeleteAction: Bool = false
    
    public init(title: String,
                image: UIImage? = nil,
                color: UIColor? = nil) {
        
        self.title = title
        self.image = image
        self.color = color
    }
    
    func markAsDeleteAction() {
        isDeleteAction = true
    }
    
}
