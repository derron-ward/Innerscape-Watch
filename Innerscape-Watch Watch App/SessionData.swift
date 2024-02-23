import Foundation

class SessionData {
    private var fileURL: URL
    private var data: String
    private var dataTypes: Set<HKDataType>
    
    init(_ dataTypes: Set<HKDataType>) {
        self.fileURL = URL.documentsDirectory.appending(path: "sessionData.csv")
        self.data = ""
        self.dataTypes = dataTypes
        
        var header = "timestamp"
        for type in self.dataTypes {
            header.append(", \(type.objectType.identifier)")
        }
        self.data.append(header + "\n")
    }
    
    func append(data: [String: String]) {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss a"
        
        var dataPoint = formatter.string(from: now)
        for type in self.dataTypes {
            //dataPoint.append(", \(String(describing: data[type.objectType.identifier]))")
            dataPoint.append(", " + data[type.objectType.identifier]!)
        }
        
        print("Appending: " + dataPoint)
        
        self.data.append(dataPoint + "\n")
    }
    
    func endSession() {
        let data = Data(self.data.utf8)
        do {
            try data.write(to: self.fileURL, options: .atomic)
        } catch {
            // error
        }
    }
    
    func getFileURL() -> URL {
        return self.fileURL
    }
}

