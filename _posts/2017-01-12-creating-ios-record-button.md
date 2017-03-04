---
layout: post
title: Creating a iOS Style Record Button
subtitle: iOS video and voice memo record button in Swift
---

Recently, I had to build a record button interaction, similar to the ones used in the iOS Camera app (for videos) and in the Voice Memos app. Having little experience with `CALayer` and friends, I was excited to take on this task.

<img src="/img/button.gif" width="220" class="center-image" >

### Initial Setup

I started off with by simply adding a outer white ring using a `UIBezierPath`, and the inner filled circle.

```swift
override func draw(_ rect: CGRect) {
    // set outer ring
    let path = UIBezierPath(ovalIn: rect)
    path.lineWidth = ringWidth
    UIColor.white.setStroke()
    UIColor.black.setFill()
    path.fill()
    path.stroke()

    // calculate size for inner circle w.r.t the outer ring
    let sizeDifference = 2*ringWidth
    let originDifference = ringWidth
    var insideRect = rect
    insideRect.size.height = rect.size.height - sizeDifference
    insideRect.size.width = rect.size.width - sizeDifference
    insideRect.origin.x = rect.origin.x + originDifference
    insideRect.origin.y = rect.origin.y + originDifference

    // create and set animating (inner red animating) layer properties
    animatingLayer = CAShapeLayer()
    animatingLayer.frame = insideRect
    animatingLayer.cornerRadius = insideRect.size.height/2.0
    animatingLayer.backgroundColor = UIColor.red.cgColor
    layer.addSublayer(animatingLayer)

    layer.cornerRadius = rect.size.height/2
    layer.masksToBounds = true
}
```
We now have the UI set up for the button.

![Record Button](/img/record-button-ui.png){: .center-image }

### State Transform and Animations

Tapping on the button, should set the button to the recording state, which should also animate the red circle to a rounded square.

![Recording State UI](/img/record-button-selected.png){: .center-image }

We can create state type here to help us out with updating the layer properties for respective states.

```swift
enum RecordButtonState {
    case ready, recording

    mutating func `switch`() {
        self = self == .ready ? .recording : .ready
    }
}

extension RecordButtonState {
    /// transform for button for state. full size when ready, shrunken when recording
    var transform: CATransform3D {
        switch self {
        case .ready: return CATransform3DIdentity
        case .recording: return CATransform3DMakeScale(0.6, 0.6, 0.6)
        }
    }

    /// inner view corner radius. half the height when ready (For full circle) and 8 for rounded square
    var buttonRadius: (CALayer) -> (CGFloat) {
        switch self {
        case .ready: return { layer in return layer.bounds.size.height/2 }
        case .recording: return { _ in return 8 }
        }
    }
}

```

We can now update the button layers for state change in it's target `didPress()` function.
```swift
@objc private func didPress() {
    // get old corner radius for initial animation value
    let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
    cornerRadiusAnimation.fromValue = recordState.buttonRadius(animatingLayer)

    // get old size for initial animation value
    let trasnformAnimation = CABasicAnimation(keyPath: "transform")
    trasnformAnimation.fromValue = recordState.transform

    // switch states
    recordState.switch()

    // set final new corner radius and transform animation values
    cornerRadiusAnimation.toValue = recordState.buttonRadius(animatingLayer)
    trasnformAnimation.toValue = recordState.transform

    // group the animations for smooth effect
    let group = CAAnimationGroup()
    group.animations = [cornerRadiusAnimation, trasnformAnimation]
    group.isRemovedOnCompletion = false
    group.fillMode = kCAFillModeForwards
    group.duration = 0.25

    animatingLayer.add(group, forKey: "all")
}
```

And voila, we have our record button up and running.

<img src="/img/button.gif" width="220" class="center-image" >

You can view the full gist [here](https://gist.github.com/hdamania/af451843e8590794cab3fad9d4a55868).
