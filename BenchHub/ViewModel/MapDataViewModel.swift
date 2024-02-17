//
//  MapDataViewModel.swift
//  BenchHub
//
//  Created by Shun Sato on 2024/02/06.
//

import Foundation
import FirebaseFirestore

class MapDataViewModel: ObservableObject {
    @Published var mapData = [MapModel]()

    func fetchData() async {
        let db = Firestore.firestore()
        
        do {
            let snapshot = try await db.collection("benchData").getDocuments()
            for document in snapshot.documents {
                let data = document.data()
                let name = data["name"] as? String ?? ""
                let geoPoint = data["geopoint"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
                let latitude = geoPoint.latitude
                let longitude = geoPoint.longitude
                let imageName = "bench"
                
                var reviews: [Review] = []
                if let reviewsData = data["reviews"] as? [[String: Any]] {
                    for reviewData in reviewsData {
                        let description = reviewData["description"] as? String ?? ""
                        let evaluation = reviewData["evaluation"] as? Int ?? 0
                        reviews.append(Review(description: description, evaluation: evaluation))
                    }
                }
                

                let model = MapModel(latitude: latitude, longitude: longitude, name: name, ImageName: imageName, reviews: reviews)
                DispatchQueue.main.async {
                    self.mapData.append(model)
                }

            }
        } catch {
            print("Error getting documents: \(error)")
        }
    }
    
    func addData() {
        
    }
}
