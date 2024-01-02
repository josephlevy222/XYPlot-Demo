//
//  ContentView.swift
//  XYPlot-Demo
//
//  Created by Joseph Levy on 11/23/23.
//

import SwiftUI

struct ContentView: View {
	@State var plotData = testPlotLines.readFromUserDefaults("Graph 1")

	var body: some View {
		VStack {
			XYPlot(data: $plotData )
				.padding()
		}
	}
}
      

#Preview {
	ContentView()
}
