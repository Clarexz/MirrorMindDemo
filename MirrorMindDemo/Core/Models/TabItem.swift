//
//  TabItem.swift
//  MirrorMindDemo
//
//  Created by Caleb Martínez Cavazos on 21/08/25.
//


// Core/Models/TabItem.swift
import SwiftUI

enum TabItem: String, CaseIterable, Identifiable {
    case home = "home"
    case momentos = "momentos"
    case chat = "chat"
    case perfil = "perfil"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .home:
            return "Inicio"
        case .momentos:
            return "Momentos"
        case .chat:
            return "Chat"
        case .perfil:
            return "Perfil"
        }
    }
    
    var iconName: String {
        switch self {
        case .home:
            return "house"
        case .momentos:
            return "leaf"
        case .chat:
            return "message"
        case .perfil:
            return "person"
        }
    }
    
    var iconNameFilled: String {
        switch self {
        case .home:
            return "house.fill"
        case .momentos:
            return "leaf.fill"
        case .chat:
            return "message.fill"
        case .perfil:
            return "person.fill"
        }
    }
}