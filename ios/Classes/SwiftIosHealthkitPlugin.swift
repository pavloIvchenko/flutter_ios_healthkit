import Flutter
import UIKit
import HealthKit

struct ResultsDictionary : Codable {
    let immunizations: [FHIRRecord]
    let labResults: [FHIRRecord]
    let vitalSigns: [FHIRRecord]
    let procedures: [FHIRRecord]
}

struct FHIRRecord : Codable {
    let identifier: String
    let resourceType: String
    let sourceURL: String
    let description: String
    let hashValue: Int
    let debugDescription: String
    let data: String
}


public class SwiftIosHealthkitPlugin: NSObject, FlutterPlugin {
    
  let healthStore: HKHealthStore = HKHealthStore()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ios_healthkit", binaryMessenger: registrar.messenger())
    let instance = SwiftIosHealthkitPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print(call.method)
    if call.method == "getMedicalRecords" {
        if #available(iOS 12.0, *) {
            self.getEhrData(result: result)
        } else {
           print("Older iOS version")
        }
    }
    
    if call.method == "requestAuthorization" {
        if #available(iOS 12.0, *) {
            print("Request authorization")
            self.requestAuthorization(result: result)
        } else {
            print("Older iOS version")
        }
    }
    
    if call.method == "getActivityData" {
        if #available(iOS 9.3, *) {
            print("getActivityData")
            self.getActivityData(result: result)
        } else {
            print("Older iOS version")
        }
    }
    
    if call.method == "getStepsData" {
        print("getStepsData")
        self.getStepsData(result: result)
    }
    
    if call.method == "getSleepData" {
        print("getSleepData")
        self.getSleepData(result: result)
    }
    
    if call.method == "getWeightData" {
        print("getWeightData")
        self.getWeightData(result: result)
    }
  }
    
    func getWeightData(result: @escaping FlutterResult) {
        let bodyMassSample = HKObjectType.quantityType(forIdentifier: .bodyMass)
        let calendar = Calendar.autoupdatingCurrent
        let dayComp = DateComponents(month: -3)
        let startDate = Calendar.current.date(byAdding: dayComp, to: Date())
        var startDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: startDate!
        )
        var endDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: Date()
        )
        // This line is required to make the whole thing work
        startDateComponents.calendar = calendar
        endDateComponents.calendar = calendar
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let weightQuery = HKSampleQuery(sampleType: bodyMassSample!, predicate: predicate, limit: 92, sortDescriptors: [sortDescriptor]) { (query, results, error) -> Void in
            
            var bodyMassDict: [String: Double] = [String: Double]()
            
            if error != nil {
                print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                result(nil)
                return
            }
            
            if let myResults = results {
                for item in results! {
                    if let sample = item as? HKQuantitySample {
                        print(sample as Any)
                        print(sample.quantity as Any)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .medium
                        dateFormatter.timeStyle = .none
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let formattedDate = dateFormatter.string(from: sample.startDate)
                        let bodyMass = sample.quantity.doubleValue(for: HKUnit.pound())
                        bodyMassDict[formattedDate] = bodyMass
                        print(bodyMass as Any)
                    }
                }
                do {
                    print("Final encoding")
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try jsonEncoder.encode(bodyMassDict)
                    let jsonString = String(data: jsonData, encoding: .utf8)
                    print(jsonString as Any)
                    result(jsonString)
                    return
                }
                catch {
                    print("Json encode error occured.")
                }
            }
        }
        healthStore.execute(weightQuery)
    }
    
    func getSleepData(result: @escaping FlutterResult) {
        let sleepSample = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        let calendar = Calendar.autoupdatingCurrent
        let dayComp = DateComponents(month: -3)
        let startDate = Calendar.current.date(byAdding: dayComp, to: Date())
        var startDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: startDate!
        )
        var endDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: Date()
        )
        // This line is required to make the whole thing work
        startDateComponents.calendar = calendar
        endDateComponents.calendar = calendar
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let sleepQuery = HKSampleQuery(sampleType: sleepSample!, predicate: predicate, limit: 92, sortDescriptors: [sortDescriptor]) { (query, results, error) -> Void in
            
            var sleepDict: [String: Double] = [String: Double]()
            
            if error != nil {
                print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                result(nil)
                return
            }
            
            if let myResults = results {
                for item in results! {
                    if let sample = item as? HKCategorySample {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .medium
                        dateFormatter.timeStyle = .none
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let formattedDate = dateFormatter.string(from: sample.startDate)
                        let seconds = sample.endDate.timeIntervalSince(sample.startDate)
                        let minutes = seconds/60
                        let value = sleepDict[formattedDate]
                        if value != nil {
                            print(formattedDate)
                            print(value!)
                            sleepDict[formattedDate] = value! + minutes;
                        } else {
                            sleepDict[formattedDate] = minutes
                        }
                    }
                }
                do {
                    print("Final encoding")
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try jsonEncoder.encode(sleepDict)
                    let jsonString = String(data: jsonData, encoding: .utf8)
                    print(jsonString as Any)
                    result(jsonString)
                    return
                }
                catch {
                    print("Json encode error occured.")
                }
            }
        }
        healthStore.execute(sleepQuery)
    }
    
    func getStepsData(result: @escaping FlutterResult) {
        print("Start func")
        let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let calendar = Calendar.autoupdatingCurrent
        let dayComp = DateComponents(month: -3)
        let startDate = Calendar.current.date(byAdding: dayComp, to: Date())
        var startDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: startDate!
        )
        var endDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: Date()
        )
        // This line is required to make the whole thing work
        startDateComponents.calendar = calendar
        endDateComponents.calendar = calendar
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: stepsCount!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startDate!, intervalComponents: interval)

            query.initialResultsHandler = { query, results, error in
                
            print(results!)
                
            var keys: [String] = [String]()
            var values: [Double]  = [Double]()
                
            if error != nil {
                print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                result(nil)
                return
            }
                
            if let myResults = results {
                myResults.enumerateStatistics(from: startDate!, to: Date()) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .medium
                        dateFormatter.timeStyle = .none
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        print("Summary date")
                        let formattedDate = dateFormatter.string(from: statistics.endDate)
                        print(formattedDate)
                        keys.append(formattedDate)
                        let steps = quantity.doubleValue(for: HKUnit.count())
                        values.append(steps)
                        print("Steps = \(steps)")
                        //completion(stepRetrieved: steps)
                        
                    }
                }
                do {
                    let stepsMap = Dictionary(uniqueKeysWithValues: zip(keys, values))
                    print("Final encoding")
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try jsonEncoder.encode(stepsMap)
                    let jsonString = String(data: jsonData, encoding: .utf8)
                    print(jsonString as Any)
                    result(jsonString)
                    return
                }
                catch {
                    print("Json encode error occured.")
                }
            }
        }
        healthStore.execute(query)
    }
    
    @available(iOS 9.3, *)
    func getActivityData(result: @escaping FlutterResult) {
        let calendar = Calendar.autoupdatingCurrent
        let dayComp = DateComponents(month: -3)
        let startDate = Calendar.current.date(byAdding: dayComp, to: Date())
        var startDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: startDate!
        )
        var endDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: Date()
        )
        // This line is required to make the whole thing work
        startDateComponents.calendar = calendar
        endDateComponents.calendar = calendar
        
        let predicate = HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents, end: endDateComponents)
        let activityQuery = HKActivitySummaryQuery(predicate: predicate) { (query, summaries, error) in
            
            var keys: [String] = [String]()
            var values: [Double]  = [Double]()
            
            guard let summaries = summaries, summaries.count > 0
                else {
                    print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                    result(nil)
                    return
            }
            
            // Handle the activity rings data here
            let exerciseUnit = HKUnit.minute()
            
            print(summaries.count)
            
            for summary in summaries {
                let summaryDate = summary.dateComponents(for: calendar)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                dateFormatter.dateFormat = "yyyy-MM-dd"
                print("Summary date")
                let formattedDate = dateFormatter.string(from: summaryDate.date!)
                print(formattedDate)
                keys.append(formattedDate)
                let excercise = summary.appleExerciseTime.doubleValue(for: exerciseUnit)
                print("Excercise")
                print(excercise)
                values.append(excercise)
                print("=========")
            }
            do {
                let activityMap = Dictionary(uniqueKeysWithValues: zip(keys, values))
                print("Final encoding")
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(activityMap)
                let jsonString = String(data: jsonData, encoding: .utf8)
                print(jsonString as Any)
                result(jsonString)
                return
            }
            catch {
                print("Json encode error occured.")
            }
        }
        healthStore.execute(activityQuery)
    }
    
    @available(iOS 12.0, *)
    func requestAuthorization(result: @escaping FlutterResult) {
        
        guard let immunizationType = HKObjectType.clinicalType(forIdentifier: .immunizationRecord),
            let labResultsType = HKObjectType.clinicalType(forIdentifier: .labResultRecord),
            let vitalSignsType = HKObjectType.clinicalType(forIdentifier: .vitalSignRecord),
            let proceduresType = HKObjectType.clinicalType(forIdentifier: .procedureRecord),
            let stepsCount = HKObjectType.quantityType(forIdentifier: .stepCount),
            let sleepTime = HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass)
        else {
            result(nil)
                fatalError("*** Unable to create the requested types ***")
        }
        healthStore.requestAuthorization(toShare: nil, read: [
            immunizationType,
            labResultsType,
            vitalSignsType,
            proceduresType,
            stepsCount,
            sleepTime,
            bodyMass,
            HKObjectType.activitySummaryType()
        ]) { (success, error) in guard success else {
                // Handle errors here.
                result(nil)
                fatalError("*** An error occurred while requesting authorization: \(error!.localizedDescription) ***")
            }
            result("success")
        }
        
    }
    
    @available(iOS 12.0, *)
    func getEhrData(result: @escaping FlutterResult) {

        var fhirDocuments = [FHIRRecord]()
        
        guard let immunizationType = HKObjectType.clinicalType(forIdentifier: .immunizationRecord),
            let labResultsType = HKObjectType.clinicalType(forIdentifier: .labResultRecord),
            let vitalSignsType = HKObjectType.clinicalType(forIdentifier: .vitalSignRecord)
            else {
                result(nil)
                fatalError("*** Unable to create the requested types ***")
        }
        
        let objectTypes: [HKObjectType] = [immunizationType, labResultsType, vitalSignsType]
        let group = DispatchGroup()

        for object in objectTypes {
            group.enter()
            let query = HKSampleQuery(sampleType: object as! HKSampleType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                
                guard let actualSamples = samples else {
                    // Handle the error here.
                    result(nil)
                    print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                    return
                }
                
                let useSamples = actualSamples as? [HKClinicalRecord]
                
                for item in useSamples! {
                    guard let fhirRecord = item.fhirResource else {
                        print("No FHIR record found!")
                        result(nil)
                        return
                    }
                    
                    let entry = FHIRRecord(
                        identifier: fhirRecord.identifier,
                        // ------
                        resourceType: fhirRecord.resourceType.rawValue,
                        // ------
                        sourceURL: fhirRecord.sourceURL!.absoluteString,
                        // ------
                        description: fhirRecord.description,
                        // ------
                        hashValue: fhirRecord.hashValue,
                        // ------
                        debugDescription: fhirRecord.debugDescription,
                        // ------
                        data: String(data: fhirRecord.data, encoding: .utf8)!);
                    // ------
                    fhirDocuments.append(entry)
                }
                group.leave()
            }
            healthStore.execute(query)
        }
        group.notify(queue: .main) {
            do {
                print("Final encoding")
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(fhirDocuments)
                let jsonString = String(data: jsonData, encoding: .utf8)
                print(jsonString as Any)
                result(jsonString)
                return
            }
            catch {
                result(nil)
                print("Json encode error occured.")
            }
        }
        
    }

}
