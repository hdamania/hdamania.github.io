---
layout: post
title: Cropping a CAGradientLayer
---

Since the [last]({% link _posts/2017-01-12-creating-ios-record-button.md %}) post, I've had to spend a little bit more time with `CALayer`s. This time, with `CAGradientLayer`.

As you may have guessed, `CAGradientLayer` is a layer object for easily building out gradients. In just a couple lines, we can build a gradient.
```swift
let gradientLayer = CAGradientLayer()
gradientLayer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor, UIColor.green.cgColor]
gradientLayer.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
```
![Gradient](\img\gradient.png){: .center-image }

For business reasons, I just needed to get a cropped part of the gradient layer, still keeping the colors at their original position. While completely possible to convert to a `UIImage` and crop using CoreGraphics, I wanted to keep using this gradient layer.

To do this, I created a mask of a `CAShapeLayer` and applied that to the gradient layer. To compensate for origin offset, we can apply a translate transform on the layer.

```swift
func croppedGradient(to rect: CGRect) -> CALayer {
    let targetPath = UIBezierPath()
    targetPath.move(to: rect.origin)
    targetPath.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
    targetPath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    targetPath.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    targetPath.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
    targetPath.close()

    let shapeMaskingLayer = CAShapeLayer()
    shapeMaskingLayer.path = targetPath.cgPath

    let gradient = gradientLayer
    gradient.mask = shapeMaskingLayer
    gradient.setAffineTransform(CGAffineTransform(translationX: -rect.origin.x, y: -rect.origin.y))

    return gradient
}
```
By applying a crop rect of `(x: 150, y: 50, width: 50, height: 150)` we get

![Cropped Gradient](\img\cropped-gradient.png){: .center-image }

We should use this method carefully when adding as a view layers sublayer, since the transform does affect its origin. Any calculations that needs to be done on frame would be affected. In that case, it might just be better to use CoreGraphics, although a little, but negligibly, more computationally expensive.

You can find the full gist [here](https://gist.github.com/hdamania/7b01a8ff4c8650f08ccbedb3cbfad449).
