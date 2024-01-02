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
		line.symbolFilled = pointShape.filled
		line.symbolSize = pointShape.size
		line.symbolShape = pointShape.path(CGRect(origin: .zero, size:  CGSize(width: 1.0, height: 1.0))).description
		///   - secondary: true if line should use secondary (right-side) axis
		line.useRightAxis = secondary
		///   - legend: optional String of line name;
		line.lineName = legend
		line.symbolAngle = pointShape.angle.radians
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
		pointShape.filled = line.symbolFilled
		pointShape.size = line.symbolSize
		pointShape.path = { rect in
			Path(line.symbolShape ?? "")?
				.applying(CGAffineTransform(scaleX: rect.width, y: rect.height))
			?? Polygon(sides: 4).path(in: rect)
		}
		///   - secondary: true if line should use secondary (right-side) axis
		secondary = line.useRightAxis
		///   - legend: optional String of line name;
		legend = line.lineName
		pointShape.angle = Angle(radians: line.symbolAngle)
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


func decodeToAttributedString(_ data: Data?) -> AttributedString {
	guard let data else { return AttributedString("")}
	if let output = data.attributedString {
		return output
	} else {
		print("Here is the data"); print(data)
		return AttributedString("Could not decode to AttributedString").setFont(to: .title)
	}
}

extension Data {
	var attributedString : AttributedString? {
		let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
			.documentType: NSAttributedString.DocumentType.rtfd,
			.characterEncoding: String.Encoding.utf8
		]
		let aString = try? NSAttributedString(data: self,
											  options: options,
											  documentAttributes: nil)
		return aString?.attributedString
	}
}

extension AttributedString {
	var data : Data? {
		let options: [NSAttributedString.DocumentAttributeKey: Any] = [
			.documentType: NSAttributedString.DocumentType.rtfd,
			.characterEncoding: String.Encoding.utf8
		]
		let range = NSRange(location: 0, length: characters.count)
		
		return try? nsAttributedString.data(from: range, documentAttributes: options)
	}
}
