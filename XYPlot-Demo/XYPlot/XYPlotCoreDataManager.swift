//
//  XYPlotCoreDataManager.swift
//  for XYPlot settings and line settings
//
//
//  Created by Joseph Levy on 12/11/22.
//

import Foundation
import CoreData
import SwiftUI
import RichTextEditor

extension PlotData { //use XYPlot namespace
	static public var coreDataManager = CoreDataManager() // defined below
	public class CoreDataManager : ObservableObject  {
		let persistentContainer: NSPersistentContainer
		init(inMemory: Bool = false) {
//			guard
//				let objectModelURL = Bundle.module.url(forResource: "XYPlot", withExtension: "momd"),
//				let objectModel = NSManagedObjectModel(contentsOf: objectModelURL)
//			else {
//				fatalError("Failed to retrieve PlotDataModel")
//			}
			persistentContainer = NSPersistentContainer(name: "XYPlot")//, managedObjectModel: objectModel)
			if inMemory {
				persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
			}
			persistentContainer.loadPersistentStores { (description, error) in
				if let error = error as NSError? {
					fatalError("Unable to initialize core data: \(error), \(error.userInfo)")
				}
			}
			persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
		}
		
		public var moc: NSManagedObjectContext { persistentContainer.viewContext }
		
		public func getSettings() -> [Settings] {
			let request: NSFetchRequest<Settings> = NSFetchRequest<Settings>(entityName: "Settings")
			return (try? moc.fetch(request)) ?? [Settings]()
		}
		
		public func getLines() -> [Line] {
			let request: NSFetchRequest<Line> = NSFetchRequest<Line>(entityName: "Line")
			return ( try? moc.fetch(request)) ?? [Line]()
		}
		
		public func getLineById(id: NSManagedObjectID) -> Line? {
			do {
				return try moc.existingObject(with: id) as? Line
			} catch {
				return nil
			}
		}
		
		public func getSettingsById(id: NSManagedObjectID) -> Settings? {
			do {
				return try moc.existingObject(with: id) as? Settings
			} catch {
				print("nil settings in id \(id)")
				return nil
			}
		}
		
		public func getXYPlotDataById(id: NSManagedObjectID) -> XYPlotData? {
			do {
				return try moc.existingObject(with: id) as? XYPlotData
			} catch {
				print("nil data in id \(id)")
				return nil
			}
		}
		
		public func getXYPlotData() -> [XYPlotData] {
			let request: NSFetchRequest<XYPlotData> = NSFetchRequest<XYPlotData>(entityName: "XYPlotData")
			return ( try? moc.fetch(request)) ?? [XYPlotData]()
		}
		
		public func save() {
			do { try moc.save() }
			catch {
				moc.rollback()
				print(error.localizedDescription)
			}
		}
	}
}

extension PlotSettings {
	mutating public func copyFromCoreData(settings: Settings?) {
		guard let settings else { return }
		title = decodeToAttributedString(settings.title)
		xAxis = AxisParameters(min: settings.xMin, max: settings.xMax, majorTics: Int(settings.xMajor), minorTics: Int(settings.xMinor), title: decodeToAttributedString(settings.xAxisTitle))
		yAxis = AxisParameters(min: settings.yMin, max: settings.yMax, majorTics: Int(settings.yMajor), minorTics: Int(settings.yMinor), title: decodeToAttributedString(settings.yAxisTitle))
		sAxis = AxisParameters(min: settings.sMin, max: settings.sMax, majorTics: Int(settings.sMajor), minorTics: Int(settings.sMinor), title: decodeToAttributedString(settings.sAxisTitle))
		sizeMinor = settings.sizeMinor
		sizeMajor = settings.sizeMajor
		format = settings.format ?? ""
		autoScale = settings.autoScale
		independentTics = settings.independentTics
		legendPos = CGPoint(x: settings.legendPosX,y: settings.legendPosY)
		legend = settings.showLegend
		showSecondaryAxis = settings.useSecondary
	}
	
	public func copyPlotSettingsToCoreData(settings: Settings?) {
		print("Copying settings to Coredata")
		guard let settings else { return }
		settings.title = title.data
		settings.autoScale = autoScale
		settings.format = format
		settings.independentTics = independentTics
		settings.legendPosX = legendPos.x
		settings.legendPosY = legendPos.y
		settings.showLegend = legend
		settings.sizeMajor = sizeMajor
		settings.sizeMinor = sizeMinor
		if let axis = xAxis {
			settings.xMajor = Int64(axis.majorTics)
			settings.xMinor = Int64(axis.minorTics)
			settings.xMax = axis.max
			settings.xMin = axis.min
			settings.xAxisTitle = axis.title.data
		}
		if let axis = yAxis {
			settings.yMajor = Int64(axis.majorTics)
			settings.yMinor = Int64(axis.minorTics)
			settings.yMax = axis.max
			settings.yMin = axis.min
			settings.yAxisTitle = axis.title.data
		}
		if let axis = sAxis {
			settings.sMajor = Int64(axis.majorTics)
			settings.sMinor = Int64(axis.minorTics)
			settings.sMax = axis.max
			settings.sMin = axis.min
			settings.sAxisTitle = axis.title.data
		}
		settings.useSecondary = showSecondaryAxis
		PlotData.coreDataManager.save()
	}
}

extension PlotLine {
	public func copyLineSettingsToCoreData(_ line: Line) {
		///   - lineColor: line color
		line.lineColor = Int64(lineColor.sARGB)
		///   - lineStyle: line style
		line.lineWidth = lineStyle.lineWidth
		
		line.dash = lineStyle.dash // [CGFloat]
		line.dashPhase = Float(lineStyle.dashPhase)
		line.lineCap = lineStyle.lineCap.rawValue
		line.lineJoin = lineStyle.lineJoin.rawValue
		line.miterLimit = Float(lineStyle.miterLimit)
		
		///   - pointColor: point symbol color
		line.symbolColor = Int64(pointColor.sARGB)
		///   - pointShape: point symbol from ShapeParameters
		//line.symbolShape = pointShape
		line.symbolFilled = pointShape.fill
		//line.symbolSize = pointShape.size
		line.symbolShape = pointShape.path(in: CGRect(origin: .zero, size: CGSize(width: 1, height: 1))).description
		///   - secondary: true if line should use secondary (right-side) axis
		line.useRightAxis = secondary
		///   - legend: optional String of line name;
		line.lineName = legend
		//line.symbolAngle = pointShape.angle.radians
		PlotData.coreDataManager.save()
	}
	
	mutating public func copyLineSettingsFromCoreData(_ line: Line) {
		///   - lineColor: line color
		lineColor = Color(sARGB: Int(line.lineColor))
		///   - lineStyle: line style
		lineStyle.lineWidth = line.lineWidth
		lineStyle.dash = line.dash ?? []
		lineStyle.dashPhase = CGFloat(line.dashPhase)
		lineStyle.lineCap = CGLineCap(rawValue: line.lineCap) ?? .butt
		lineStyle.lineJoin = CGLineJoin(rawValue: line.lineJoin ) ?? .miter
		lineStyle.miterLimit =  CGFloat(line.miterLimit)
		///   - pointColor: point symbol color
		pointShape.color = Color(sARGB: Int(line.symbolColor))
		///   - pointShape: point symbol from ShapeParameters
		pointShape.fill = line.symbolFilled
		//pointShape.size = line.symbolSize
		//pointShape = line.symbolShape
// 		{ rect in
//			Path(line.symbolShape ?? "")?
//				.applying(CGAffineTransform(scaleX: rect.width, y: rect.height))
//			?? Polygon(sides: 4).path(in: rect)
//		}
		///   - secondary: true if line should use secondary (right-side) axis
		secondary = line.useRightAxis
		///   - legend: optional String of line name;
		legend = line.lineName
		//pointShape.angle = Angle(radians: line.symbolAngle)
	}
}

//extension PlotData {
//	
//	mutating
//	public func copyPlotDataFromCoreData() {
//		//guard let coreDataManager else { print("No CoreDataManager"); return }
//		//guard let xyPlotData else { print("No Coredata to retrieve"); return }
//		//if settings.settings == nil { settings.settings = Settings(context: PlotData.coreDataManager.moc)}
//		settings.copyFromCoreData(settings: xyPlotData.settings)
//		let lines = xyPlotData.lines?.allObjects ?? []
//		while plotLines.count < lines.count { plotLines.append(PlotLine())}
//		for i in plotLines.indices {
//			plotLines[i].copyLineSettingsFromCoreData(lines[i] as! Line)
//		}
//	}
//	
//	mutating
//	public func copyPlotDataToCoreData() {
//		print("Copying plotData to Coredata")
//		settings.copyPlotSettingsToCoreData(settings: xyPlotData.settings)
//		var lines = xyPlotData.lines?.allObjects ?? []
//		while lines.count < plotLines.count {
//			let newLine = Line(context: PlotData.coreDataManager.moc)
//			xyPlotData.addToLines(newLine)
//			lines.append(newLine)
//		}
//		for i in plotLines.indices {
//			plotLines[i].copyLineSettingsToCoreData(lines[i] as! Line)
//		}
//		PlotData.coreDataManager.save()
//	}
//}




//
//  XYPlotData+CoreDataClass.swift
//  XYPlot
//
//  Created by Joseph Levy on 11/26/23.
//
//
/*
import Foundation
import CoreData

@objc(XYPlotData)
public class XYPlotData: NSManagedObject {
	
}
 
//  XYPlotData+CoreDataProperties.swift
//  XYPlot
//
//  Created by Joseph Levy on 11/26/23.
//
//
 
import Foundation
import CoreData
 
 
extension XYPlotData {
 
 @nonobjc public class func fetchRequest() -> NSFetchRequest<XYPlotData> {
 return NSFetchRequest<XYPlotData>(entityName: "XYPlotData")
 }
 @NSManaged public var id: String
 @NSManaged public var lines: NSSet?
 @NSManaged public var settings: Settings?
 
 }
 
 // MARK: Generated accessors for lines
 extension XYPlotData {
 
 @objc(addLinesObject:)
 @NSManaged public func addToLines(_ value: Line)
 
 @objc(removeLinesObject:)
 @NSManaged public func removeFromLines(_ value: Line)
 
 @objc(addLines:)
 @NSManaged public func addToLines(_ values: NSSet)
 
 @objc(removeLines:)
 @NSManaged public func removeFromLines(_ values: NSSet)
 
 }
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
 //
 //  Settings+CoreDataClass.swift
 //  XYPlotCoreData
 //
 //  Created by Joseph Levy on 12/11/22.
 //
 //
 
 import Foundation
 import CoreData
 
 @objc(Settings)
 public class Settings: NSManagedObject {
 
 }
 //
 //  Line+CoreDataClass.swift
 //  XYPlot CoreData
 //
 //  Created by Joseph Levy on 12/11/22.
 //
 //
 
 import Foundation
 import CoreData
 
 @objc(Line)
 public class Line: NSManagedObject {
 
 }
 //
 //  Line+CoreDataClass.swift
 //  XYPlot CoreData
 //
 //  Created by Joseph Levy on 12/11/22.
 //
 //
 
 import Foundation
 import CoreData
 
 @objc(Line)
 public class Line: NSManagedObject {
 
 }

 
 

*/
