//
//  Settings+CoreDataProperties.swift
//  XYPlotCoreData
//
//  Created by Joseph Levy on 12/11/22.
//
//

import Foundation
import CoreData
import UIKit

//@objc(NSAttributedStringTransformer)
//class NSAttributedStringTransformer: NSSecureUnarchiveFromDataTransformer {
//    override class var allowedTopLevelClasses: [AnyClass] {
//        return super.allowedTopLevelClasses + [NSAttributedString.self]
//    }
//}

extension Settings {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
        return NSFetchRequest<Settings>(entityName: "Settings")
    }
    
    @NSManaged public var independentTics: Bool
    @NSManaged public var legendPosX: Double
    @NSManaged public var legendPosY: Double
    @NSManaged public var sAxisTitle: Data?
    @NSManaged public var sMajor: Int64
    @NSManaged public var sMinor: Int64
    @NSManaged public var title: Data?
    @NSManaged public var useSecondary: Bool
    @NSManaged public var xAxisTitle: Data?
    @NSManaged public var xMajor: Int64
    @NSManaged public var xMax: Double
    @NSManaged public var xMin: Double
    @NSManaged public var xMinor: Int64
    @NSManaged public var yAxisTitle: Data?
    @NSManaged public var yMajor: Int64
    @NSManaged public var yMax: Double
    @NSManaged public var yMin: Double
    @NSManaged public var yMinor: Int64
    @NSManaged public var sMax: Double
    @NSManaged public var sMin: Double
    @NSManaged public var sizeMajor: Double
    @NSManaged public var sizeMinor: Double
    @NSManaged public var autoScale: Bool
    @NSManaged public var showLegend: Bool
    @NSManaged public var format: String?
    @NSManaged public var plotData: XYPlotData
}

extension Settings : Identifiable {
    
}
//import Combine
//import SwiftUI
// Axis Parameters is an x, y or secondary (s) axis extent, tics, and tile
//public struct AxisParameters : Equatable  {
//    public init(min: Double = 0.0, max: Double = 1.0, majorTics: Int = 10, minorTics: Int = 5, title: AttributedString = AttributedString(), show: Bool = true) {
//        self.min = min
//        self.max = max
//        self.majorTics = majorTics
//        self.minorTics = minorTics
//        self.title = title
//        self.show = show
//    }
//    public var show = true
//    public var min = 0.0
//    public var max = 1.0
//    public var majorTics = 10
//    public var minorTics = 5
//    public var title = AttributedString()
//}
//
///// PlotSettings is used by PlotData to define axes and axes labels
//public struct PlotSettings: Equatable { //, ObservableObject  {
//    
//    /// Parameters
//    ///
//    //public var plotData: PlotData? // Owner
//    //public var settings: Settings? // Entity
//    //public var settingsID: NSManagedObjectID? { settings?.objectID }
//    //var store = Set<AnyCancellable>()
//    public var title : AttributedString
//    
//    public var xAxis : AxisParameters?
//    public var yAxis : AxisParameters?
//    public var sAxis : AxisParameters?
//    
//    // Computed properties for minimizing code changes when adding title to AxisParameters
//    public var xTitle : AttributedString { get { xAxis?.title ?? AttributedString()}
//        set { xAxis?.title = newValue.convertToNSFonts } }
//    public var yTitle : AttributedString { get { yAxis?.title ?? AttributedString()}
//        set { yAxis?.title = newValue.convertToNSFonts } }
//    public var sTitle : AttributedString { get { sAxis?.title ?? AttributedString()}
//        set { sAxis?.title = newValue.convertToNSFonts } }
//    // -----------------------------------------------------------------------------------
//    public var sizeMinor = 0.005
//    public var sizeMajor = 0.01
//	public var format = "%g" //"%.1f"//
//    public var showSecondaryAxis : Bool = false
//    public var autoScale : Bool = true
//    public var independentTics : Bool = false
//	public var legendPos = CGPoint(x: 0, y: 0)
//    public var legend = true
//    public var selection : Int?
//    
//    public init(title: AttributedString = .init(), xAxis: AxisParameters? = nil, yAxis: AxisParameters? = nil,
//                sAxis: AxisParameters? = nil, sizeMinor: Double = 0.005, sizeMajor: Double = 0.01,
//                format: String = "%g", showSecondaryAxis: Bool = false, autoScale: Bool = true,
//                independentTics: Bool = false, legendPos: CGPoint = .zero, legend: Bool = true, selection: Int? = nil , coreDataManager: PlotData.CoreDataManager? = nil) {
//        self.title = title.convertToNSFonts
//        self.xAxis = xAxis
//        self.yAxis = yAxis
//        self.sAxis = sAxis
//        self.sizeMajor = sizeMajor
//        self.sizeMinor = sizeMinor
//        self.format = format
//        self.showSecondaryAxis = showSecondaryAxis
//        self.autoScale = autoScale
//        self.independentTics = independentTics
//        self.legendPos = legendPos
//        self.selection = selection
//    }
//    
//    public init(settings: Settings) {
//        self.settings = settings
//        title = decodeToAttributedString(settings.title)
//        self.independentTics = settings.independentTics
//        legendPos = CGPoint(x: settings.legendPosX, y: settings.legendPosY)
//        xAxis = AxisParameters(min: settings.xMin, max: settings.xMax, majorTics: Int(settings.xMajor), minorTics: Int(settings.xMinor), title: decodeToAttributedString(settings.xAxisTitle))
//        yAxis = AxisParameters(min: settings.yMin, max: settings.yMax, majorTics: Int(settings.yMajor), minorTics: Int(settings.yMinor), title: decodeToAttributedString(settings.yAxisTitle))
//        sAxis = AxisParameters(min: settings.sMin, max: settings.sMax, majorTics: Int(settings.sMajor), minorTics: Int(settings.sMinor), title: decodeToAttributedString(settings.sAxisTitle))
//        showSecondaryAxis = settings.useSecondary
//        sizeMajor = settings.sizeMajor
//        sizeMinor = settings.sizeMinor
//        autoScale = settings.autoScale
//        format = settings.format ?? "g"
//        legend = settings.showLegend
//        setPublisherActions(settings)
//    }
//    
//    func onChange<Value>(of: Published<Value>.Publisher, debounce: TimeInterval = 0.0, action: @escaping (Published<Value>.Publisher.Output) -> Void  ) where Value: Equatable {
//        of
//            .debounce(for: .seconds(debounce), scheduler: RunLoop.main)
//            .removeDuplicates()
//            .sink { 
//                action($0)
//                print("Trying to save ...", terminator: " ")
//				PlotData.coreDataManager.save() }
//            .store(in: &store)
//    }
    
//    func setPublisherActions(_ settings: Settings?) {
//        guard let settings else { 
//            print("settings is nil, no publisher actions setup");return }
//        print("Setting up publishers")
//        onChange(of: $title) { settings.title = $0.data }
//        onChange(of: $xAxis) {
//            settings.xMin = $0?.min ?? 0.0;  settings.xMax = $0?.max ?? 1.0
//            settings.xMajor = Int64($0?.majorTics ?? 5); settings.xMinor = Int64($0?.minorTics ?? 5)
//            settings.xAxisTitle = $0?.title.data
//        }
//        onChange(of: $yAxis) {
//            settings.yMin = $0?.min ?? 0.0;  settings.yMax = $0?.max ?? 1.0
//            settings.yMajor = Int64($0?.majorTics ?? 5); settings.yMinor = Int64($0?.minorTics ?? 5)
//            settings.yAxisTitle = $0?.title.data
//        }
//        onChange(of: $sAxis) {
//            settings.sMin = $0?.min ?? 0.0; settings.sMax = $0?.max ?? 1.0
//            settings.sMajor = Int64($0?.majorTics ?? 5); settings.sMinor = Int64($0?.minorTics ?? 5)
//            settings.sAxisTitle = $0?.title.data
//        }
//        onChange(of: $showSecondaryAxis) { settings.useSecondary = $0 }
//        onChange(of: $sizeMajor) { settings.sizeMajor = $0 }
//        onChange(of: $sizeMinor) { settings.sizeMinor = $0 }
//        onChange(of: $autoScale) { settings.autoScale = $0}
//        onChange(of: $format) { settings.format = $0 }
//        onChange(of: $legend) { settings.showLegend = $0 }
//    }
//}



