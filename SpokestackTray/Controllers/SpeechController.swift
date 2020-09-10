//
//  SpeechController.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/23/20.
//

import Foundation
import Spokestack
import Combine
import AVFoundation

typealias ModelDownloadPublisherURLs = ((nluMeta: URL, nluModel: URL, nluVocab: URL),(wwFilter: URL, wwEncode: URL, wwDetect: URL))

final class SpeechController: NSObject, ObservableObject {
    
    // MARK: Internal (properties)
    
    @Published var intentResult: PassthroughSubject<IntentResult, Never> = PassthroughSubject()
    
    @Published var transcriptResult: PassthroughSubject<String, Never> = PassthroughSubject()

    @Published var initPublisher: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    
    @Published var startedPublisher: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    
    @Published var listeningPublisher: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    
    @Published var stopOnErrorPublisher: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    
    @Published var didBeginSpeakingPublisher: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    
    @Published var didFinishSpeakingPublisher: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    
    @Published var didTimeoutPublisher: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    
    var configuration: TrayConfiguration!
    
    var isSilent: Bool = false
    
    var sayGreeting: Bool {
        
        set {
            self.configuration.sayGreeting = newValue
        }
        get {
            return self.configuration.sayGreeting
        }
    }
    
    var hasOnboarded: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "TrayHasOnboarded")
        }
        get {
            UserDefaults.standard.bool(forKey: "TrayHasOnboarded")
        }
    }
    
    var hasGreeted: Bool {
        
        set {
            UserDefaults.standard.set(newValue, forKey: "TrayHasGreeted")
        }
        get {
            UserDefaults.standard.bool(forKey: "TrayHasGreeted")
        }
    }

    lazy var initializePublisher: AnyPublisher<(Bool, Downloads),TraySetupInitializeError>  = {

        var errorMappedDownloadsPublisher: AnyPublisher<Downloads, TraySetupInitializeError> {
            
            return self.downloadsPublisher.mapError{ error -> TraySetupInitializeError in
                
                if let error = error as? TraySetupInitializeError {
                    return error
                }
                
                if let urlerror = error as? URLError {
                    return TraySetupInitializeError.invalidModelDownloadStatus
                }
                
                return TraySetupInitializeError.unknown
            }
            .eraseToAnyPublisher()
        }
        
        return Publishers.CombineLatest(self.permissions.hasGrantedPermissions, errorMappedDownloadsPublisher).eraseToAnyPublisher()
    }()
    
    // MARK: Private (properties)

    private var tts: TextToSpeech?
    
    private var nlu: NLUTensorflow?
    
    private var canStart: Bool = true
    
    private var cancelleables: Set<AnyCancellable> = []
    
    lazy private var speechConfiguration: SpeechConfiguration = {
        return SpeechConfiguration()
    }()
    
    private var permissions: Permission = Permission()
    
    private var downloadsPublisher: AnyPublisher<Downloads, Error> {

        let nluDownloadPublishers = Publishers.Zip3(downloadNLU, downloadNLUMetaData, downloadNLUVocab)
        let wakeWordDownloadPublishers = Publishers.Zip3(downloadWakeWordFilter, downloadWakeWordDetect, downloadWakeWordEncode)
        
        let publishers = Publishers.Zip(nluDownloadPublishers, wakeWordDownloadPublishers).map{ nluDownloads, wakeWordDownloads -> ModelDownloadPublisherURLs in
            
            return (
                (nluMeta: nluDownloads.0, nluModel: nluDownloads.1, nluVocab: nluDownloads.2),
                (wwFilter: wakeWordDownloads.0, wwEncode: wakeWordDownloads.1, wwDetect: wakeWordDownloads.2)
            )
        }
        
        return publishers.map{nluDownloads, wakeWordDownloads -> Downloads in
            
            return Downloads.init(nluMetaURL: nluDownloads.nluMeta,
                                  nluURL: nluDownloads.nluModel,
                                  nluVocabURL: nluDownloads.nluVocab,
                                  wakeWordFilter: wakeWordDownloads.wwFilter,
                                  wakeWordEncode: wakeWordDownloads.wwEncode,
                                  wakeWordDetect: wakeWordDownloads.wwDetect)
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    private var downloadWakeWordFilter: AnyPublisher<URL, Error> {
        
        let url: URL = URL(string: configuration.wakewordModelURLs[WakeWordModelFilterKey]!)!
        return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { response -> URL in
                        
                    guard let httpURLResponse = response.response as? HTTPURLResponse, httpURLResponse.statusCode == 200 else {
                        throw TraySetupInitializeError.invalidModelDownloadStatus
                    }
                    
                    let metaDataURL: URL = URL.spsk_documentsDirectory.appendingPathComponent(url.lastPathComponent)
                    try? response.data.write(to: metaDataURL)
                    
                    return metaDataURL
                }
                .eraseToAnyPublisher()
    }
    
    private var downloadWakeWordDetect: AnyPublisher<URL, Error> {
        
        let url: URL = URL(string: configuration.wakewordModelURLs[WakeWordModelDetectKey]!)!
        return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { response -> URL in
                        
                    guard let httpURLResponse = response.response as? HTTPURLResponse, httpURLResponse.statusCode == 200 else {
                        throw TraySetupInitializeError.invalidModelDownloadStatus
                    }
                    
                    let metaDataURL: URL = URL.spsk_documentsDirectory.appendingPathComponent(url.lastPathComponent)
                    try? response.data.write(to: metaDataURL)
                    
                    return metaDataURL
                }
                .eraseToAnyPublisher()
    }
    
    private var downloadWakeWordEncode: AnyPublisher<URL, Error> {
        
        let url: URL = URL(string: configuration.wakewordModelURLs[WakeWordModelEncodeKey]!)!
        return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { response -> URL in
                        
                    guard let httpURLResponse = response.response as? HTTPURLResponse, httpURLResponse.statusCode == 200 else {
                        throw TraySetupInitializeError.invalidModelDownloadStatus
                    }
                    
                    let metaDataURL: URL = URL.spsk_documentsDirectory.appendingPathComponent(url.lastPathComponent)
                    try? response.data.write(to: metaDataURL)
                    
                    return metaDataURL
                }
                .eraseToAnyPublisher()
    }

    private var downloadNLUMetaData: AnyPublisher<URL, Error> {
        
        let url: URL = URL(string: configuration.nluModelURLs[NLUModelURLMetaDataKey]!)!
        return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { response -> URL in
                        
                    guard let httpURLResponse = response.response as? HTTPURLResponse, httpURLResponse.statusCode == 200 else {
                        throw TraySetupInitializeError.invalidModelDownloadStatus
                    }
                    
                    let metaDataURL: URL = URL.spsk_documentsDirectory.appendingPathComponent(url.lastPathComponent)
                    try? response.data.write(to: metaDataURL)
                    
                    return metaDataURL
                }
                .eraseToAnyPublisher()
    }
    
    private var downloadNLU: AnyPublisher<URL, Error> {
        
        let url: URL = URL(string: configuration.nluModelURLs[NLUModelURLNLUKey]!)!
        return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { response -> URL in
                        
                    guard let httpURLResponse = response.response as? HTTPURLResponse, httpURLResponse.statusCode == 200 else {
                        throw TraySetupInitializeError.invalidModelDownloadStatus
                    }
                    
                    let metaDataURL: URL = URL.spsk_documentsDirectory.appendingPathComponent(url.lastPathComponent)
                    try? response.data.write(to: metaDataURL)
                    
                    return metaDataURL
                }
                .eraseToAnyPublisher()
    }
    
    private var downloadNLUVocab: AnyPublisher<URL, Error> {
        
        let url: URL = URL(string: configuration.nluModelURLs[NLUModelURLVocabKey]!)!
        return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { response -> URL in
                        
                    guard let httpURLResponse = response.response as? HTTPURLResponse, httpURLResponse.statusCode == 200 else {
                        throw TraySetupInitializeError.invalidModelDownloadStatus
                    }
                    
                    let metaDataURL: URL = URL.spsk_documentsDirectory.appendingPathComponent(url.lastPathComponent)
                    try? response.data.write(to: metaDataURL)
                    
                    return metaDataURL
                }
                .eraseToAnyPublisher()
    }

    lazy private var pipeline: SpeechPipeline = {

         return try! SpeechPipelineBuilder()
                    .addListener(self)
                    .setDelegateDispatchQueue(DispatchQueue.main)
                    .useProfile(configuration.speechPipelineProfile)
                    .setProperty("tracing", configuration.traceLevel)
                    .setProperty("detectModelPath", URL.spsk_documentsDirectory.appendingPathComponent("detect.tflite").path)
                    .setProperty("encodeModelPath", URL.spsk_documentsDirectory.appendingPathComponent("encode.tflite").path)
                    .setProperty("filterModelPath", URL.spsk_documentsDirectory.appendingPathComponent("filter.tflite").path)
                    .build()
    }()
    
    // MARK: Initializers
    
    override init() {
        
        super.init()
        tts = TextToSpeech(self, configuration: speechConfiguration)
    }
    
    /// Starts the `SpeechPipeline`
    /// - Returns: Void
    func start() -> Void {

        if self.startedPublisher.value == true || self.listeningPublisher.value == true {
            return
        }
        
        self.pipeline.start()
    }
    
    /// Stops the `SpeechPipeline`
    /// - Returns: Void
    func stop() -> Void {
        self.pipeline.stop()
    }
    
    /// Activates the `SpeechPipeline`
    /// - Returns: Void
    func activate() -> Void {

        if self.listeningPublisher.value == false {
            self.pipeline.activate()
        }
    }
    
    /// Deactivates the `SpeechPipeline`
    /// - Returns: Void
    func deactive() -> Void {
        
        if self.listeningPublisher.value == true {
            self.pipeline.deactivate()
        }
    }
    
    /// Prodnounced Speech to Text
    /// - Returns: Void
    func synthesizeSpeech(_ input: String) -> Void {
    
        if self.isSilent {
            return
        }

        self.tts?.speak(TextToSpeechInput(input, voice: configuration.voice, inputFormat: configuration.ttsFormat))
    }
    
    /// Initializes the `NLUTensorflow` and `SpeechConfiguration`
    /// - Returns: Void
    func initializeNLU() -> Void {
        
        self.speechConfiguration.nluModelPath = URL.spsk_documentsDirectory.appendingPathComponent("nlu.tflite").path
        self.speechConfiguration.nluVocabularyPath = URL.spsk_documentsDirectory.appendingPathComponent("vocab.txt").path
        self.speechConfiguration.nluModelMetadataPath = URL.spsk_documentsDirectory.appendingPathComponent("metadata.json").path
        self.nlu = try! NLUTensorflow(self, configuration: self.speechConfiguration)
    }
}

extension SpeechController: NLUDelegate {
    
    /// The `NLUDelegate` method that takes the `NLUResult` and synthesizes the prompt
    /// if the tray hasn't set the `isSilent` property to `true`.  If `TrayConfiguration.handleIntent` property hasn't
    /// been configured then method is returned immediately.
    /// - Parameter result: NLUResult
    func classification(result: NLUResult) {
        
        guard let intentResult: IntentResult = configuration.handleIntent?(result.intent, result.slots, result.utterance) else {
            
            let errorEvent: TrayListenerEvent = TrayListenerEvent()
            
            errorEvent.type = .error
            errorEvent.error = "THere was wasn't a IntentResult found for \(result.utterance)"
            
            self.configuration.onEvent?(errorEvent)
            return
        }

        self.intentResult.send(intentResult)
        self.synthesizeSpeech(intentResult.prompt)
        
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .classification
        event.result = result
        event.intent = result.intent

        self.configuration.onEvent?(event)
    }
    
    /// Sends the trace to  `LogController.log` with the level set to `info`
    /// - Parameter trace: String
    /// - Returns: Void
    func didTrace(_ trace: String) -> Void {
        LogController.shared.log("NLUDelegate didTrace \(trace)", level: .info)
    }
    
    /// `NLUDelegate` method that is called when an `Error` has occured.
    /// The `nluError` is passed to `LogController.log`with a level of `error` and
    /// the pipeline is stopped
    /// - Parameter nluError: Error
    /// - Returns: Void
    func failure(nluError: Error) -> Void {

        LogController.shared.log("NLUDelegate failure \(nluError)", level: .error)
        
        if self.stopOnErrorPublisher.value {
        
            self.stopOnErrorPublisher.send(false)
            self.stop()
            
            let event: TrayListenerEvent = TrayListenerEvent()
            event.type = .error
            event.error = nluError.localizedDescription

            self.configuration.onEvent?(event)
        }
    }
}

extension SpeechController: TextToSpeechDelegate {
    
    /// `TextToSpeechDelegate` method that is called when a successful `TextToSpeechResult` has been
    ///  processed.
    /// - Parameter result: TextToSpeechResult
    func success(result: TextToSpeechResult) {
        
        LogController.shared.log("SpeechController result \(String(describing: result.url))")
        
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .success
        event.result = result
        event.url = result.url?.absoluteString
        
        self.configuration.onEvent?(event)
    }
    
    /// `TextToSpeechDelegate` method that is called when the speech pipeline has detected that a user
    /// has started to speak. The `didBeginSpeakingPublisher` will send `true` to its subscribers
    func didBeginSpeaking() {
        
        self.didBeginSpeakingPublisher.send(true)
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .startedSpeaking
        
        self.configuration.onEvent?(event)
    }
    
    /// `TextToSpeechDelegate` method that is called when the speech pipeline has detected that a user
    /// has finished speaking. The `didFinishSpeakingPublisher` will send `true` to its subscribers
    func didFinishSpeaking() {
        
        self.didFinishSpeakingPublisher.send(true)
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .finishedSpeaking
        
        self.configuration.onEvent?(event)
    }
    
    /// `TextToSpeechDelegate` method that is called when the speech pipeline has encountered an error.
    /// If the `stopOnErrorPublisher` is currently `true` then the subscribers are sent a `false` value
    /// and the pipleline is stopped
    /// - Returns Void
    func failure(ttsError: Error) -> Void {

        if self.stopOnErrorPublisher.value {
        
            self.stopOnErrorPublisher.send(false)
            self.stop()
            
            let event: TrayListenerEvent = TrayListenerEvent()
            event.type = .stop
            
            self.configuration.onEvent?(event)
        }
    }
}

extension SpeechController: SpeechEventListener {
    
    /// The speech pipeline has been initialized
    /// The `initPublisher` subscribers are sent a `true` value
    func didInit() {
        
        self.initPublisher.send(true)
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .initialize
        
        self.configuration.onEvent?(event)
    }
    
    /// The speech pipeline has been started.
    /// The `startedPublisher` subscribers are sent a `true` value
    func didStart() {
        
        self.startedPublisher.send(true)
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .start
        
        self.configuration.onEvent?(event)
    }
    
    /// The speech pipeline has been stopped.
    /// The `startedPublisher` subscribers are sent a `false` value
    func didStop() {
        
        self.startedPublisher.send(false)
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .stop
        
        self.configuration.onEvent?(event)
    }

    /// The pipeline activate event. Occurs upon activation of speech recognition.
    /// The pipeline remains active until the user stops talking or the activation timeout is reached.
    /// The `listeningPublisher` sends a `true` value to its subscribers
    ///
    /// - Returns: Void
    /// - SeeAlso:  wakeActiveMin
    func didActivate() -> Void {
        
        self.listeningPublisher.send(true)
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .activate
        
        self.configuration.onEvent?(event)
    }
    
    /// The pipeline deactivate event. Occurs upon deactivation of speech recognition.
    /// The pipeline remains inactive until activated again by either explicit activation or wakeword activation.
    /// The `listeningPublisher` sends a `false` value to its subscribers
    ///
    /// - Returns: Void
    func didDeactivate() -> Void {
        
        self.listeningPublisher.send(false)
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .deactive
        
        self.configuration.onEvent?(event)
    }
    
    /// The error event. An error occured in the speech pipeline. The `transcriptResult` sends the error's
    /// `localizedDescription` to the `onEvent` callback
    ///
    /// - Parameter error: A human-readable error message.
    /// - Returns: Void
    func failure(speechError: Error) -> Void {
        
        self.transcriptResult.send(speechError.localizedDescription)
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .error
        event.error = speechError.localizedDescription
        
        self.configuration.onEvent?(event)
    }
    
    /// The pipeline speech recognition result event. The pipeline was activated and recognized speech.
    ///  The `stopOnErrorPublisher` will send a `true` value to its subscribers. If the `result.transcript`
    ///  isn't empty then the `listeningPublisher` will send a `false` value to its subscribers, followed by
    ///  passing the transcript through the configuration's `editTranscript` callback before the `nlu` instance
    ///  attempts to classify it. The `transcriptResult` will send the transcript to its subscribers
    ///
    /// - Parameter result: The speech recognition result.
    /// - Returns: Void
    func didRecognize(_ result: SpeechContext) -> Void {
        
        self.stopOnErrorPublisher.send(true)

        if !result.transcript.isEmpty {
            
            self.listeningPublisher.send(false)
            
            let editTranscript: String = self.configuration.editTranscript?(result.transcript) ?? result.transcript
            self.nlu?.classify(utterance: editTranscript)

            self.transcriptResult.send(result.transcript)
            
            let event: TrayListenerEvent = TrayListenerEvent()
            event.type = .recognize
            event.result = result

            self.configuration.onEvent?(event)
        }
    }
    
    /// The pipeline timeout event. The pipeline experienced a timeout in a component.
    ///  The `didTimeoutPublisher` sends a `true` value to its subscribers
    /// - Returns: Void
    func didTimeout() -> Void {
        
        LogController.shared.log("SpeechEventListener didTimeout", level: .info)
        self.didTimeoutPublisher.send(true)
        
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .timeout
        
        self.configuration.onEvent?(event)
    }
}



