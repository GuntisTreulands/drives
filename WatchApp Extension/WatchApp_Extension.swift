//
//  WatchApp_Extension.swift
//  WatchApp Extension
//
//  Created by GT on 02/02/2023.
//  Copyright © 2023 . All rights reserved.
//

import WidgetKit
import SwiftUI

struct ComplicationViewCircular: View {

  var body: some View {
      ZStack {
          Circle()
          .fill(Color.init(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.1))
//          Image("u0iNw")
//              .renderingMode(.template)
//                      .resizable()
//                      .aspectRatio(contentMode: .fit)
//                      .foregroundColor(.yellow)
          Text("⛩️")//"⍇⍈") //⛩️
              .font(.system(size: 20))//.font(.system(size: 26))
              .minimumScaleFactor(0.4)
              .lineLimit(2)
      }
  }
}



struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        completion(Timeline(entries: [SimpleEntry(date: Date())], policy: .never))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct WatchApp_ExtensionEntryView : View {
    
    var body: some View {
        ComplicationViewCircular()
    }
}

@main
struct WatchApp_Extension: Widget {
    let kind: String = "WatchApp_Extension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WatchApp_ExtensionEntryView().privacySensitive(false)
        }
        .configurationDisplayName("Open the Gates")
        .description("Open the Gates Widget")
    }
}

struct WatchApp_Extension_Previews: PreviewProvider {
    static var previews: some View {
        WatchApp_ExtensionEntryView()
            .privacySensitive(false)
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
