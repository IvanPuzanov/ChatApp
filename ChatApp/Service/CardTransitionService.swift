//
//  CardTransitionService.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 02.05.2023.
//

import UIKit

enum CardTransitionType {
    case presentation
    case dismissal
}

final class CardTransitionService: NSObject {
    // MARK: - Параметры
    
    let transitionDuration: Double = 0.8
    var transition: CardTransitionType = .presentation
    let shrinkDuration: Double = 0.2
}

extension CardTransitionService: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from) else {
            return
        }

        switch transition {
        case .presentation:
            containerView.addSubview(toViewController.view)
            toViewController.view.alpha = 0
            UIView.animate(withDuration: 0.4) {
                toViewController.view.alpha = 1
            } completion: { _ in
                transitionContext.completeTransition(true)
            }
        case .dismissal:
            UIView.animate(withDuration: 0.4) {
                fromViewController.view.alpha = 1
            } completion: { _ in
                transitionContext.completeTransition(true)
                fromViewController.view.removeFromSuperview()
            }
        }
    }
}

extension CardTransitionService: UIViewControllerTransitioningDelegate {
    typealias Transitioning = UIViewControllerAnimatedTransitioning
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> Transitioning? {
        transition = .presentation
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> Transitioning? {
        transition = .dismissal
        return self
    }
}
