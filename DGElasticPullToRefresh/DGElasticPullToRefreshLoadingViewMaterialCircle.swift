//
//  DGElasticPullToRefreshLoadingViewMaterialCircle.swift
//  DGElasticPullToRefreshExample
//
//  Created by Igor Kharytaniuk on 2/12/19.
//  Copyright © 2019 Danil Gontovnik. All rights reserved.
//

import UIKit

open class DGElasticPullToRefreshLoadingViewMaterialCircle: DGElasticPullToRefreshLoadingView {
    
    // MARK: -
    // MARK: Vars
    
    fileprivate let kStrokeAnimation = "strokeAnimation"
    fileprivate let kCircleOutAnimation = "circleOutAnimation"
    
    fileprivate let shapeLayer = CAShapeLayer()
    fileprivate lazy var identityTransform: CATransform3D = {
        var transform = CATransform3DIdentity
        transform.m34 = CGFloat(1.0 / -500.0)
        transform = CATransform3DRotate(transform, CGFloat(180).toRadians(), 0.0, 0.0, 1.0)
        return transform
    }()
    
    public var lineWidth: CGFloat = 1.0 {
        didSet {
            shapeLayer.lineWidth = lineWidth
        }
    }
    
    fileprivate lazy var inAnimation: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        
        return animation
    }()
    
    fileprivate lazy var outAnimation: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.beginTime = 0.5
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        return animation
    }()
    
    fileprivate lazy var circleOutAnimation: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        
        return animation
    }()
    
    fileprivate lazy var rotationAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0.0
        animation.toValue = CGFloat(Double.pi * 2.5)
        animation.duration = 2.0
        animation.repeatCount = MAXFLOAT
        
        return animation
    }()
    
    fileprivate lazy var strokeAnimationGroup: CAAnimationGroup = {
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.0 + self.outAnimation.beginTime
        animationGroup.repeatCount = Float.infinity
        animationGroup.animations = [self.inAnimation, self.outAnimation]
        animationGroup.isRemovedOnCompletion = false
        
        return animationGroup
    }()
    
    
    public var fadeInOnPull: Bool = true
    private var inProgress: Bool = false
    
    // MARK: -
    // MARK: Constructors
    
    public override init() {
        super.init(frame: .zero)
        
        shapeLayer.lineWidth = self.lineWidth
        shapeLayer.fillColor = self.backgroundColor?.cgColor
        shapeLayer.strokeColor = tintColor.cgColor
        shapeLayer.actions = ["strokeEnd" : NSNull(), "transform" : NSNull()]
        shapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.addSublayer(shapeLayer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    // MARK: Methods
    
    override open func setPullProgress(_ progress: CGFloat) {
        super.setPullProgress(progress)
        
        shapeLayer.strokeStart = 0.0
        shapeLayer.strokeEnd = min(progress, 1.0)
        if progress > 1.0 {
            shapeLayer.strokeColor = tintColor.cgColor
        } else {
            if fadeInOnPull {
                shapeLayer.strokeColor = tintColor.withAlphaComponent(progress).cgColor
            }
            shapeLayer.transform = identityTransform
        }
    }
    
    override open func startAnimating() {
        super.startAnimating()
        inProgress = true
        guard shapeLayer.animation(forKey: kStrokeAnimation) == nil &&
            shapeLayer.animation(forKey: kCircleOutAnimation) == nil else {
                return
        }
        startCircleOutAnimation()
    }
    
    private func startCircleOutAnimation() {
        circleOutAnimation.delegate = self
        shapeLayer.strokeStart = 1.0
        shapeLayer.add(self.circleOutAnimation, forKey: kCircleOutAnimation)
    }
    
    private func stopCircleOutAnimation() {
        circleOutAnimation.delegate = nil
        shapeLayer.removeAnimation(forKey: kCircleOutAnimation)
    }
    
    private func startStrokeAnimationGroup() {
        strokeAnimationGroup.delegate = self
        shapeLayer.add(strokeAnimationGroup, forKey: kStrokeAnimation)
    }
    
    private func stopStrokeAnimationGroup() {
        strokeAnimationGroup.delegate = nil
        shapeLayer.removeAnimation(forKey: kStrokeAnimation)
    }
    
    override open func stopLoading() {
        super.stopLoading()
        inProgress = false
        if shapeLayer.animation(forKey: kCircleOutAnimation) != nil {
            stopCircleOutAnimation()
        }
        if shapeLayer.animation(forKey: kStrokeAnimation) != nil {
            stopStrokeAnimationGroup()
        }
    }
    
    fileprivate func currentRotationDegree() -> CGFloat {
        let value = shapeLayer.value(forKeyPath: "transform.rotation.z") as? NSNumber
        return CGFloat(value!.floatValue)
    }
    
    fileprivate func currentStrokeProgress() -> CGFloat {
        let value = shapeLayer.value(forKeyPath: "strokeEnd") as? NSNumber
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
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2.0 - shapeLayer.lineWidth / 2.0
        
        let arcPath = UIBezierPath(arcCenter: CGPoint.zero,
                                   radius: radius,
                                   startAngle: CGFloat(0),
                                   endAngle: CGFloat(2.0 * Double.pi),
                                   clockwise: false)
        
        shapeLayer.position = center
        shapeLayer.path = arcPath.cgPath
    }
    
}


extension DGElasticPullToRefreshLoadingViewMaterialCircle: CAAnimationDelegate {
    
    public func animationDidStart(_ anim: CAAnimation) {
        
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag && inProgress {
            startStrokeAnimationGroup()
        }
    }
    
}
