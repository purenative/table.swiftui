import UIKit

public class TableItemAction {
    
    let title: String
    let image: UIImage?
    let color: UIColor?
    private(set) var isDeleteAction: Bool = false
    
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
