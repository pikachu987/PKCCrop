//
//  Interactor.swift
//  Search
//
//  Created by guanho on 2016. 12. 27..
//  Copyright © 2016년 guanho. All rights reserved.
//

import UIKit

enum Direction {
    case up
    case down
    case left
    case right
}
class Helper{}
class Interactor: UIPercentDrivenInteractiveTransition {
    var hasStarted = false
    var shouldFinish = false
}

class DismissAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }
        transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        UIView.animate(withDuration: transitionDuration(using: transitionContext),animations: {
            fromVC.view.frame = CGRect(origin: CGPoint(x: UIScreen.main.bounds.width, y: 0), size: UIScreen.main.bounds.size)
        },completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

class PresentMenuAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    var direction : Direction!
    var snapshotNumber: Int!
    var menuWidth: CGFloat!
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }
        let containerView = transitionContext.containerView
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false)
        snapshot?.tag = self.snapshotNumber
        snapshot?.isUserInteractionEnabled = false
        snapshot?.layer.shadowOpacity = 0
        containerView.insertSubview(snapshot!, aboveSubview: toVC.view)
        fromVC.view.isHidden = true
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),animations: {
            if self.direction != nil{
                if self.direction == .right{
                    snapshot?.center.x += UIScreen.main.bounds.width * self.menuWidth
                }else if self.direction == .left{
                    snapshot?.center.x -= UIScreen.main.bounds.width * self.menuWidth
                }else if self.direction == .up{
                    snapshot?.center.y += UIScreen.main.bounds.height * self.menuWidth
                }else if self.direction == .down{
                    snapshot?.center.y -= UIScreen.main.bounds.height * self.menuWidth
                }
            }
        },completion: { _ in
            fromVC.view.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}



class MenuHelper: Helper {
    static let menuWidth:CGFloat = 1
    static let percentThreshold:CGFloat = 0.4
    static let snapshotNumber = 12340
    static func calculateProgress(_ translationInView:CGPoint, viewBounds:CGRect, direction:Direction) -> CGFloat {
        let pointOnAxis:CGFloat
        let axisLength:CGFloat
        switch direction {
        case .up, .down:
            pointOnAxis = translationInView.y
            axisLength = viewBounds.height
        case .left, .right:
            pointOnAxis = translationInView.x
            axisLength = viewBounds.width
        }
        let movementOnAxis = pointOnAxis / axisLength
        let positiveMovementOnAxis:Float
        let positiveMovementOnAxisPercent:Float
        switch direction {
        case .right, .down:
            positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
            return CGFloat(positiveMovementOnAxisPercent)
        case .up, .left:
            positiveMovementOnAxis = fminf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fmaxf(positiveMovementOnAxis, -1.0)
            return CGFloat(-positiveMovementOnAxisPercent)
        }
    }
    static func mapGestureStateToInteractor(_ gestureState:UIGestureRecognizerState, progress:CGFloat, interactor: Interactor?, triggerSegue: () -> ()){
        guard let interactor = interactor else { return }
        switch gestureState {
        case .began:
            interactor.hasStarted = true
            triggerSegue()
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
}
