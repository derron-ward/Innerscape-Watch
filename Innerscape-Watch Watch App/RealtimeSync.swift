import Foundation

struct SyncData : Decodable {
    let unity_sync: Bool
    let unity_timestamp: String
    let username: String
    let watch_sync: Bool
    let watch_timestamp: String
}

class RealtimeSync {
    var syncData: SyncData?
    var syncTimer: Timer?
    
    let url = "https://vrtherapy-37023-default-rtdb.firebaseio.com/realtime_sync.json"
    
    init() {
        self.syncTimer = nil
        self.getData()
    }
    
    func getData() {
        guard let url = URL(string: self.url) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, err in
            if let error = err {
                print(error)
                return
            }
            
            if let data = data {
                do {
                    self.syncData = try JSONDecoder().decode(SyncData.self, from: data)
                    
                } catch {
                    print("Error decoding data")
                }
            }
        }
        task.resume()
    }
    
    func watchReady() {
        guard let url = URL(string: self.url) else { return }
        
        // get the date and time
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy h:mm:ss a"
        let dateString = formatter.string(from: now)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.httpBody = "{\"watch_sync\": true, \"watch_timestamp\": \"\(dateString)\"}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, err in
            if let error = err {
                print(error)
                return
            }
        }
        task.resume()
    }
    
    func watchUnready() {
        guard let url = URL(string: self.url) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.httpBody = "{\"watch_sync\": false, \"watch_timestamp\": \"1/1/1970 12:00:00 AM\"}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, err in
            if let error = err {
                print(error)
                return
            }
        }
        task.resume()
    }
    
    private func isSynced() -> Bool {
        if self.syncData == nil {
            return false
        }
    
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy h:mm:ss a"
        
        let watch_timestamp = formatter.date(from: self.syncData?.watch_timestamp ?? "1/1/1970 12:00:00 AM")
        let unity_timestamp = formatter.date(from: self.syncData?.unity_timestamp ?? "1/1/1970 12:00:00 AM")
        
        if (watch_timestamp == nil || unity_timestamp == nil) {
            return false
        }
        let duration = unity_timestamp!.timeIntervalSince(watch_timestamp!)
        
        return (self.syncData!.username != "") && (self.syncData!.watch_sync == true) && (self.syncData!.unity_sync == true) && (duration < 300)
    }
    
    func pollData(callback: @escaping (Bool, String?) -> Void) {
        self.syncTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { _ in
            self.getData()
            callback(self.isSynced(), self.syncData?.username)
        })
    }
    
    func stopPoll() {
        self.syncTimer?.invalidate()
    }
}
