//
//  PlotData.swift
//  XYPlot-Demo
//
//  Created by Joseph Levy on 12/22/23.
//

import SwiftUI

/// Axis Parameters is an x, y or secondary (s) axis extent, tics, and tile
public struct AxisParameters : Equatable, Codable  {
	public init(min: Double = 0.0, max: Double = 1.0, majorTics: Int = 10,
				minorTics: Int = 5, title: AttributedString = AttributedString(), show: Bool = true) {
		self.min = min
		self.max = max
		self.majorTics = majorTics
		self.minorTics = minorTics
		self.title = title
		self.show = show
	}
	public var show = true
	public var min = 0.0
	public var max = 1.0
	public var majorTics = 10
	public var minorTics = 5
	public var title = AttributedString()
}

/// PlotSettings is used by PlotData to define axes and axes labels
public struct PlotSettings : Equatable, Codable  {
	/// Parameters
	public var title : AttributedString
	
	public var xAxis : AxisParameters?
	public var yAxis : AxisParameters?
	public var sAxis : AxisParameters?
	
	// Computed properties for minimizing code changes when adding title to AxisParameters
	public var xTitle : AttributedString { get { xAxis?.title ?? AttributedString()}
		set { xAxis?.title = newValue.convertToNSFonts } }
	public var yTitle : AttributedString { get { yAxis?.title ?? AttributedString()}
		set { yAxis?.title = newValue.convertToNSFonts } }
	public var sTitle : AttributedString { get { sAxis?.title ?? AttributedString()}
		set { sAxis?.title = newValue.convertToNSFonts } }
	// -----------------------------------------------------------------------------------
	public var sizeMinor = 0.005
	public var sizeMajor = 0.01
	public var format = "%g" //"%.1f"//
	public var showSecondaryAxis : Bool = false
	public var autoScale : Bool = true
	public var independentTics : Bool = false
	public var legendPos = CGPoint(x: 0, y: 0)
	public var legend = true
	public var selection : Int?
	public init(title: AttributedString = .init(), xAxis: AxisParameters? = nil, yAxis: AxisParameters? = nil,
				sAxis: AxisParameters? = nil, sizeMinor: Double = 0.005, sizeMajor: Double = 0.01,
				format: String = "%g", showSecondaryAxis: Bool = false, autoScale: Bool = true,
				independentTics: Bool = false, legendPos: CGPoint = .zero, legend: Bool = true, selection: Int? = nil ,
				coreDataManager: PlotData.CoreDataManager? = nil) {
		self.title = title.convertToNSFonts
		self.xAxis = xAxis
		self.yAxis = yAxis
		self.sAxis = sAxis
		self.sizeMajor = sizeMajor
		self.sizeMinor = sizeMinor
		self.format = format
		self.showSecondaryAxis = showSecondaryAxis
		self.autoScale = autoScale
		self.independentTics = independentTics
		self.legendPos = legendPos
		self.selection = selection
	}
}

/// An element of a PlotLIne with an (x,y) point
public struct PlotPoint : Equatable, Codable {
	public init(x: Double, y: Double, label: String? = nil) {
		self.x = x
		self.y = y
		self.label = label
	}
	
	//CGPoint?
	public var x: Double
	public var y: Double
	public var label: String?  // not implemented to display
	/// Used to place points on a PlotLine
	/// - Parameters:
	///   - x: x axis point value
	///   - y: y axis point  value
	///   - label: unimplemented point label
}

public extension PlotPoint { /// Makes x: and y: designation unnecessary
	init(_ x: Double, _ y: Double, label: String? = nil) { self.x = x; self.y = y; self.label = label }
}

/// Make Codable version of StrokeStyle
public struct LineStyle: Equatable, Codable {
	var lineWidth: CGFloat /// The width of the stroked path.
	var lineCap: Int32/*CGLineCap*/ /// The endpoint style of a line.
	var lineJoin: Int32/*CGLineJoin*/ /// The join type of a line.
	var miterLimit: CGFloat /// A threshold used to determine whether to use a bevel instead of a miter at a join.
	var dash: [CGFloat] /// The lengths of painted and unpainted segments used to make a dashed line.
	var dashPhase: CGFloat /// How far into the dash pattern the line starts.
	
	public var strokeStyle: StrokeStyle {
		 StrokeStyle(lineWidth: lineWidth, lineCap: CGLineCap(rawValue: lineCap) ?? .butt,
					lineJoin: CGLineJoin(rawValue: lineJoin) ?? .miter, miterLimit: miterLimit,
					dash: dash, dashPhase: dashPhase)
	}
	
	public init(strokeStyle: StrokeStyle) {
		self.lineWidth = strokeStyle.lineWidth
		self.lineCap = strokeStyle.lineCap.rawValue
		self.miterLimit = strokeStyle.miterLimit
		self.lineJoin = strokeStyle.lineJoin.rawValue
		self.dash = strokeStyle.dash
		self.dashPhase = strokeStyle.dashPhase
	}
}

/// PlotLine array is used by PlotData to define multiple  lines
public struct PlotLine : RandomAccessCollection, MutableCollection, Equatable, Codable {
	public static func == (lhs: PlotLine, rhs: PlotLine) -> Bool {
		lhs.values == rhs.values && lhs.lineColorInt == rhs.lineColorInt &&
		lhs.lineStyle == rhs.lineStyle && lhs.secondary == rhs.secondary &&
		lhs.pointShape == rhs.pointShape && lhs.legend == rhs.legend
	}
	
	public var values: [PlotPoint]
	       var lineColorInt : Int/*Color codable substitute*/
	       var lineStyleCodable: LineStyle /*StrokeStyle codable substitute*/
	public var pointShape: ShapeParameters
	public var secondary: Bool
	public var legend: String?
	public var pointColor: Color { pointShape.color } // added to ShapeParameters
	public var lineColor: Color {
		get { Color(sARGB: lineColorInt)}
		set { lineColorInt = newValue.sARGB }
	}
	public var lineStyle: StrokeStyle {
		get { lineStyleCodable.strokeStyle }
		set { lineStyleCodable = LineStyle(strokeStyle: newValue)}
	}
	/// - Parameters:
	///   - values: PlotPoint array of line
	///   - lineColorInt: line color sARGB
	///   - lineStyle: line style
	///   - pointColor: point symbol color
	///   - pointShape: point symbol from ShapeParameters
	///   - secondary: true if line should use secondary (right-side) axis
	///   - legend: optional String of line name;
	///
	public init(values: [PlotPoint] = [],
				lineColor: Color = .black,
				lineStyle: StrokeStyle = StrokeStyle(lineWidth: 2),
				pointColor: Color = .clear,
				pointShape: ShapeParameters = .init(),
				secondary: Bool = false,
				legend: String? = nil,
				coreDataManager: PlotData.CoreDataManager? = nil) {
		self.values = values
		self.lineColorInt = lineColor.sARGB
		self.lineStyleCodable = LineStyle(strokeStyle: lineStyle)
		self.pointShape = pointShape
		self.secondary = secondary
		self.legend = legend
		self.pointShape.color = pointColor
		
	}
	
	/// add array append and clear -- other Array methods can be added similarly
	public mutating func append(_ plotPoint: PlotPoint) { values.append(plotPoint)}
	public mutating func clear() { values = [] }
	
	/// Collection protocols make it work with higher order functions ( like map)
	public var startIndex: Int { values.startIndex }
	public var endIndex: Int { values.endIndex}
	public subscript(_ position: Int) -> PlotPoint {
		get { values[position] }
		set(newValue) { values[position] = newValue }
	}
}

/// PlotData is the info needed for XYPlot to display a plot
/// - Parameters:
///   - plotLines: PlotLine array of the lines to plot
///   - plotSettings: scaling, tics, and titles of plot
///   - plotName: String that is unique to this data set
///   Methods:
///   - saveToUserDefaults(): Saves to UserDefaults with key in plotName
///   - readFromUserDefaults(_ plotName: String)  // Retrieves from key plotname and returns PlotData with that plotName set
///   - scaleAxes(): Adjusts settings to make plot fix in axes if autoscale is true
///   - axesScale(): Adjust setting to make plot fit in axes (regardlless of autoScale)
///
public struct PlotData : Equatable, Codable {
	
	public var plotLines: [PlotLine]
	public var settings : PlotSettings
	public var plotName: String?
	public init(plotLines: [PlotLine] = .init(), settings: PlotSettings, plotName: String? = nil) {
		self.plotLines = plotLines
		self.settings = settings
		if let plotName {
			self.plotName = plotName
		} else { print("plotName is nil")}
	}
	
	func saveToUserDefaults() {
		guard let plotName else { return }
		let encoder = JSONEncoder()
		if let data = try? encoder.encode(self) {
			print("Saving to UserDefaults: \(plotName)")
			UserDefaults.standard.set(data, forKey: plotName)
		} else { print("Could not save to UserDefaults")}
	}
	
	func readFromUserDefaults(_ plotName: String) -> PlotData {
		let decoder = JSONDecoder()
		if let data = UserDefaults.standard.data(forKey: plotName),
		   var plotData = try? decoder.decode(PlotData.self, from: data) {
			print("Read from UserDefaults: \(plotName)")
			plotData.plotName = plotName
			return plotData
		}
		return self
	}

	static public func == (lhs: PlotData, rhs: PlotData) -> Bool {
		var equal = rhs.plotLines.count == lhs.plotLines.count && lhs.settings == rhs.settings
		if equal {
			for i in rhs.plotLines.indices {
				equal = lhs.plotLines[i] == rhs.plotLines[i]
				if !equal { break }
			}
		}
		return equal
	}
	
	subscript(_ position: Int) -> PlotLine {
		get { plotLines[position] }
		set(newValue) { plotLines[position] = newValue }
	}
	
	var hasPrimaryLines : Bool { plotLines.reduce(false, { $0 || !$1.secondary })}
	var hasSecondaryLines : Bool { plotLines.reduce(false, { $0 || $1.secondary})}
	var noSecondary : Bool { !hasPrimaryLines || !hasSecondaryLines || !settings.showSecondaryAxis}
}
