/*

The MIT License (MIT)

Copyright (c) 2015 Danil Gontovnik

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

import UIKit

// MARK: -
// MARK: (CGFloat) Extension

public extension CGFloat {
    
    public func toRadians() -> CGFloat {
        return (self * CGFloat.pi) / 180.0
    }
    
    public func toDegrees() -> CGFloat {
        return self * 180.0 / CGFloat.pi
    }
    
}

// MARK: -
// MARK: DGElasticPullToRefreshLoadingViewCircle

open class DGElasticPullToRefreshLoadingViewCircle: DGElasticPullToRefreshLoadingView {
    
    // MARK: -
    // MARK: Vars
    
    fileprivate let kRotationAnimation = "kRotationAnimation"
    
    fileprivate let shapeLayer = CAShapeLayer()
    fileprivate lazy var identityTransform: CATransform3D = {
        var transform = CATransform3DIdentity
        transform.m34 = CGFloat(1.0 / -500.0)
        transform = CATransform3DRotate(transform, CGFloat(-90.0).toRadians(), 0.0, 0.0, 1.0)
        return transform
    }()

    public var lineWidth: CGFloat = 1.0 {
        didSet {
            shapeLayer.lineWidth = lineWidth
        }
    }
    
    public var fadeInOnPull: Bool = true
    
    fileprivate lazy var rotationAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = 2.0 * CGFloat.pi
        animation.duration = 1.0
        animation.repeatCount = Float.infinity
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        return animation
    }()
    
    // MARK: -
    // MARK: Constructors
    
    public override init() {
        super.init(frame: .zero)
        
        shapeLayer.lineWidth = self.lineWidth
        shapeLayer.fillColor = self.backgroundColor?.cgColor
        shapeLayer.strokeColor = tintColor.cgColor
        shapeLayer.actions = ["strokeEnd" : NSNull(), "transform" : NSNull()]
        shapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        shapeLayer.rasterizationScale = UIScreen.main.scale
        shapeLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(shapeLayer)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    // MARK: Methods
    
    override open func setPullProgress(_ progress: CGFloat) {
        super.setPullProgress(progress)
        
        shapeLayer.strokeEnd = min(0.9 * progress, 0.9)
        
        if progress > 1.0 {
            let degrees = ((progress - 1.0) * 200.0)
            shapeLayer.strokeColor = tintColor.cgColor
            shapeLayer.transform = CATransform3DRotate(identityTransform, degrees.toRadians(), 0.0, 0.0, 1.0)
        } else {
            if fadeInOnPull {
                shapeLayer.strokeColor = tintColor.withAlphaComponent(progress).cgColor
            }
            shapeLayer.transform = identityTransform
        }
    }
    
    override open func startAnimating() {
        super.startAnimating()
        
        if shapeLayer.animation(forKey: kRotationAnimation) != nil { return }
        
        rotationAnimation.toValue = 2.0 * CGFloat.pi + currentDegree()
        shapeLayer.add(rotationAnimation, forKey: kRotationAnimation)
    }
    
    override open func stopLoading() {
        super.stopLoading()
        
        shapeLayer.removeAnimation(forKey: kRotationAnimation)
    }
    
    fileprivate func currentDegree() -> CGFloat {
        let value = shapeLayer.value(forKeyPath: "transform.rotation.z") as? NSNumber
        return CGFloat(value!.floatValue)
    }
    
    override open func tintColorDidChange() {
        super.tintColorDidChange()
        
        shapeLayer.strokeColor = tintColor.cgColor
    }
    
    // MARK: -
    // MARK: Layout
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        shapeLayer.frame = bounds
        
        let inset = self.lineWidth / 2.0
        shapeLayer.path = UIBezierPath(ovalIn: shapeLayer.bounds.insetBy(dx: inset, dy: inset)).cgPath
    }
    
}
