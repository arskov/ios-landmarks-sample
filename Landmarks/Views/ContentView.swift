//
//  ContentView.swift
//  Landmarks
//
//  Created by Arseni Kavalchuk on 4.05.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LandmarkList()
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
}
