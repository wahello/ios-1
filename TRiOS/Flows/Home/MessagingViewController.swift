import UIKit
import Anchorage

final class MessagingViewController: UIViewController {
//  let viewModel: MessagingViewModelType!
  private let conversations: [Conversation]
  private let conversationService: LocalConversationServiceType
  private let audioService: AudioServiceType
  private let onSettingsTapped: () -> Void
  private let onUserSearchTapped: () -> Void

  private lazy var soundWavesViewController = SoundWavesViewController { [unowned self] selectedVoiceMessage in
    print("selected voice message", selectedVoiceMessage)
  }

  private lazy var conversationsViewController = ConversationsViewController(
    conversations: conversations,
    onConversationSelect: { [unowned self] selectedConversation in
      self.currentConversation = selectedConversation
    },
    onAddConversationSelect: { print("add new selected") },
    onConversationRecording: { [unowned self] state in
      switch state {
      case let .started(conversation: conversation):
        do {
          try self.audioService.startRecording(for: conversation) // result?
        } catch {
          print("starting recording error", error)
        }
      case .cancelled:
        do {
          try self.audioService.cancelRecording()
        } catch {
          print("cancelling recording error", error)
        }
      case .ended:
        self.audioService.finishRecording { [weak self] result in
          switch result {
          // TODO
          case let .success((url: url, meters: meters)): ()
          case let .failure(error): ()
          }
        }
      }
    }
  )

  private var currentConversation: Conversation? {
    didSet {
      guard let currentConversation = currentConversation else { return }
      if currentConversation != oldValue {
        conversationService.loadVoiceMessages(for: currentConversation) { [weak self] result in
          if case let .success(voiceMessages) = result {
            self?.soundWavesViewController.voiceMessages = voiceMessages
          }
        }
      }
    }
  }

  @objc private func settingsButtonTapped() { onSettingsTapped() }
  private let settingsButton = UIButton(type: .system).then {
    $0.setTitle("⚙️", for: .normal)
    $0.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
  }

  @objc private func userSearchButtonTapped() { onUserSearchTapped() }
  private let userSearchButton = UIButton(type: .system).then {
    $0.setTitle("🔍", for: .normal)
    $0.addTarget(self, action: #selector(userSearchButtonTapped), for: .touchUpInside)
  }

  // TODO also pass voice messages datasource and conversations data source
  init(conversations: [Conversation],
       conversationService: LocalConversationServiceType,
       audioService: AudioServiceType,
       onSettingsTapped: @escaping () -> Void,
       onUserSearchTapped: @escaping () -> Void) {
    self.conversations = conversations
    // TODO present "add friends screen", or talk to yourself
    currentConversation = conversations.first
    self.conversationService = conversationService
    self.audioService = audioService
    self.onSettingsTapped = onSettingsTapped
    self.onUserSearchTapped = onUserSearchTapped
    super.init(nibName: nil, bundle: nil)
  }

  @available (*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension MessagingViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)

    view.addSubview(settingsButton)
    settingsButton.trailingAnchor == view.trailingAnchor - 20
    settingsButton.topAnchor == view.topAnchor + 30
    settingsButton.heightAnchor == 30

    view.addSubview(userSearchButton)
    userSearchButton.leadingAnchor == view.leadingAnchor + 20
    userSearchButton.topAnchor == settingsButton.topAnchor
    userSearchButton.heightAnchor == settingsButton.heightAnchor

    // TODO
    // add a button to manage friendships FriendshipsButton() (last "conversation")
    // add a button to start recording (tap on one of the conversations)

    addChild(conversationsViewController)
    view.addSubview(conversationsViewController.view)
    conversationsViewController.view.leadingAnchor == view.leadingAnchor
    conversationsViewController.view.trailingAnchor == view.trailingAnchor
    conversationsViewController.view.bottomAnchor == view.bottomAnchor - 30
    conversationsViewController.view.heightAnchor == 100
    conversationsViewController.didMove(toParent: self)

    addChild(soundWavesViewController)
    view.addSubview(soundWavesViewController.view)
//    soundWaveCollectionViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 75)
    soundWavesViewController.view.leadingAnchor == view.leadingAnchor
    soundWavesViewController.view.trailingAnchor == view.trailingAnchor
    soundWavesViewController.view.centerYAnchor == view.centerYAnchor
    soundWavesViewController.view.heightAnchor == 175
    soundWavesViewController.didMove(toParent: self)
  }
}
