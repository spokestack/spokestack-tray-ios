//
//  TrayViewModel.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/11/20.
//

import Foundation
import Combine

final class TrayViewModel: ObservableObject {
    
    // MARK: Internal (properties)
    
    @Published private(set) var shoulOpen: PassthroughSubject<Bool, Never> = PassthroughSubject()
    
    @Published private(set) var foundTranscript: PassthroughSubject<String, Never> = PassthroughSubject()
    
    var configuration: TrayConfiguration = TrayConfiguration() {
        
        didSet {
        
            self.speechController.configuration = configuration
            self.datasource.configuration = configuration
        }
    }
    
    private (set) var isListening: Bool = false
    
    private (set) var isStarted: Bool = false
    
    private (set) var hasChosenToExit: Bool = false
    
    var isSilent: Bool = false {
        
        didSet {
            self.speechController.isSilent = isSilent
        }
    }
    
    var hasOnboarded: Bool = false {
        
        didSet {
            self.speechController.hasOnboarded = hasOnboarded
        }
    }
    
    private (set) var hasGreeted: Bool {
        set {
            self.speechController.hasGreeted = newValue
        }
        get {
            return self.speechController.hasGreeted
        }
    }
    
    // MARK: Private (properties)
    
    private var anyCancellable: Set<AnyCancellable> = []

    private var speechController: SpeechController = SpeechController()
    
    private var permissions: Permission = Permission()
    
    private var cancellables: Set<AnyCancellable> = []
    
    lazy private var datasource: TrayTableViewDatasource = {
        return TrayTableViewDatasource()
    }()
    
    // MARK: Initializers
    
    required init(_ tableView: TableView) {
        
        self.datasource.tableView = tableView
        
        self.speechController.intentResult
            .receive(on: RunLoop.main)
            .sink(receiveValue: {result in

                let message: TrayMessage = TrayMessage(alignment: .left, message: result.prompt)
                self.datasource.add(message)
                    
                /// if `result.node` is in the exit nodes then set `shouldOpen `to `false`
                
                let shouldExit: Bool = !self.configuration.exitNodes.filter({
                    $0.lowercased() == result.node.lowercased()
                }).isEmpty
                
                if shouldExit {

                    self.hasChosenToExit = true
                    
                    if self.isSilent {
                    
                        self.shoulOpen.send(false)
                        self.hasChosenToExit = false
                    }
                }
        })
        .store(in: &cancellables)
        
        self.speechController.startedPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: {started in
                self.isStarted = started
        })
        .store(in: &self.cancellables)
        
        self.speechController.listeningPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: {listening in

                self.isListening = listening
                self.shoulOpen.send(listening)
        })
        .store(in: &cancellables)
        
        self.speechController.stopOnErrorPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: {stop in
                LogController.shared.log("stopOnErrorPublisher \(stop)")
        })
        .store(in: &cancellables)
        
        self.speechController.transcriptResult
            .receive(on: RunLoop.main)
            .sink(receiveValue: {transcript in

                self.foundTranscript.send(transcript)
                let message: TrayMessage = TrayMessage(alignment: .right, message: transcript)
                self.datasource.add(message)
        })
        .store(in: &cancellables)
        
        self.speechController.didFinishSpeakingPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: {finished in

                if finished && !self.hasChosenToExit {
                    
                    self.speechController.activate()

                } else if finished && self.hasChosenToExit {

                    self.shoulOpen.send(false)
                    self.hasChosenToExit = false
                }
        })
        .store(in: &cancellables)
        
        self.speechController.didTimeoutPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: {didTimeout in
                
                self.hasChosenToExit = true
                self.shoulOpen.send(false)
                self.hasChosenToExit = false
            })
            .store(in: &cancellables)
    }
    
    // MARK: Internal (methods)
    
    /// Will start by checking to see if the user has downloaded the NLU and Wakeworld models,
    /// and approved of the the iOS permissions.
    ///
    /// If successful then the NLU models are initialized and the speed pipleline is started
    /// - Returns: Void
    func listen() -> Void {
        self.initializeSetupIfNecessary()
    }
    
    /// Stops the speed pipleline
    /// - Returns: Void
    func stopListening() -> Void {
        self.speechController.stop()
    }
    
    /// If the speech pipeline isn't listening then activate
    /// - Returns: Void
    func activate() -> Void {
        self.speechController.activate()
    }

    /// If the speech pipeline is listening then deactivate
    /// - Returns: Void
    func deactivate() -> Void {
        self.speechController.deactive()
    }
    
    /// Will dispaly and say greeting if this was the first time
    /// the user has opened the tray
    /// 
    /// - Returns: Void
    func initialize() -> Void {
        
        if configuration.sayGreeting {
            self.sayAndDisplayGreetingIfNecessary()
        }
    }
    
    // MARK: Private (methods)
    
    private func initializeSetupIfNecessary() -> Void {
        
        /// Has the user downloaded the models?
        
        if !TrayConfiguration.hasDownloadNLUModels && !TrayConfiguration.hasDownloadWakewordModels {
            
            self.speechController.initializePublisher.sink(receiveCompletion: {completion in

                switch completion {
                    
                    case .failure(let error):
                        
                        LogController.shared.log("error from download \(error)", level: .error)
                        break
                    case .finished:
                        
                        TrayConfiguration.hasDownloadNLUModels = true
                        TrayConfiguration.hasDownloadWakewordModels = true
                        self.speechController.hasOnboarded = true

                        break
                }
                
            }, receiveValue: {(loadingCompleted, models) in

                if loadingCompleted {

                    self.speechController.initializeNLU()
                    self.speechController.start()
                    
                }
            })
            .store(in: &cancellables)

        } else {

            self.speechController.initializeNLU()
            self.speechController.start()
        }
    }
    
    private func sayAndDisplayGreetingIfNecessary() -> Void {
        
        if !self.hasGreeted {

            if !self.isSilent {
                self.speechController.synthesizeSpeech(self.configuration.greeting)
            }
            
            let message: TrayMessage = TrayMessage(alignment: .right, message: self.configuration.greeting)
            self.datasource.add(message)
            self.speechController.hasGreeted = true
        }
    }
}
