---
layout: post
title: Protocol-Oriented Storyboard Instantiating in Swift
subtitle: Make it easier to instantiate view controllers from the storyboard
---

While working on an app recently, I found instantiating view controllers from storyboards pretty frustrating. Although an easy task, it can be very tedious, especially when working with multiple storyboards. We have storyboard names and view controller IDs to keep track of and work with, at many places throughout the app - all in the form of string literals.

### The problem

Instantiating a view controller from a storyboard looks something like this

```swift
let loginVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
```

We use hard-coded string literals for the storyboard name and the view controller identifier (and even a bundle identifier in a rare circumstance). These would need to be copy-pasted, or manually typed out (without any auto-complete help), at every place we'd want to get an instance of `LoginViewController`, which can lead to human error.

### The solution

We introduce a `StoryboardInstantiable` protocol that a `UIViewController` subclass would adopt and conform to, to make getting that information easy.

```swift
protocol StoryboardInstantiable: class {
    static var storyboardName: String { get }
    static var storyboardIdentifier: String { get }
}
```

We can then extend this protocol to provide an implementation of the actual instantiation of a `UIViewController`.

```swift
extension StoryboardInstantiable where Self: UIViewController {
    static func instantiateFromStoryboard() -> Self? {
        return UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: storyboardIdentifier) as? Self
    }
}

// Conform to StoryboardInstantiable
extension LoginViewController: StoryboardInstantiable {
    static var storyboardName: String { return "Login" }
    static var storyboardIdentifier: String { return String(Self) }
}
```

So now, to get an instance of our view controller from the storyboard, we can simply call `instantiateFromStoryboard()` on the class.

```swift
// now get instance
let loginVC = LoginViewController.instantiateFromStoryboard()
```

If your `storyboardIdentifier` is the same - or has similar matching patterns - as the view controller name throughout the app, we can provide a default implementation for our protocol to save (however little) time in the future _where needed_.

```swift
extension StoryboardInstantiable {
    static var storyboardIdentifier: String {
        return String(Self)
    }
}
```

### Conclusion

Swift's Protocol-Oriented approach helps tackle a lot of tedious problems in a very intuitive way, which makes us rely less on hard-coded literal values. 

You can view the gist [here](https://gist.github.com/hdamania/b3d30412c9f014b9566bb7e1f7714ac7).
