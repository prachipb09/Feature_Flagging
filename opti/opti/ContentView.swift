    //
    //  ContentView.swift
    //  opti
    //
    //  Created by Prachi Bharadwaj on 06/09/24.
    //

import SwiftUI
import Optimizely


class AppConfig {
    
    static let shared = AppConfig()
    
    var featureFlags = FeatureFlag()
    private init() {
        
    }
}

struct FeatureFlag {
    init() {
        
    }
     var discountFeautre: Bool = false
}

class Optimizely {
    func setup() {
        let optimizely = OptimizelyClient(sdkKey:"SDK_KEY")
        let user = optimizely.createUserContext(userId: "123")
        
        do {
           try optimizely.start(datafile: "datafileJSON")
            
            let decision = user.decide(key: "feature_discount")
            AppConfig.shared.featureFlags.discountFeautre = decision.enabled
           
        } catch {
                // errors
        }
    }
}


struct ContentView: View {
    @State private var isLoading: Bool = false
    var optimizely = OptimizelyClient(sdkKey: "SDK_KEY")
   
    var body: some View {
        VStack(spacing: 32) {
            if isLoading == false {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                Divider().frame(height: 8).background(.blue)
                if AppConfig.shared.featureFlags.discountFeautre {
                    Text("Discount deals!!!")
                    Image(systemName: "cart.badge.plus")
                        .symbolRenderingMode(.multicolor)     
                }
            } else {
                ProgressView().progressViewStyle(.circular)
            }
        }
        .padding()
        .onAppear {
            Task {
                isLoading = true
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask {
                        optimizely.start { result in
                            switch result {
                                case .failure(let error):
                                    print("Optimizely SDK initialization failed: \(error)")
                                    isLoading = false
                                case .success:
                                    print("Optimizely SDK initialized successfully!")
                                    Optimizely().setup()
                                    print(AppConfig.shared.featureFlags.discountFeautre)
                                    isLoading = false
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
