//
//  LandmarksNotificationView.swift
//  WatchLandmarks Watch App
import SwiftUI

struct LandmarksNotificationView: View {
    
    var body: some View {
        VStack {
            Text("Landmarks Data Received")
                .font(.headline)
            
            Divider()
            
            Text("You received landmarks update")
                .font(.caption)
        }
    }
}

#Preview {
    LandmarksNotificationView()
}
