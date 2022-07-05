import SwiftUI
import UIKit

final class TableItemViewHolder<Content: View>: UIHostingController<Content> {
    
    weak var delegate: TableItemViewHolderDelegate?
    
    var itemHeight: CGFloat {
        view.sizeThatFits(CGSize(width: view.frame.width, height: .infinity)).height
    }
    
    func detach() {
        willMove(toParent: nil)
        removeFromParent()
        didMove(toParent: nil)
        view?.willMove(toSuperview: nil)
        view?.removeFromSuperview()
        view?.didMoveToSuperview()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.tableItemViewHolderDidUpdateHeight(self)
        }
    }
    
}

protocol TableItemViewHolderDelegate: AnyObject {
    
    func tableItemViewHolderDidUpdateHeight(_ controller: UIViewController?)
    
}
