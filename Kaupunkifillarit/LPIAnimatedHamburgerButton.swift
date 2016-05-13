//
//  LPIAnimatedHamburgerButton.swift
//  Kaupunkifillarit
//
//  Created by Lauri Piispanen on 12/05/16.
//  Copyright © 2016 Lauri Piispanen. All rights reserved.
//

import UIKit

class LPIAnimatedHamburgerButton: UIControl, LPIAnimatedHamburgerOptions {
    
    var isHamburger = true {
        willSet {
            if (newValue) {
                self.assumeShape(true, shape: self.originShape)
            } else {
                self.assumeShape(true, shape: self.shape)
            }
            self.layoutIfNeeded()
        }
        didSet {
            self.sendActionsForControlEvents(.ValueChanged)
        }
    }
    
    var animationTime: Double = 0.3
    var lineWidth: Double = 3.0
    var strokeColor: CGColor = UIColor.whiteColor().CGColor
    var originShape: LPIAnimatedHamburgerShape = LPIAnimatedHamburgerDefaultShapes.Hamburger
    var shape: LPIAnimatedHamburgerShape = LPIAnimatedHamburgerDefaultShapes.ArrowRight
    var timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    
    private var layers = (
        CAShapeLayer(),
        CAShapeLayer(),
        CAShapeLayer()
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addBehavior()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    private func addBehavior() {
        self.addTarget(self, action: #selector(toggleValue), forControlEvents: .TouchUpInside)
        
        self.layer.addSublayer(layers.0)
        self.layer.addSublayer(layers.1)
        self.layer.addSublayer(layers.2)
                
        self.redraw()
    }
    
    func toggleValue() {
        isHamburger = !isHamburger
    }
    
    func assumeShape(animate:Bool = false, shape: LPIAnimatedHamburgerShape) {
        shape(layers: self.layers, animate: true, options: self)

        initLayerSettings(layers.0)
        initLayerSettings(layers.1)
        initLayerSettings(layers.2)
    }
    
    private func initLayerSettings(shapeLayer: CAShapeLayer) {
        shapeLayer.lineWidth = CGFloat(lineWidth)
        shapeLayer.strokeColor = strokeColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.frame = self.bounds
        self.layers.0.frame = layer.frame
        self.layers.1.frame = layer.frame
        self.layers.2.frame = layer.frame
        self.redraw()
    }
    
    private func redraw() {
        if (isHamburger) {
            self.assumeShape(false, shape: self.originShape)
        } else {
            self.assumeShape(false, shape: self.shape)
        }
    }
    
    
}

struct LPIAnimatedHamburgerDefaultShapes {
    static func Hamburger(layers: (CAShapeLayer, CAShapeLayer, CAShapeLayer), animate: Bool, options: LPIAnimatedHamburgerOptions) {
        assume(layers.0, path: (CGPoint(x: 0, y: layers.0.frame.height * 0.1), CGPoint(x: layers.0.frame.width, y: layers.0.frame.height * 0.1)), opacity: 1.0, options: options, animate: animate)
        assume(layers.1, path: (CGPoint(x: 0.0, y: layers.1.frame.height / 2.0), CGPoint(x: layers.1.frame.width, y: layers.1.frame.height / 2.0)), opacity: 1.0, options: options, animate: animate)
        assume(layers.2, path: (CGPoint(x: 0.0, y: layers.2.frame.height * 0.9), CGPoint(x: layers.2.frame.width, y: layers.2.frame.height * 0.9)), opacity: 1.0, options: options, animate: animate)
    }
    static func Cross(layers: (CAShapeLayer, CAShapeLayer, CAShapeLayer), animate: Bool, options: LPIAnimatedHamburgerOptions) {
        assume(layers.0, path: (CGPoint(x: 0, y: 0), CGPoint(x: layers.0.frame.width, y: layers.0.frame.height)), opacity: 1.0, options: options, animate: animate)
        assume(layers.1, path: layers.1.path, opacity: 0.0, options: options, animate: animate)
        assume(layers.2, path: (CGPoint(x: 0.0, y: layers.2.frame.height), CGPoint(x: layers.2.frame.width, y: 0.0)), opacity: 1.0, options: options, animate: animate)
    }
    static func ArrowRight(layers: (CAShapeLayer, CAShapeLayer, CAShapeLayer), animate: Bool, options: LPIAnimatedHamburgerOptions) {
        assume(layers.0, path: (CGPoint(x: layers.0.frame.width / 2, y: 0), CGPoint(x: layers.0.frame.width, y: layers.0.frame.height / 2)), opacity: 1.0, options: options, animate: animate)
        assume(layers.1, path: (CGPoint(x: 0.0, y: layers.1.frame.height / 2.0), CGPoint(x: layers.1.frame.width, y: layers.1.frame.height / 2.0)), opacity: 1.0, options: options, animate: animate)
        assume(layers.2, path: (CGPoint(x: layers.0.frame.width / 2, y: layers.2.frame.height), CGPoint(x: layers.2.frame.width, y: layers.2.frame.height / 2)), opacity: 1.0, options: options, animate: animate)
    }
    
    private static func assume(layer: CAShapeLayer, path: LPIPathSpec, opacity: Float, options: LPIAnimatedHamburgerOptions, animate: Bool) {
        
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(path.0)
        bezierPath.addLineToPoint(path.1)
        assume(layer, path: bezierPath.CGPath, opacity: opacity, options: options, animate: animate)
    }
    
    private static func assume(layer: CAShapeLayer, path: CGPath?, opacity: Float, options: LPIAnimatedHamburgerOptions, animate: Bool) {
        
        if (animate) {
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.fromValue = layer.path
            pathAnimation.toValue = path
            pathAnimation.duration = options.animationTime
            pathAnimation.timingFunction = options.timingFunction
            layer.addAnimation(pathAnimation, forKey: "Path")
            
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = layer.opacity
            opacityAnimation.toValue = opacity
            opacityAnimation.duration = options.animationTime
            opacityAnimation.timingFunction = options.timingFunction
            layer.addAnimation(opacityAnimation, forKey: "Opacity")
        }
        layer.path = path
        layer.opacity = opacity
    }
    
}


typealias LPIPathSpec = (CGPoint, CGPoint)

typealias LPIAnimatedHamburgerShape = (layers: (CAShapeLayer, CAShapeLayer, CAShapeLayer), animate: Bool, options: LPIAnimatedHamburgerOptions) -> Void

protocol LPIAnimatedHamburgerOptions {
    
    var animationTime:Double { get }
    var timingFunction:CAMediaTimingFunction { get }
    
}