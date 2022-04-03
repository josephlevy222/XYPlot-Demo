# XYPlot-Example
XYPlot is a SwiftUI View to plot multiple lines and point on an chart for numerical data. 
This example shows how the view is setup and changed under program control.

XYPlot takes a binding to PlotData.  
PlotData is a struct which contains plotLines: [PlotLine] and settings: PlotSettings

A PlotLine is a [PlotPoint], color, useSecondary flag and line and point definitions.
Each PlotPoint has an x: Double and y: Double value and a legend: String
