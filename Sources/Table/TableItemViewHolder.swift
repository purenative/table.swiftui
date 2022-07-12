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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fixSafeArea()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.tableItemViewHolderDidUpdateHeight(self)
        }
    }
    
    private func fixSafeArea() {
        
        guard let _class = view?.classForCoder else {
            return
        }
        
        let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { (sself: AnyObject!) -> UIEdgeInsets in
            return .zero
        }
        guard let safeAreaInsetsMethod = class_getInstanceMethod(_class.self, #selector(getter: UIView.safeAreaInsets)) else {
            return
        }
        class_replaceMethod(_class, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(safeAreaInsetsMethod))
        
        let safeAreaLayoutGuide: @convention(block) (AnyObject) -> UILayoutGuide? = { (sself: AnyObject!) -> UILayoutGuide? in
            return nil
        }
        guard let safeAreaLayoutGuideMethod = class_getInstanceMethod(_class.self, #selector(getter: UIView.safeAreaLayoutGuide)) else {
            return
        }
        class_replaceMethod(_class.self, #selector(getter: UIView.safeAreaLayoutGuide), imp_implementationWithBlock(safeAreaLayoutGuide), method_getTypeEncoding(safeAreaLayoutGuideMethod))
        
    }
    
}

protocol TableItemViewHolderDelegate: AnyObject {
    
    func tableItemViewHolderDidUpdateHeight(_ controller: UIViewController?)
    
}
