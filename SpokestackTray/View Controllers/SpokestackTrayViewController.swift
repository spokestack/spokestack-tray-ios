//
//  SpokestackTrayViewController.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/7/20.
//

import Foundation
import UIKit
import Spokestack
import Combine

private let MicButtonOffset: CGFloat = 30.0

fileprivate extension Selector {
    
    static let panGestureAction: Selector = #selector(SpokestackTrayViewController.handlePanGestureAction(_:))
    static let openTrayAction: Selector = #selector(SpokestackTrayViewController.openTrayAction(_:))
    static let hideTrayButtonAction: Selector = #selector(SpokestackTrayViewController.hideTrayAction(_:))
    static let micPanGestureAction: Selector = #selector(SpokestackTrayViewController.micPanGestureAction(_:))
    static let toggleMuteAction: Selector = #selector(SpokestackTrayViewController.toggleMuteAction(_:))
}

public class SpokestackTrayViewController: ViewController, ObservableObject {

    // MARK: Public (properties)
    
    public enum TrayState {
        case open
        case closed
    }
    
    /// The (readonly) parent view controller which `SpokestackTrayViewController` is added
    /// to as a child view controller.
    /// - Returns UIViewController
    public private (set) var hostController: UIViewController?
    
    /// The  (readonly) `open` or `closed` state of the tray which is published
    /// - Returns TrayState
    @Published public private (set) var trayState: TrayState = .closed
    
    public var configuration: TrayConfiguration {
        return self.viewModel.configuration
    }
    
    // MARK: Private (properties)
    
    private var trayOriginalCenter: CGPoint!
    
    private var cancellables: Set<AnyCancellable> = []
    
    lazy private var panGesture: UIPanGestureRecognizer = {
        
        let gesture: UIPanGestureRecognizer =  UIPanGestureRecognizer(target: self, action: .panGestureAction)
        
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        
        return gesture
    }()

    lazy private var dismissTapGesture: UITapGestureRecognizer = {
        
        let gesture: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: .openTrayAction)
        gesture.require(toFail: micPanGesture)

        return gesture
    }()
    
    lazy private var micPanGesture: UIPanGestureRecognizer = {
        
        let gesture: UIPanGestureRecognizer =  UIPanGestureRecognizer(target: self, action: .micPanGestureAction)

        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        
        return gesture
    }()
    
    lazy private var viewModel: TrayViewModel = {
        return TrayViewModel(self.trayTableView)
    }()
    
    lazy private var trayTableView: TrayTableView = {
        return TrayTableView()
    }()
    
    lazy private var maxTrayYCoordinate: CGFloat = {
        return self.hostController!.view.frame.height * self.configuration.maxHeightPercentage
    }()
    
    lazy private var minTrayYCoordinate: CGFloat = {
        return self.hostController!.view.frame.height * self.configuration.minHeightPercenter
    }()
    
    lazy private var animatedGradientView: AnimatedGradientView = {
       return AnimatedGradientView()
    }()
    
    lazy private var speakerButton: UIButton = {
       
        let speakerButtonImage: UIImage? = configuration.soundOnImage
        let button: UIButton = UIButton(type: .system)
        
        button.addTarget(self, action: .toggleMuteAction, for: .touchUpInside)
        button.setImage(speakerButtonImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy private var grabberHandleContainerView: UIView = {
        
        let view: UIView = UIView()
        
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        /// Grabber Handle
        
        let grabberHandleView: GrabberHandleView = GrabberHandleView()
        view.addSubview(grabberHandleView)

        grabberHandleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5.0).isActive = true
        grabberHandleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        grabberHandleView.widthAnchor.constraint(equalToConstant: 51.0).isActive = true
        grabberHandleView.heightAnchor.constraint(equalToConstant: 6.0).isActive = true
        
        /// Back Button
        
        let imageConfiguration: UIImage.SymbolConfiguration = UIImage.SymbolConfiguration(weight: .light)
        let backButtonImage: UIImage = UIImage(systemName: "arrow.left", withConfiguration: imageConfiguration)!.withTintColor(.black, renderingMode: .alwaysOriginal)
        let backButton: UIButton = UIButton(type: .system)
        
        backButton.addTarget(self, action: .hideTrayButtonAction, for: .touchUpInside)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backButton)
        
        backButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        /// Speaker Button
        
        view.addSubview(speakerButton)
        
        speakerButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        speakerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0).isActive = true
        speakerButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        speakerButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        /// Listening Label

        view.addSubview(listeningLabel)
        
        listeningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        listeningLabel.topAnchor.constraint(equalTo: grabberHandleView.bottomAnchor).isActive = true
        listeningLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        return view
    }()
    
    lazy private var listeningLabel: UILabel = {
       
        let label: UILabel = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.systemGray2
        
        return label
    }()
    
    lazy private var containerView: ContainerView = {
        return ContainerView()
    }()
    
    lazy private var microphoneView: MicrophoneView = {
        return MicrophoneView()
    }()
    
    lazy private var impactGenerator: UIImpactFeedbackGenerator = {
        return UIImpactFeedbackGenerator(style: .heavy)
    }()
    
    // MARK: Initializers
    
    /// Required initiallizer
    /// - Parameters:
    ///   - hostController: The (parent view controller which `SpokestackTrayViewController` is added to as a child view controller.
    ///   - configuration: `TrayConfiguration` instance to customize the tray
    public required convenience init(_ hostController: UIViewController, configuration: TrayConfiguration = TrayConfiguration()) {
        
        self.init()
        self.hostController = hostController
        self.viewModel.configuration = configuration
        self.animatedGradientView.gradientColors = configuration.gradientColors.map{$0.cgColor}
    }
    
    public override init() {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Life Cycle
    
    public override func loadView() {
        
        super.loadView()
        
        self.view = ContainerView(frame: UIScreen.main.bounds)
        self.view.backgroundColor = .white
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setupSubviews()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Public (methods)
    
    /// Initializes the pipeline to start listening
    /// - Returns: Void
    public func listen() -> Void {
        self.viewModel.listen()
    }
    
    /// Tears down the speech pipeline
    /// - Returns: Void
    public func stopListening() -> Void {
        self.viewModel.stopListening()
    }
    
    /// Sets up the subviews and necessary gesture recognizers, as well as, dds the tray to the `hostController`
    ///  If the `hostController` hasn't been set then a `fatalError` will be thrown
    /// - Returns: Void
    public func addToParentView() -> Void {
        
        guard let parentController: UIViewController = self.hostController else {
            fatalError("hostController isn't set")
        }
        
        self.spsk_addToParentController(parentController)
        let xCoordinate: CGFloat = self.configuration.orientation == .left ? parentController.view.frame.minX - parentController.view.frame.width : parentController.view.frame.width
        
        self.view.frame = CGRect(
            x: xCoordinate,
            y: parentController.view.frame.height * self.configuration.minHeightPercenter,
            width: parentController.view.frame.width,
            height: parentController.view.frame.height
        )
        
        trayOriginalCenter = self.view.center
        
        /// Gradient View
        
        self.view.addSubview(self.animatedGradientView)
        
        self.animatedGradientView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.animatedGradientView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.animatedGradientView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.animatedGradientView.heightAnchor.constraint(equalToConstant: 10.0).isActive = true
    
        /// Microphone View
        
        self.view.addSubview(self.microphoneView)        
        self.microphoneView.orientation = self.configuration.orientation

        let xAxisAnchor: NSLayoutXAxisAnchor = self.configuration.orientation == .left ? self.view.trailingAnchor : self.view.leadingAnchor
        let microPhoneViewXAxis: NSLayoutXAxisAnchor = self.configuration.orientation == .left ? self.microphoneView.trailingAnchor : self.microphoneView.leadingAnchor
        let microPhoneViewOffset: CGFloat = self.configuration.orientation == .left ? MicButtonOffset : -MicButtonOffset
        
        self.microphoneView.topAnchor.constraint(equalTo: self.animatedGradientView.bottomAnchor).isActive = true
        microPhoneViewXAxis.constraint(equalTo: xAxisAnchor, constant: microPhoneViewOffset).isActive = true

        /// Grabber Handle Container View
        
        self.view.addSubview(self.grabberHandleContainerView)
        
        self.grabberHandleContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.grabberHandleContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.grabberHandleContainerView.topAnchor.constraint(equalTo: self.animatedGradientView.bottomAnchor).isActive = true
        self.grabberHandleContainerView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        
        /// Tray TableView
        
        self.view.addSubview(self.trayTableView)
        
        self.trayTableView.topAnchor.constraint(equalTo: self.grabberHandleContainerView.bottomAnchor).isActive = true
        self.trayTableView.bottomAnchor.constraint(equalTo: parentController.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.trayTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.trayTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        /// Gestures
        
        self.microphoneView.addGestureRecognizer(self.dismissTapGesture)
        self.microphoneView.addGestureRecognizer(self.micPanGesture)
    }
    
    /// Tells the speech pipeline to stop listening and removes the tray from the parent view controller
    /// - Returns: Void
    public func removeFromParentView() -> Void {
        
        /// Shutdown Spokestack
        
        self.viewModel.stopListening()
        
        /// Remove from view hiearchy
        
        self.spsk_removeFromParentController()
    }
    
    // MARK: Private (methods)
    
    private func setupSubviews() -> Void {
        
        self.addToParentView()
        
        let tableFooterViewFrame: CGRect = CGRect(x: 0, y: 0, width: self.trayTableView.frame.width, height: 44.0)
        self.trayTableView.tableFooterView = TrayTableViewHeaderFooter(frame: tableFooterViewFrame)
        self.grabberHandleContainerView.addGestureRecognizer(panGesture)
        
        self.viewModel.shoulOpen.sink(receiveValue: {shouldOpen in
            
            if shouldOpen {
                
                /// Need to have a flag and logic for the greeting just like other defaults
                
                self.openTrayAction(nil)
                
                /// Has the user been greeted
                
                if !self.viewModel.hasGreeted {

                    self.viewModel.initialize()
                    return
                }
                
                self.animatedGradientView.startAnimation()
                self.listeningLabel.text = "Listening..."
                
                /// Send haptic feedback
                
                if self.configuration.useHaptic {
                    self.impactGenerator.impactOccurred()
                }
                
            } else {

                if self.viewModel.hasChosenToExit {
                    self.hideTrayAction(nil)
                }
            }
        })
        .store(in: &self.cancellables)
        
        self.viewModel.foundTranscript.sink(receiveValue: {transcript in
            
            self.animatedGradientView.stopAnimation()
            self.listeningLabel.text = nil
        })
        .store(in: &self.cancellables)
    }
}

fileprivate extension SpokestackTrayViewController {
    
    @objc func handlePanGestureAction(_ gesture: UIPanGestureRecognizer) -> Void {

        guard let parentController: UIViewController = self.hostController else {
            fatalError("hostController isn't set")
        }

        switch gesture.state {
        case .began:
            break
        case .changed:
            
            let parentlocation: CGPoint = gesture.location(in: parentController.view)

            if parentlocation.y >= self.minTrayYCoordinate || parentlocation.y <= self.maxTrayYCoordinate  {
                return
            }
            
            self.view.frame = CGRect(
                x: parentController.view.frame.minX,
                y: parentlocation.y,
                width: parentController.view.frame.width,
                height: parentController.view.frame.height
            )
        case .ended:
            gesture.setTranslation(.zero, in: self.view)
        default:
            break
        }
    }

    @objc func openTrayAction(_ gesture: UITapGestureRecognizer?) -> Void {

        guard let parentController: UIViewController = self.hostController else {
            fatalError("hostController isn't set")
        }
        
        if self.trayState == .open {
            return
        }
        
        self.trayState = .open
        self.viewModel.activate()

        let xCoordinate: CGFloat = parentController.view.frame.minX
        var newFrame: CGRect = self.view.frame
        newFrame.origin.x = xCoordinate

        UIView.animate(withDuration: configuration.duration, animations: {
            
            self.view.frame = newFrame

        }, completion: {isFinished in
            
            if isFinished {
                self.configuration.onOpen?()
            }
        })
    }
    
    @objc func hideTrayAction(_ sender: AnyObject?) -> Void {
        
        guard let parentController: UIViewController = self.hostController else {
            fatalError("hostController isn't set")
        }
        
        if self.trayState == .closed {
            return
        }
        
        self.animatedGradientView.stopAnimation()
        self.trayState = .closed
        self.viewModel.deactivate()
        
        let xCoordinate: CGFloat = self.configuration.orientation == .left ? parentController.view.frame.minX - parentController.view.frame.width : parentController.view.frame.width
        var newFrame: CGRect = self.view.frame
        newFrame.origin.x = xCoordinate

        UIView.animate(withDuration: configuration.duration,
                       delay: configuration.closeDelay,
                       options: configuration.easing, animations: {[unowned self] in
                        
                        self.view.frame = newFrame

        }, completion: {isFinished in
            
            if isFinished {
                self.configuration.onClose?()
            }
        })
    }
    
    @objc func micPanGestureAction(_ gesture: UIPanGestureRecognizer) -> Void {

        guard let parentController: UIViewController = self.hostController else {
            fatalError("hostController isn't set")
        }

        let translation: CGPoint = gesture.translation(in: self.view)
        let parentControllerCenter: CGPoint = parentController.view.center
        
        gesture.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
        
        switch gesture.state {
            case .began:
                break
            case .changed:

                self.view.center = CGPoint(x: self.view.center.x + translation.x, y: self.view.center.y)
                break
            case .ended:
                
                let shouldOpen: Bool
                shouldOpen = self.view.center.x > MicButtonOffset ? true : false
                
                UIView.animate(withDuration: self.configuration.duration,
                               delay: 0,
                               usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 0.3,
                               options: .curveEaseInOut,
                               animations: {
                                
                                if shouldOpen {

                                    self.view.center = CGPoint(x: parentControllerCenter.x, y: self.view.center.y)

                                } else {

                                    self.view.center = self.trayOriginalCenter
                                }
                            }, completion: {finished in
                                
                                if finished {
                                    
                                    self.trayState = shouldOpen ? .open : .closed
                                    
                                    if shouldOpen {
                                        self.configuration.onOpen?()
                                    }
                                }
                            }
                )
                break
            default:
                break
        }
        
        gesture.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
    }
    
    @objc func toggleMuteAction(_ sender: AnyObject?) -> Void {
        
        self.viewModel.isSilent.toggle()
        let toggleMuteImage: UIImage? = self.viewModel.isSilent ? configuration.soundOffImage : configuration.soundOnImage
        
        self.speakerButton.setImage(toggleMuteImage, for: .normal)
    }
}
