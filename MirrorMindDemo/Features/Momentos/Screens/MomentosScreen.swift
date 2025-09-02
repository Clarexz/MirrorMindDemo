//
//  MomentosScreen.swift
//  MirrorMindDemo
//
//  Created by Demo Momentos Lead on 21/08/25.
//

import SwiftUI

struct MomentosScreen: View {
    var body: some View {
        NavigationView {
            MomentosView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    MomentosScreen()
}
