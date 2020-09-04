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
        
        return Publishers.Zip(nluDownloadPublishers, wakeWordDownloadPublishers).map{nluDownloads, wakeWordDownloads -> Downloads in
            
            return Downloads.init(nluMetaURL: nluDownloads.0,
                                  nluURL: nluDownloads.1,
                                  nluVocabURL: nluDownloads.2,
                                  wakeWordFilter: wakeWordDownloads.0,
                                  wakeWordEncode: wakeWordDownloads.1,
                                  wakeWordDetect: wakeWordDownloads.2)
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
                    .useProfile(.tfLiteWakewordAppleSpeech)
                    .setProperty("tracing", Trace.Level.PERF)
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
    
    func activate() -> Void {

        if self.listeningPublisher.value == false {
            self.pipeline.activate()
        }
    }
    
    func deactive() -> Void {
        
        if self.listeningPublisher.value == true {
            self.pipeline.deactivate()
        }
    }
    
    func synthesizeSpeech(_ input: String) -> Void {
    
        if self.isSilent {
            return
        }

        self.tts?.speak(TextToSpeechInput(input, voice: configuration.voice, inputFormat: configuration.ttsFormat))
    }

    func initializeNLU() -> Void {
        
        self.speechConfiguration.nluModelPath = URL.spsk_documentsDirectory.appendingPathComponent("nlu.tflite").path
        self.speechConfiguration.nluVocabularyPath = URL.spsk_documentsDirectory.appendingPathComponent("vocab.txt").path
        self.speechConfiguration.nluModelMetadataPath = URL.spsk_documentsDirectory.appendingPathComponent("metadata.json").path
        self.nlu = try! NLUTensorflow(self, configuration: self.speechConfiguration)
    }
}

extension SpeechController: NLUDelegate {
 
    func classification(result: NLUResult) {
        
        guard let intentResult: IntentResult = configuration.handleIntent?(result.intent, result.slots, result.utterance) else {
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
    
    func didTrace(_ trace: String) -> Void {
        LogController.shared.log("NLUDelegate didTrace \(trace)", level: .info)
    }
    
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
    
    func success(result: TextToSpeechResult) {
        
        LogController.shared.log("SpeechController result \(String(describing: result.url))")
        
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .success
        event.result = result
        event.url = result.url?.absoluteString
        
        self.configuration.onEvent?(event)
    }
    
    func didBeginSpeaking() {
        
        self.didBeginSpeakingPublisher.send(true)
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .startSpeaking
        
        self.configuration.onEvent?(event)
    }
    
    func didFinishSpeaking() {
        
        self.didFinishSpeakingPublisher.send(true)
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .finishedSpeaking
        
        self.configuration.onEvent?(event)
    }
    
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
    
    func didInit() {
        
        self.startedPublisher.send(true)
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .initialize
        
        self.configuration.onEvent?(event)
    }
    
    func didStart() {
        
        self.startedPublisher.send(true)
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .start
        
        self.configuration.onEvent?(event)
    }
    
    func didStop() {
        
        self.startedPublisher.send(false)
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .stop
        
        self.configuration.onEvent?(event)
    }

    /// The pipeline activate event. Occurs upon activation of speech recognition.
    /// The pipeline remains active until the user stops talking or the activation timeout is reached.
    ///
    /// - SeeAlso:  wakeActiveMin
    func didActivate() -> Void {
        
        self.listeningPublisher.send(true)
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .activate
        
        self.configuration.onEvent?(event)
    }
    
    /// The pipeline deactivate event. Occurs upon deactivation of speech recognition.
    /// The pipeline remains inactive until activated again by either explicit activation or wakeword activation.
    func didDeactivate() -> Void {
        
        self.listeningPublisher.send(false)
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .deactive
        
        self.configuration.onEvent?(event)
    }
    
    /// The error event. An error occured in the speech pipeline.
    /// - Parameter error: A human-readable error message.
    func failure(speechError: Error) -> Void {
        
        self.transcriptResult.send(speechError.localizedDescription)
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .error
        event.error = speechError.localizedDescription
        
        self.configuration.onEvent?(event)
    }
    
    /// The pipeline speech recognition result event. The pipeline was activated and recognized speech.
    /// - Parameter result: The speech recognition result.
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
    func didTimeout() -> Void {
        
        LogController.shared.log("SpeechEventListener didTimeout", level: .info)
        self.didTimeoutPublisher.send(true)
        
        let event: TrayListenerEvent = TrayListenerEvent()
        event.type = .timeout
        
        self.configuration.onEvent?(event)
    }
}



