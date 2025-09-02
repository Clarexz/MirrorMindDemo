//
//  CameraState.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//


//
//  CameraState.swift
//  MirrorMind
//
//  Created by Camera Integration Lead on 21/08/25.
//

import Foundation

// MARK: - Camera State Management
enum CameraState: Equatable {
    case notConfigured
    case denied
    case configured
    case failed(Error)
    
    static func == (lhs: CameraState, rhs: CameraState) -> Bool {
        switch (lhs, rhs) {
        case (.notConfigured, .notConfigured),
             (.denied, .denied),
             (.configured, .configured):
            return true
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}

// MARK: - Camera Permission Status
enum CameraPermissionStatus: Equatable {
    case notDetermined
    case denied
    case authorized
    case restricted
}

// MARK: - Camera Session Status
enum CameraSessionStatus: Equatable {
    case notRunning
    case running
    case interrupted
    case failed(Error)
    
    static func == (lhs: CameraSessionStatus, rhs: CameraSessionStatus) -> Bool {
        switch (lhs, rhs) {
        case (.notRunning, .notRunning),
             (.running, .running),
             (.interrupted, .interrupted):
            return true
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}