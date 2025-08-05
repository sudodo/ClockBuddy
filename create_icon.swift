#!/usr/bin/env swift

import Cocoa
import SwiftUI

// Create a modern clock icon for ClockBuddy
struct ClockIcon: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.6, blue: 0.9), 
                        Color(red: 0.05, green: 0.3, blue: 0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Clock face
            Circle()
                .stroke(Color.white.opacity(0.9), lineWidth: 8)
                .frame(width: 180, height: 180)
            
            // Hour markers
            ForEach(0..<12) { hour in
                Rectangle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: hour % 3 == 0 ? 6 : 3, 
                           height: hour % 3 == 0 ? 20 : 12)
                    .offset(y: -75)
                    .rotationEffect(Angle(degrees: Double(hour) * 30))
            }
            
            // Clock hands (showing 10:10)
            // Hour hand
            Rectangle()
                .fill(Color.white)
                .frame(width: 8, height: 60)
                .offset(y: -30)
                .rotationEffect(Angle(degrees: -60)) // 10 o'clock
            
            // Minute hand
            Rectangle()
                .fill(Color.white)
                .frame(width: 6, height: 80)
                .offset(y: -40)
                .rotationEffect(Angle(degrees: 60)) // 10 minutes
            
            // Center dot
            Circle()
                .fill(Color.white)
                .frame(width: 16, height: 16)
            
            // Digital time overlay
            Text("10:10")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.9))
                .offset(y: 100)
        }
        .frame(width: 256, height: 256)
        .background(Color.clear)
    }
}

// Generate and save icon
let icon = ClockIcon()
    .frame(width: 1024, height: 1024)
    .background(Color.clear)

let controller = NSHostingController(rootView: icon)
let view = controller.view

view.setFrameSize(NSSize(width: 1024, height: 1024))

// Create bitmap representation
let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: 1024,
    pixelsHigh: 1024,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
)!

// Draw the view into the bitmap
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

if let context = NSGraphicsContext.current?.cgContext {
    view.layer?.render(in: context)
}

NSGraphicsContext.restoreGraphicsState()

// Create and save image
let image = NSImage(size: NSSize(width: 1024, height: 1024))
image.addRepresentation(rep)

// Save multiple sizes for icon set
let sizes = [16, 32, 64, 128, 256, 512, 1024]
for size in sizes {
    let sizedImage = NSImage(size: NSSize(width: size, height: size))
    sizedImage.lockFocus()
    image.draw(in: NSRect(x: 0, y: 0, width: size, height: size),
               from: NSRect(x: 0, y: 0, width: 1024, height: 1024),
               operation: .copy,
               fraction: 1.0)
    sizedImage.unlockFocus()
    
    if let tiffData = sizedImage.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData),
       let pngData = bitmap.representation(using: .png, properties: [:]) {
        let filename = "ClockBuddy_\(size)x\(size).png"
        try? pngData.write(to: URL(fileURLWithPath: filename))
        print("Saved \(filename)")
    }
}

print("\nIcon files created! Add them to Assets.xcassets > AppIcon in Xcode.")