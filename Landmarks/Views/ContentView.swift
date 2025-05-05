//
//  ContentView.swift
//  Landmarks
//
//  Created by Arseni Kavalchuk on 4.05.25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selection: Tab = .featured
    
    enum Tab {
        case featured
        case list
    }
    
    var body: some View {
        TabView(selection: $selection) {
            CategoryHome()
                .tabItem {
                    Label("Featured", systemImage: "star")
                }
                .tag(Tab.featured)
            
            
            LandmarkList()
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
}
