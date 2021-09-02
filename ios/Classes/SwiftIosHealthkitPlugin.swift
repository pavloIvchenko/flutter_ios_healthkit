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

struct ActivitySummary: Encodable {
    let appleExerciseTime: Double
    let activeEnergyBurned: Double
    let appleStandHours: Double
}

struct WorkoutSummary: Codable {
    let uuid: UUID
    let duration: TimeInterval
    let totalDistance: Double
    let totalEnergyBurned: Double
    let workoutActivityType: String
    let startDate: Int
    let endDate: Int
    let timezone: String
}

struct HeartRateData: Codable {
    let value: Double
    let quantityType: String
    let startDate: Int
    let endDate: Int
    let timezone: String
}

struct SleepDetails: Codable {
    let uuid: UUID
    let type: String
    let startDate: Int
    let endDate: Int
    let source: String
    let sourceBundleId: String
    let timezone: String
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension HKWorkoutActivityType {

    /*
     Simple mapping of available workout types to a human readable name.
     */
    var name: String {
        switch self {
        case .americanFootball:             return "American Football"
        case .archery:                      return "Archery"
        case .australianFootball:           return "Australian Football"
        case .badminton:                    return "Badminton"
        case .baseball:                     return "Baseball"
        case .basketball:                   return "Basketball"
        case .bowling:                      return "Bowling"
        case .boxing:                       return "Boxing"
        case .climbing:                     return "Climbing"
        case .crossTraining:                return "Cross Training"
        case .curling:                      return "Curling"
        case .cycling:                      return "Cycling"
        case .dance:                        return "Dance"
        case .danceInspiredTraining:        return "Dance Inspired Training"
        case .elliptical:                   return "Elliptical"
        case .equestrianSports:             return "Equestrian Sports"
        case .fencing:                      return "Fencing"
        case .fishing:                      return "Fishing"
        case .functionalStrengthTraining:   return "Functional Strength Training"
        case .golf:                         return "Golf"
        case .gymnastics:                   return "Gymnastics"
        case .handball:                     return "Handball"
        case .hiking:                       return "Hiking"
        case .hockey:                       return "Hockey"
        case .hunting:                      return "Hunting"
        case .lacrosse:                     return "Lacrosse"
        case .martialArts:                  return "Martial Arts"
        case .mindAndBody:                  return "Mind and Body"
        case .mixedMetabolicCardioTraining: return "Mixed Metabolic Cardio Training"
        case .paddleSports:                 return "Paddle Sports"
        case .play:                         return "Play"
        case .preparationAndRecovery:       return "Preparation and Recovery"
        case .racquetball:                  return "Racquetball"
        case .rowing:                       return "Rowing"
        case .rugby:                        return "Rugby"
        case .running:                      return "Running"
        case .sailing:                      return "Sailing"
        case .skatingSports:                return "Skating Sports"
        case .snowSports:                   return "Snow Sports"
        case .soccer:                       return "Soccer"
        case .softball:                     return "Softball"
        case .squash:                       return "Squash"
        case .stairClimbing:                return "Stair Climbing"
        case .surfingSports:                return "Surfing Sports"
        case .swimming:                     return "Swimming"
        case .tableTennis:                  return "Table Tennis"
        case .tennis:                       return "Tennis"
        case .trackAndField:                return "Track and Field"
        case .traditionalStrengthTraining:  return "Traditional Strength Training"
        case .volleyball:                   return "Volleyball"
        case .walking:                      return "Walking"
        case .waterFitness:                 return "Water Fitness"
        case .waterPolo:                    return "Water Polo"
        case .waterSports:                  return "Water Sports"
        case .wrestling:                    return "Wrestling"
        case .yoga:                         return "Yoga"

        // iOS 10
        case .barre:                        return "Barre"
        case .coreTraining:                 return "Core Training"
        case .crossCountrySkiing:           return "Cross Country Skiing"
        case .downhillSkiing:               return "Downhill Skiing"
        case .flexibility:                  return "Flexibility"
        case .highIntensityIntervalTraining:    return "High Intensity Interval Training"
        case .jumpRope:                     return "Jump Rope"
        case .kickboxing:                   return "Kickboxing"
        case .pilates:                      return "Pilates"
        case .snowboarding:                 return "Snowboarding"
        case .stairs:                       return "Stairs"
        case .stepTraining:                 return "Step Training"
        case .wheelchairWalkPace:           return "Wheelchair Walk Pace"
        case .wheelchairRunPace:            return "Wheelchair Run Pace"

        // iOS 11
        case .taiChi:                       return "Tai Chi"
        case .mixedCardio:                  return "Mixed Cardio"
        case .handCycling:                  return "Hand Cycling"

        // iOS 13
        case .discSports:                   return "Disc Sports"
        case .fitnessGaming:                return "Fitness Gaming"

        // Catch-all
        default:                            return "Other"
        }
    }

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
        
        guard let args = call.arguments as? [String: [String]] else {
            result("iOS could not recognize flutter arguments in method: (requestAuthorization)")
            return
        }
        
        print(args)
        
        if #available(iOS 12.0, *) {
            self.requestAuthorization(result: result, wantedCategories: args["wantedCategories"]!)
        } else {
            print("iOS version is not supported")
        }
    }
    
    if call.method == "getFullActivityData" {
        
        guard let args = call.arguments as? [String: Int] else {
            result("iOS could not recognize flutter arguments in method: (getFullActivityData)")
            return
        }
        
        print(args)
        
        if #available(iOS 9.3, *) {
            print("getFullActivityData")
            self.getFullActivityData(result: result, startDate: args["startTime"]!, endDate: args["endTime"]!)
        } else {
            print("Older iOS version")
        }
    }
    
    if call.method == "getActivityTimeData" {
        
        guard let args = call.arguments as? [String: Int] else {
            result("iOS could not recognize flutter arguments in method: (getActivityTimeData)")
            return
        }
        
        print(args)
        
        if #available(iOS 9.3, *) {
            print("getActivityTimeData")
            self.getActivityTimeData(result: result, startDate: args["startTime"]!, endDate: args["endTime"]!)
        } else {
            print("Older iOS version")
        }
    }
    
    if call.method == "getStepsData" {
        guard let args = call.arguments as? [String: Int] else {
            result("iOS could not recognize flutter arguments in method: (getStepsData)")
            return
        }
        
        print(args)
        print("getStepsData")
        self.getStepsData(result: result, startDate: args["startTime"]!, endDate: args["endTime"]!)
    }
    
    if call.method == "getDistance" {
        guard let args = call.arguments as? [String: Int] else {
            result("iOS could not recognize flutter arguments in method: (getDistance)")
            return
        }
        
        print(args)
        print("getDistance")
        self.getDistance(result: result, startDate: args["startTime"]!, endDate: args["endTime"]!)
    }
    
    if call.method == "getFlightsClimbed" {
        guard let args = call.arguments as? [String: Int] else {
            result("iOS could not recognize flutter arguments in method: (getFlightsClimbed)")
            return
        }
        
        print(args)
        print("getFlightsClimbed")
        self.getFlightsClimbed(result: result, startDate: args["startTime"]!, endDate: args["endTime"]!)
    }
    
    if call.method == "getRestingEnergyData" {
        guard let args = call.arguments as? [String: Int] else {
            result("iOS could not recognize flutter arguments in method: (getRestingEnergyData)")
            return
        }
        
        print(args)
        print("getRestingEnergyData")
        self.getRestingEnergyData(result: result, startDate: args["startTime"]!, endDate: args["endTime"]!)
    }
    
    if call.method == "getHeartRateVariability" {
        guard let args = call.arguments as? [String: Int] else {
            result("iOS could not recognize flutter arguments in method: (getHeartRateVariability)")
            return
        }
        
        print(args)
        print("getHeartRateVariability")
        if #available(iOS 11.0, *) {
            self.getHeartRateData(result: result, typeId: HKQuantityTypeIdentifier.heartRateVariabilitySDNN, unit: HKUnit(from: "ms"), startDate: args["startTime"]!, endDate: args["endTime"]!)
        } else {
            print("Older iOS version")
        }
    }
    
    if call.method == "getHeartRateData" {
        guard let args = call.arguments as? [String: Int] else {
            result("iOS could not recognize flutter arguments in method: (getHeartRateData)")
            return
        }
        
        print(args)

        print("getHeartRateData")
        if #available(iOS 9.0, *) {
            self.getHeartRateData(result: result, typeId: HKQuantityTypeIdentifier.heartRate, unit: HKUnit(from: "count/min"), startDate: args["startTime"]!, endDate: args["endTime"]!)
        } else {
            print("Older iOS version")
        }
    }
    
    if call.method == "getRestingHeartRateData" {
        guard let args = call.arguments as? [String: Int] else {
            result("iOS could not recognize flutter arguments in method: (getRestingHeartRateData)")
            return
        }
        
        print(args)
        print("getRestingHeartRateData")
        if #available(iOS 11.0, *) {
            self.getHeartRateData(result: result, typeId: HKQuantityTypeIdentifier.restingHeartRate, unit: HKUnit(from: "count/min"), startDate: args["startTime"]!, endDate: args["endTime"]!)
        } else {
            print("Older iOS version")
        }
    }
    
    if call.method == "getSleepData" {
        guard let args = call.arguments as? [String: Int] else {
            result("iOS could not recognize flutter arguments in method: (getSleepData)")
            return
        }
        
        print(args)
        print("getSleepData")
        self.getSleepData(result: result, startDate: args["startTime"]!, endDate: args["endTime"]!)
    }
    
    if call.method == "getSleepDetails" {
        guard let args = call.arguments as? [String: Int] else {
            result("iOS could not recognize flutter arguments in method: (getSleepDetails)")
            return
        }
        
        print(args)
        print("getSleepDetails")
        self.getSleepDetails(result: result, startDate: args["startTime"]!, endDate: args["endTime"]!)
    }
    
    if call.method == "getWeightData" {
        guard let args = call.arguments as? [String: Int] else {
            result("iOS could not recognize flutter arguments in method: (getWeightData)")
            return
        }
        
        print(args)
        print("getWeightData")
        self.getWeightData(result: result, startDate: args["startTime"]!, endDate: args["endTime"]!)
    }
    
    if call.method == "getWorkoutsData" {
        guard let args = call.arguments as? [String: Int] else {
            result("iOS could not recognize flutter arguments in method: (getWorkoutsData)")
            return
        }
        
        print(args)
        print("getWorkoutsData")
        if #available(iOS 9.3, *) {
            self.getWorkouts(result: result, startDate: args["startTime"]!, endDate: args["endTime"]!)
        } else {
            // Fallback on earlier versions
        }
    }
    
  }
    
    func getWeightData(result: @escaping FlutterResult, startDate: Int, endDate: Int) {
        let bodyMassSample = HKObjectType.quantityType(forIdentifier: .bodyMass)
        let calendar = Calendar.autoupdatingCurrent
        let startDateConverted = Date(timeIntervalSince1970: TimeInterval(startDate))
        let endDateConverted =  Date(timeIntervalSince1970: TimeInterval(endDate))
        var startDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: startDateConverted
        )
        var endDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: endDateConverted
        )
        // This line is required to make the whole thing work
        startDateComponents.calendar = calendar
        endDateComponents.calendar = calendar
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = HKQuery.predicateForSamples(withStart: startDateConverted, end: endDateConverted, options: .strictStartDate)
        
        let weightQuery = HKSampleQuery(sampleType: bodyMassSample!, predicate: predicate, limit: 92, sortDescriptors: [sortDescriptor]) { (query, results, error) -> Void in
            
            var bodyMassDict: [String: Double] = [String: Double]()
            
            if error != nil {
                print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                result(nil)
                return
            }
            
            if results != nil {
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
    
    func getSleepDetails(result: @escaping FlutterResult, startDate: Int, endDate: Int) {
        let sleepSample = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        let calendar = Calendar.autoupdatingCurrent
        let startDateConverted = Date(timeIntervalSince1970: TimeInterval(startDate))
        let endDateConverted =  Date(timeIntervalSince1970: TimeInterval(endDate))
        var startDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: startDateConverted
        )
        var endDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: endDateConverted
        )
        // This line is required to make the whole thing work
        startDateComponents.calendar = calendar
        endDateComponents.calendar = calendar
        
        var sleepSamples: [SleepDetails] = [];
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = HKQuery.predicateForSamples(withStart: startDateConverted, end: endDateConverted, options: .strictStartDate)
        
        let sleepQuery = HKSampleQuery(sampleType: sleepSample!, predicate: predicate, limit: 92, sortDescriptors: [sortDescriptor]) { (query, results, error) -> Void in
                        
            if error != nil {
                print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                result(nil)
                return
            }
        
            
            if results != nil {
                for item in results! {
                    if let sample = item as? HKCategorySample {
                        sleepSamples.append(SleepDetails(
                            uuid: sample.uuid,
                            type: self.getSleepSampleType(sampleValue: sample.value),
                            startDate: Int(sample.startDate.millisecondsSince1970),
                            endDate: Int(sample.endDate.millisecondsSince1970),
                            source: sample.source.name,
                            sourceBundleId: sample.source.bundleIdentifier,
                            timezone: self.getTimeZoneString(sample: sample, shouldReturnDefaultTimeZoneInExceptions: true)!))
                    }
                }
                do {
                    print("Final encoding")
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try jsonEncoder.encode(sleepSamples)
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
    
    func getSleepSampleType(sampleValue: Int) -> String {
        if (sampleValue == HKCategoryValueSleepAnalysis.asleep.rawValue) {
            return "asleep";
        } else if (sampleValue == HKCategoryValueSleepAnalysis.inBed.rawValue) {
            return "inBed";
        } else {
            return "awake";
        }
    }
    
    func getSleepData(result: @escaping FlutterResult, startDate: Int, endDate: Int) {
        let sleepSample = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        let calendar = Calendar.autoupdatingCurrent
        let startDateConverted = Date(timeIntervalSince1970: TimeInterval(startDate))
        let endDateConverted =  Date(timeIntervalSince1970: TimeInterval(endDate))
        var startDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: startDateConverted
        )
        var endDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: endDateConverted
        )
        // This line is required to make the whole thing work
        startDateComponents.calendar = calendar
        endDateComponents.calendar = calendar
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = HKQuery.predicateForSamples(withStart: startDateConverted, end: endDateConverted, options: .strictStartDate)
        
        let sleepQuery = HKSampleQuery(sampleType: sleepSample!, predicate: predicate, limit: 92, sortDescriptors: [sortDescriptor]) { (query, results, error) -> Void in
            
            var sleepDict: [String: Double] = [String: Double]()
            
            if error != nil {
                print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                result(nil)
                return
            }
            
            if results != nil {
                for item in results! {
                    if let sample = item as? HKCategorySample {
                        if (self.getSleepSampleType(sampleValue: sample.value) != "asleep") {
                            continue;
                        }
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
    
    
    @available(iOS 9.0, *)
    func getHeartRateData(result: @escaping FlutterResult, typeId: HKQuantityTypeIdentifier, unit: HKUnit, startDate: Int, endDate: Int) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: typeId)!
        
        let calendar = Calendar.autoupdatingCurrent
        let startDateConverted = Date(timeIntervalSince1970: TimeInterval(startDate))
        let endDateConverted =  Date(timeIntervalSince1970: TimeInterval(endDate))
        var startDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: startDateConverted
        )
        var endDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: endDateConverted
        )
        // This line is required to make the whole thing work
        startDateComponents.calendar = calendar
        endDateComponents.calendar = calendar
        
        let predicate = HKQuery.predicateForSamples(withStart: startDateConverted, end: endDateConverted, options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        let sortDescriptors = [
          NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        ]

        var heartRateEntries: [HeartRateData] = []
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: sortDescriptors) { (query, samples, error) in
            
            guard let actualSamples = samples else {
                // Handle the error here.
                result(nil)
                print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                return
            }
            
            let useSamples = actualSamples as? [HKQuantitySample]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            for item in useSamples! {
                let entry = HeartRateData(
                    value: item.quantity.doubleValue(for: unit),
                    quantityType: item.quantityType.identifier,
                    startDate: Int(item.startDate.millisecondsSince1970),
                    endDate: Int(item.endDate.millisecondsSince1970),
                    timezone: self.getTimeZoneString(sample: item, shouldReturnDefaultTimeZoneInExceptions: true)!)
                heartRateEntries.append(entry)
            }
            do {
                print("Final encoding")
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(heartRateEntries)
                let jsonString = String(data: jsonData, encoding: .utf8)
                print(jsonString as Any)
                result(jsonString)
                return
            }
            catch {
                print("Json encode error occured.")
            }
        }
        healthStore.execute(query)
    
    }
    
    func getRestingEnergyData(result: @escaping FlutterResult, startDate: Int, endDate: Int) {
        let basalEnergy = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)
        
        let calendar = Calendar.autoupdatingCurrent
        let startDateConverted = Date(timeIntervalSince1970: TimeInterval(startDate))
        let truncatedStartDate = Calendar.current.startOfDay(for: startDateConverted)
        print("trunc start")
        print(truncatedStartDate.timeIntervalSince1970)
        let endDateConverted =  Date(timeIntervalSince1970: TimeInterval(endDate))
        print("trunc end")
        let truncatedEndDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDateConverted)
        print(truncatedEndDate?.timeIntervalSince1970 ?? "no end data")
        var startDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: truncatedStartDate
        )
        var endDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: truncatedEndDate!
        )
        // This line is required to make the whole thing work
        startDateComponents.calendar = calendar
        endDateComponents.calendar = calendar
        
        let predicate = HKQuery.predicateForSamples(withStart: truncatedStartDate, end: truncatedEndDate, options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let query = HKStatisticsCollectionQuery(quantityType: basalEnergy!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: truncatedStartDate, intervalComponents: interval)

            query.initialResultsHandler = { query, results, error in
                
            if results != nil {
              print(results)
            } else {
              print("No resting energy data")
            }
                
            var keys: [String] = [String]()
            var values: [Double]  = [Double]()
                
            if error != nil {
                print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                result(nil)
                return
            }
                
            if let myResults = results {
                myResults.enumerateStatistics(from: truncatedStartDate, to: truncatedEndDate ?? endDateConverted) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        print("================================")
                        print("Summary date")
                        print(statistics.startDate.timeIntervalSince1970)
                        print(statistics.endDate.timeIntervalSince1970)
                        let formattedDate = dateFormatter.string(from: statistics.startDate)
                        print(formattedDate)
                        keys.append(formattedDate)
                        let restingEnergy = quantity.doubleValue(for: HKUnit.kilocalorie())
                        values.append(restingEnergy)
                        print("restingEnergy = \(restingEnergy)")
                        print("================================")
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
    
    func getStepsData(result: @escaping FlutterResult, startDate: Int, endDate: Int) {
        print("Start func")
        let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let calendar = Calendar.autoupdatingCurrent
        let startDateConverted = Date(timeIntervalSince1970: TimeInterval(startDate))
        let endDateConverted =  Date(timeIntervalSince1970: TimeInterval(endDate))
        var startDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: startDateConverted
        )
        var endDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: endDateConverted
        )

        // This line is required to make the whole thing work
        startDateComponents.calendar = calendar
        endDateComponents.calendar = calendar
        
        let predicate = HKQuery.predicateForSamples(withStart: startDateConverted, end: endDateConverted, options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: stepsCount!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startDateConverted, intervalComponents: interval)

            query.initialResultsHandler = { query, results, error in

            if results != nil {
              print(results)
            } else {
              print("No steps data")
            }

            var keys: [String] = [String]()
            var values: [Double]  = [Double]()
                
            if error != nil {
                print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                result(nil)
                return
            }
                
            if let myResults = results {
                myResults.enumerateStatistics(from: startDateConverted, to: endDateConverted) {
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
    
    func getDistance(result: @escaping FlutterResult, startDate: Int, endDate: Int) {
        print("Get distance")
        let distance = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
        
        let calendar = Calendar.autoupdatingCurrent
        let startDateConverted = Date(timeIntervalSince1970: TimeInterval(startDate))
        let endDateConverted =  Date(timeIntervalSince1970: TimeInterval(endDate))
        var startDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: startDateConverted
        )
        var endDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: endDateConverted
        )

        // This line is required to make the whole thing work
        startDateComponents.calendar = calendar
        endDateComponents.calendar = calendar
        
        let predicate = HKQuery.predicateForSamples(withStart: startDateConverted, end: endDateConverted, options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: distance!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startDateConverted, intervalComponents: interval)

            query.initialResultsHandler = { query, results, error in

            if results != nil {
              print(results)
            } else {
              print("No distance data")
            }

            var keys: [String] = [String]()
            var values: [Double]  = [Double]()
                
            if error != nil {
                print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                result(nil)
                return
            }
                
            if let myResults = results {
                myResults.enumerateStatistics(from: startDateConverted, to: endDateConverted) {
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
                        let distance = quantity.doubleValue(for: HKUnit.meter())
                        values.append(distance)
                        print("Distance = \(distance)")
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
    
    func getFlightsClimbed(result: @escaping FlutterResult, startDate: Int, endDate: Int) {
        print("flights test")
        let flightsType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)
        
        let calendar = Calendar.autoupdatingCurrent
        let startDateConverted = Date(timeIntervalSince1970: TimeInterval(startDate))
        let endDateConverted =  Date(timeIntervalSince1970: TimeInterval(endDate))
        var startDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: startDateConverted
        )
        var endDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: endDateConverted
        )

        // This line is required to make the whole thing work
        startDateComponents.calendar = calendar
        endDateComponents.calendar = calendar
        
        let predicate = HKQuery.predicateForSamples(withStart: startDateConverted, end: endDateConverted, options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: flightsType!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startDateConverted, intervalComponents: interval)

            query.initialResultsHandler = { query, results, error in

            if results != nil {
              print(results)
            } else {
              print("No flights data")
            }

            var keys: [String] = [String]()
            var values: [Double]  = [Double]()
                
            if error != nil {
                print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                result(nil)
                return
            }
                
            if let myResults = results {
                myResults.enumerateStatistics(from: startDateConverted, to: endDateConverted) {
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
                        let flightsClimbed = quantity.doubleValue(for: HKUnit.count())
                        values.append(flightsClimbed)
                        print("Flights climbed = \(flightsClimbed)")
                        
                    }
                }
                do {
                    let map = Dictionary(uniqueKeysWithValues: zip(keys, values))
                    print("Final encoding")
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try jsonEncoder.encode(map)
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
    func getFullActivityData(result: @escaping FlutterResult, startDate: Int, endDate: Int) {
        let calendar = Calendar.autoupdatingCurrent
        let startDateConverted = Date(timeIntervalSince1970: TimeInterval(startDate))
        let endDateConverted =  Date(timeIntervalSince1970: TimeInterval(endDate))
        var startDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: startDateConverted
        )
        var endDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: endDateConverted
        )
        // This line is required to make the whole thing work
        startDateComponents.calendar = calendar
        endDateComponents.calendar = calendar
        
        let predicate = HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents, end: endDateComponents)
        let activityQuery = HKActivitySummaryQuery(predicate: predicate) { (query, summaries, error) in
            
            var keys: [String] = [String]()
            var values: [ActivitySummary]  = [ActivitySummary]()
            
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
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                print("Summary date")
                print(dateFormatter.timeZone)
                let formattedDate = dateFormatter.string(from: summaryDate.date!)
                print(formattedDate)
                keys.append(formattedDate)
                let appleExerciseTime = summary.appleExerciseTime.doubleValue(for: exerciseUnit)
                print(appleExerciseTime)
                let activeEnergyBurned = summary.activeEnergyBurned.doubleValue(for: HKUnit.kilocalorie())
                print(activeEnergyBurned)
                let appleStandHours = summary.appleStandHours.doubleValue(for: HKUnit.count())
                print(appleStandHours)
                let activitySummary = ActivitySummary(
                    appleExerciseTime: appleExerciseTime,
                    activeEnergyBurned: activeEnergyBurned,
                    appleStandHours: appleStandHours);
                print("Activity summary end")
                values.append(activitySummary)
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
    
    @available(iOS 9.3, *)
    func getActivityTimeData(result: @escaping FlutterResult, startDate: Int, endDate: Int) {
        let calendar = Calendar.autoupdatingCurrent
        let startDateConverted = Date(timeIntervalSince1970: TimeInterval(startDate))
        print(startDateConverted.millisecondsSince1970)
        let endDateConverted =  Date(timeIntervalSince1970: TimeInterval(endDate))
        print(endDateConverted.millisecondsSince1970)
        var startDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: startDateConverted
        )
        var endDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: endDateConverted
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

    
    @available(iOS 9.3, *)
    func requestAuthorization(result: @escaping FlutterResult, wantedCategories: [String]) {
        
        var requestTypes: Set<HKObjectType> = Set()
        
        var dataTypes: [String: HKObjectType] = [:]
        
        if #available(iOS 12.0, *) {
        guard let immunizationType = HKObjectType.clinicalType(forIdentifier: .immunizationRecord),
            let labResultsType = HKObjectType.clinicalType(forIdentifier: .labResultRecord),
            let vitalSignsType = HKObjectType.clinicalType(forIdentifier: .vitalSignRecord),
            let proceduresType = HKObjectType.clinicalType(forIdentifier: .procedureRecord)
            else {
                result(nil)
                print("*** Unable to create the requested types ***")
                return
            }
            
            dataTypes["immunization"] = immunizationType
            dataTypes["labResults"] = labResultsType
            dataTypes["vitalSigns"] = vitalSignsType
            dataTypes["procedures"] = proceduresType
        }
 
        if #available(iOS 11.0, *) {
            guard let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate),
                let heartRateVariability = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
                let walkingHeartRate = HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)
                else {
                    result(nil)
                    print("*** Unable to create the requested types ***")
                    return
            }
            
            dataTypes["restingHeartRate"] = restingHeartRate
            dataTypes["heartRateVariability"] = heartRateVariability
            dataTypes["walkingHeartRate"] = walkingHeartRate
        }
        
        guard let stepsCount = HKObjectType.quantityType(forIdentifier: .stepCount),
              let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
              let flightsClimbed = HKObjectType.quantityType(forIdentifier: .flightsClimbed),
            let sleepTime = HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let restingEnergy = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned),
            let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)
            else {
                result(nil)
                print("*** Unable to create the requested types ***")
                return
            }
        
        dataTypes["steps"] = stepsCount
        dataTypes["distance"] = distance
        dataTypes["sleep"] = sleepTime
        dataTypes["flightsClimbed"] = flightsClimbed
        dataTypes["sleepDetails"] = sleepTime
        dataTypes["weight"] = bodyMass
        dataTypes["restingEnergy"] = restingEnergy
        dataTypes["heartRate"] = heartRate
        dataTypes["activity"] = HKObjectType.activitySummaryType()
        dataTypes["activitySummary"] = HKObjectType.activitySummaryType()
        dataTypes["workouts"] = HKObjectType.workoutType()
        
        for categoryName in wantedCategories {
            if (dataTypes[categoryName] == nil) {
                continue
            }
            requestTypes.insert(dataTypes[categoryName]!);
        }
        
        healthStore.requestAuthorization(toShare: nil, read: requestTypes) { (success, error) in guard success else {
                // Handle errors here.
                result(nil)
                print("*** An error occurred while requesting authorization: \(error!.localizedDescription) ***")
                return
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
                print("*** Unable to create the requested types ***")
                return
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
    
    @available(iOS 9.3, *)
    func getWorkouts(result: @escaping FlutterResult, startDate: Int, endDate: Int) {

        var workouts = [WorkoutSummary]()
        
        let workoutsType = HKObjectType.workoutType()
        
        let objectTypes: [HKObjectType] = [workoutsType]
        let group = DispatchGroup()
        
        let calendar = Calendar.autoupdatingCurrent
        let startDateConverted = Date(timeIntervalSince1970: TimeInterval(startDate))
        let endDateConverted =  Date(timeIntervalSince1970: TimeInterval(endDate))
        var startDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: startDateConverted
        )
        var endDateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: endDateConverted
        )
        // This line is required to make the whole thing work
        startDateComponents.calendar = calendar
        endDateComponents.calendar = calendar
        

        for object in objectTypes {
            group.enter()
            let query = HKSampleQuery(sampleType: object as! HKSampleType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                
                guard let actualSamples = samples else {
                    // Handle the error here.
                    result(nil)
                    print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                    return
                }
                
                let useSamples = actualSamples as? [HKWorkout]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                for item in useSamples! {
                    
                    if (Int(item.startDate.millisecondsSince1970) < startDate * 1000) {
                        continue
                    }
                    let entry = WorkoutSummary(
                        uuid: item.uuid,
                        duration: item.duration,
                        totalDistance: item.totalDistance?.doubleValue(for: HKUnit.meter()) ?? 0.0,
                        totalEnergyBurned: item.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0,
                        workoutActivityType: item.workoutActivityType.name,
                        startDate: Int(item.startDate.millisecondsSince1970),
                        endDate: Int(item.endDate.millisecondsSince1970),
                        timezone: self.getTimeZoneString(sample: item, shouldReturnDefaultTimeZoneInExceptions: true)!)
                    // ------
                    workouts.append(entry)
                }
                group.leave()
            }
            healthStore.execute(query)
        }
        group.notify(queue: .main) {
            do {
                print("Final encoding")
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(workouts)
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
    
    func getTimeZoneString(sample: HKSample? = nil, shouldReturnDefaultTimeZoneInExceptions: Bool = true) -> String? {
      var timeZone: TimeZone?
        print("sample?.metadata?[HKMetadataKeyTimeZone]: \(String(describing: sample?.metadata?[HKMetadataKeyTimeZone]) )")
        print("bundleId: \(String(describing: sample?.source.bundleIdentifier) )")

      if let metaDataTimeZoneValue = sample?.metadata?[HKMetadataKeyTimeZone] as? String {
        timeZone = TimeZone(identifier: metaDataTimeZoneValue)
      }

      if shouldReturnDefaultTimeZoneInExceptions == true && timeZone == nil {
        timeZone = TimeZone.current
      }

      var timeZoneString: String?

      if let timeZone = timeZone {
        let seconds = timeZone.secondsFromGMT()

        let hours = seconds/3600
        let minutes = abs(seconds/60) % 60

        timeZoneString = String(format: "%+.2d:%.2d", hours, minutes)
      }
      return timeZoneString
    }
    

}
