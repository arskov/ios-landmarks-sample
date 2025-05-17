//
//  ModelData.swift
//  Landmarks
//
//  Created by Arseni Kavalchuk on 4.05.25.
//

import Foundation

extension Notification.Name {
    static let didReceiveLandmarks = Notification.Name("didReceiveLandmarks")
}

struct LandmarksInfo: Hashable, Codable {
    var landmarks: [Landmark]
}

@Observable
class ModelData {
    var landmarks: [Landmark] = []
    var hikes: [Hike] = []
    var profile = Profile.default

    var categories: [String: [Landmark]] {
        Dictionary(
            grouping: landmarks,
            by: { $0.category.rawValue }
        )
    }
    
    var features: [Landmark] {
       landmarks.filter { $0.isFeatured }
    }
    
    var landmarksInfo = LandmarksInfo(landmarks: loadData("landmarkData.json"))
    var receivedLandmarks: [Landmark] = []
    
    init() {
        self.hikes = loadData("hikeData.json")
        #if os(watchOS)
        NotificationCenter.default.addObserver(forName: .didReceiveLandmarks, object: nil, queue: .main) { notification in
            let landmarkInfo = notification.object as! LandmarksInfo
            self.landmarks = landmarkInfo.landmarks
        }
        #else
        self.landmarks = loadData("landmarkData.json")
        #endif
    }
}

func loadData<T: Decodable>(_ filename: String) -> T {
    let data: Data


    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }


    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }


    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
