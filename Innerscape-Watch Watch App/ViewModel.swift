import Foundation
import HealthKit
import FirebaseStorage

enum Screen {
    case Home
    case Sync
    case Data
}

struct HKDataType : Hashable {
    var objectType: HKQuantityType
    var unitType: HKUnit
}

class ViewModel : ObservableObject {
    @Published var screen = Screen.Home
    
    var realtimeSync: RealtimeSync
    @Published var username = ""
    
    private var dataTypes: Set<HKDataType>
    private var queries: Array<HKObserverQuery>
    @Published var data: [String: String]
    
    var sessionData: SessionData
    
    private let healthStore = HKHealthStore()
    
    init(_ dataTypes: Set<HKDataType>) {
        self.realtimeSync = RealtimeSync()
        self.sessionData = SessionData(dataTypes)
        
        self.dataTypes = dataTypes
        self.queries = Array()
        self.data = [String: String]()
        for type in self.dataTypes {
            self.data[type.objectType.identifier] = ""
        }
    }
    
    private func authState() -> Bool {
        for type in self.dataTypes {
            if self.healthStore.authorizationStatus(for: type.objectType).rawValue != 2 { return false }
        }
        return true
    }

    private func requestHKAuth(dataTypes: Set<HKDataType>, onSuccess: @escaping () -> Void) {
        var types = Set<HKObjectType>()
        
        for type in self.dataTypes {
            types.insert(type.objectType)
        }
        
        self.healthStore.requestAuthorization(toShare: nil, read: types) { success, error in
            if (success) {
                onSuccess()
            } else {
                // handle error
            }
        }
    }
    
    private func safeStartQueries() {
        for type in self.dataTypes {
            let query = HKObserverQuery(sampleType: type.objectType, predicate: nil) { _, _, error in
                guard error == nil else {
                    print("Error: \(error!.localizedDescription)")
                    return
                }
                self.updateDatapoint(dataType: type)
            }

            self.queries.append(query)
            print("Observing \(type.objectType.identifier).")
            
            self.healthStore.execute(query)
//            self.healthStore.enableBackgroundDelivery(for: type.objectType, frequency: .immediate) { success, error in
//                if success {
//                    print("Background delivery enabled for \(type.objectType.identifier).")
//                } else {
//                    print("Failed to enable background delivery for \(type.objectType.identifier).")
//                }
//            }
        }
    }
    
    private func startQueries() {
        print("Starting Queries")
        if !self.authState() {
            self.requestHKAuth(dataTypes: self.dataTypes, onSuccess: self.safeStartQueries)
        }
        else {
            self.safeStartQueries()
        }
    }
    
    private func stopQueries() {
        print("Stopping queries")
        for query in self.queries {
            self.healthStore.stop(query)
        }
        self.queries = Array()
    }
    
    func startSession() {
        self.setScreen(.Sync)
        self.realtimeSync.watchReady()
        self.realtimeSync.pollData(callback: { isSynced, username in
            if username != nil {
                self.username = username ?? ""
            }
            
            if self.screen == .Sync && isSynced {
                self.sessionData = SessionData(self.dataTypes)
                self.startQueries()
                self.setScreen(.Data)
            }
            else if self.screen == .Data && !isSynced {
                self.stopSession()
            }
        })
    }
    
    func stopSession() {
        self.realtimeSync.stopPoll()
        self.realtimeSync.watchUnready()
        self.stopQueries()
        
        self.sessionData.endSession()
        let fileURL = self.sessionData.getFileURL()
        
        let now = Date()
        
        let storage = Storage.storage().reference().child("session_data/watch/\(now.timeIntervalSince1970).csv")
        storage.putFile(from: fileURL) { metadata, error in
            guard metadata != nil, error == nil else {
                print("Failed to upload file")
                print(error!.localizedDescription)
                return
            }
        }

        self.setScreen(.Home)
    }
    
    func cancelSync() {
        self.realtimeSync.stopPoll()
        self.setScreen(.Home)
    }
    
    func updateDatapoint(dataType: HKDataType) {
        let sampleQuery = HKSampleQuery(sampleType: dataType.objectType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, samples, error in
            guard error == nil, let samples = samples as? [HKQuantitySample], let mostRecent = samples.first else {
                print("Error fetching latest \(dataType.objectType.identifier) data: \(String(describing: error?.localizedDescription))")
                return
            }
            let value = mostRecent.quantity.doubleValue(for: dataType.unitType)
            let formattedValue = dataType.unitType == HKUnit.percent() ? String(format: "%.1f%%", value * 100) : String(format: "%.1f", value)

            print("Fetched: \(dataType.objectType.identifier) = \(formattedValue)")

            DispatchQueue.main.async {
                self.data[dataType.objectType.identifier] = formattedValue
            }

            self.sessionData.append(data: self.data)
        }

        self.healthStore.execute(sampleQuery)
    }
    
    
    func setScreen(_ screen: Screen) {
        self.screen = screen
    }
}
