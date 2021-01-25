//
//  UINavBarExtension.swift
//  Kasei
//
//  Sourced from https://stackoverflow.com/questions/21823692/how-to-prevent-uinavigationbar-from-blocking-touches-on-view
//

// This code stops the navigation bar from intercepting all touches it receives.

import UIKit

/// Passes through all touch events to views behind it, except when the
/// touch occurs in a contained UIControl or view with a gesture
/// recognizer attached
extension UINavigationBar {
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard nestedInteractiveViews(in: self, contain: point) else { return false }
        return super.point(inside: point, with: event)
    }

    private func nestedInteractiveViews(in view: UIView, contain point: CGPoint) -> Bool {
        if view.isPotentiallyInteractive, view.bounds.contains(convert(point, to: view)) {
            return true
        }

        for subview in view.subviews {
            if nestedInteractiveViews(in: subview, contain: point) {
                return true
            }
        }

        return false
    }
}

private extension UIView {
    var isPotentiallyInteractive: Bool {
        guard isUserInteractionEnabled else { return false }
        return (isControl || doesContainGestureRecognizer)
    }

    var isControl: Bool {
        return self is UIControl
    }

    var doesContainGestureRecognizer: Bool {
        return !(gestureRecognizers?.isEmpty ?? true)
    }
}
