//
//  Permissions.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/24/20.
//

import Foundation
import AVFoundation
import Speech
import Combine

class Permission {
    private var cancellables = [AnyCancellable]()
    
    // MARK: Internal (properties)
    
    var hasGrantedPermissions: AnyPublisher<Bool, TraySetupInitializeError> {
        
        return Future {promise in
            
            self.hasGrantedMicPermission.combineLatest(self.hasGrantedSpeechPermission).sink(receiveValue: {grantedMic, grantedSpeech in
                
                if grantedMic && grantedSpeech {
                    promise(.success(true))
                } else if !grantedMic && !grantedSpeech {
                    promise(.failure(.deniedBoth))
                } else if !grantedMic {
                    promise(.failure(.deniedMicrophone))
                } else if !grantedSpeech {
                    promise(.failure(.deniedSpeech))
                }
            })
            .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }

    var hasGrantedMicPermission: Future<Bool, Never> {
        
        return Future {promise in
            
            switch AVAudioSession.sharedInstance().recordPermission {
                case .undetermined:
                    AVAudioSession.sharedInstance().requestRecordPermission({granted in
                        promise(.success(granted))
                    })
                    break
                case .granted:
                    promise(.success(true))
                    break
                case .denied:
                    promise(.success(false))
                    break
                @unknown default:
                    promise(.success(false))
            }
        }
    }
    
    var hasGrantedSpeechPermission: Future<Bool, Never> {
        
        return Future {promise in
            
            switch SFSpeechRecognizer.authorizationStatus() {
                case .authorized:
                    promise(.success(true))
                    break
                case .denied:
                    promise(.success(false))
                    break
                case .notDetermined:
                    
                    SFSpeechRecognizer.requestAuthorization{authStatus in
                        DispatchQueue.main.async {
                         
                            switch authStatus {
                                 case .authorized:
                                    promise(.success(true))
                                    break
                                 case .restricted, .notDetermined, .denied:
                                    promise(.success(false))
                                    break
                                @unknown default:
                                    promise(.success(false))
                            }
                        }
                    }
                    
                    break
                case .restricted:
                    promise(.success(false))
                    break
                @unknown default:
                    promise(.success(false))
            }
        }
    }
}
