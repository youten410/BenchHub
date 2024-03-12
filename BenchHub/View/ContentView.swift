//
//  ContentView.swift
//  BenchHub
//
//  Created by Shun Sato on 2024/02/04.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var viewModel = MapDataViewModel()
    @StateObject var detailViewModel = DetailViewModel()
    @StateObject var postViewModel = PostViewModel()
    
    @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State var isShowReviewSheet: Bool = false
    @State var isPost: Bool =  false
    @State var getedData:Bool = false
    @State var showSearchSheet: Bool = true
    @State var inputText: String = ""
    @State var searchText: String = ""
    
    @State var targetCoordinate = CLLocationCoordinate2D()
    @State var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $cameraPosition) {
                UserAnnotation(anchor: .center)
                ForEach(viewModel.mapData) { mapInfo in
                    Annotation(mapInfo.name, coordinate: mapInfo.coordinate) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.orange)
                            Text("🪑")
                                .padding(5)
                        }
                        .onTapGesture {
                            detailViewModel.selectedFramework = mapInfo
                            isShowReviewSheet = true
                            showSearchSheet = false
                        }
                        .sheet(isPresented: $isShowReviewSheet,onDismiss: {
                            showSearchSheet = true
                        }) {
                            DetailView(isShowPostSheet: false, selectedMapInfo: detailViewModel.selectedFramework!, isPostReview: $isPost,isShowReviewSheet: $isShowReviewSheet, isGoodOrBad: false, getedData: $getedData)
                                .presentationDetents([ .medium, .large])
                                .presentationBackground(Color.background)
                        }
                    }
                }
            }
            .task {
                let manager = CLLocationManager()
                manager.requestWhenInUseAuthorization()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .controlSize(.small)
            .onChange(of: getedData) {
                Task {
                    await viewModel.fetchData()
                }
            }
            .onChange(of: searchText, initial: true) { oldValue, newValue in
                print("検索ワード: \(newValue)")
                let request  = MKLocalSearch.Request()
                request.naturalLanguageQuery = newValue
                
                let search = MKLocalSearch(request: request)
                search.start { response, error in
                    if let mapItems = response?.mapItems,
                       let mapItem = mapItems.first {
                        targetCoordinate = mapItem.placemark.coordinate
                        print("緯度経度: \(targetCoordinate)")
                        print(mapItems)
                        cameraPosition = .region(MKCoordinateRegion(
                            center: targetCoordinate,
                            latitudinalMeters: 500.0,
                            longitudinalMeters: 500.0
                            
                        ))
                    }
                }
            }
            .onAppear() {
                cameraPosition = position
                Task {
                    await viewModel.fetchData()
                }
            } // Map
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                Image(systemName: "gear")
                    .padding()
                    .background(Color.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .font(.subheadline)
            }
            .padding(.bottom,100)
            .padding(.trailing,5)
            .controlSize(.small)
        } // ZStack
        .sheet(isPresented: $showSearchSheet) {
            ScrollView(.vertical) {
                HStack(spacing: 15){
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                    
                    TextField("場所を入力して移動", text: $inputText)
                        .onSubmit {
                            searchText = inputText
                            inputText = ""
                        }
                        .submitLabel(.search)
                }
            }
            .presentationDetents([.height(60)])
            .presentationCornerRadius(20)
            .presentationBackground(.thinMaterial)
            .presentationBackgroundInteraction(.enabled(upThrough: .height(60)))
            .interactiveDismissDisabled()
            .padding()
        }
    }
}


#Preview {
    ContentView(isPost: false)
}
