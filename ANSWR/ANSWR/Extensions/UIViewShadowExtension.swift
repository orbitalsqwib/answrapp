//
//  UIViewShadowExtension.swift
//  Kasei
//
//  Extension implementation of the method to draw a shadow on a UIView from this link: https://www.hackingwithswift.com/example-code/uikit/how-to-add-a-shadow-to-a-uiview
//

import UIKit

extension UIView {
    func setShadow(col: CGColor, opacity: Float, offset: CGSize, rad: CGFloat) {
        self.layer.shadowColor = col
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = rad
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
