//
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
