import PlaygroundSupport
import UIKit

@testable import TRAppProxy

let messagingViewController = MessagingViewController(
  onSettingsTapped: { print("settings tapped") },
  onUserSearchTapped: { print("user search tapped") }
)

let parent = playgroundWrapper(
  child: messagingViewController,
  device: .phone4inch,
  orientation: .portrait
)

//CGSize(width: 375, height: 100)

//let containerSize = CGSize(width: 375, height: 400)

//messagingViewController.view.frame.size = containerSize
//messagingViewController.preferredContentSize = containerSize
//parent.preferredContentSize = parent.view.frame.size
//parent.view.frame.size

PlaygroundPage.current.liveView = parent
