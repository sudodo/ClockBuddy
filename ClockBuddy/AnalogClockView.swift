import SwiftUI

struct AnalogClockView: View {
    let date: Date
    var showSecondsHand: Bool = true
    
    private var hourAngle: Angle {
        let hours = Calendar.current.component(.hour, from: date) % 12
        let minutes = Calendar.current.component(.minute, from: date)
        let hoursInDegrees = Double(hours) * 30.0
        let minutesInDegrees = Double(minutes) * 0.5
        return Angle(degrees: hoursInDegrees + minutesInDegrees - 90)
    }
    
    private var minuteAngle: Angle {
        let minutes = Calendar.current.component(.minute, from: date)
        let seconds = Calendar.current.component(.second, from: date)
        let minutesInDegrees = Double(minutes) * 6.0
        let secondsInDegrees = Double(seconds) * 0.1
        return Angle(degrees: minutesInDegrees + secondsInDegrees - 90)
    }
    
    private var secondAngle: Angle {
        let seconds = Calendar.current.component(.second, from: date)
        return Angle(degrees: Double(seconds) * 6.0 - 90)
    }
    
    var body: some View {
        ZStack {
            // Clock face
            Circle()
                .stroke(lineWidth: 4)
                .frame(width: 250, height: 250)
            
            // Hour markers
            ForEach(0..<12) { hour in
                VStack {
                    Rectangle()
                        .fill()
                        .frame(width: 2, height: hour % 3 == 0 ? 15 : 10)
                    Spacer()
                }
                .frame(height: 125)
                .rotationEffect(Angle(degrees: Double(hour) * 30))
            }
            
            // Hour hand
            Rectangle()
                .fill()
                .frame(width: 6, height: 80)
                .offset(y: -40)
                .rotationEffect(hourAngle)
            
            // Minute hand
            Rectangle()
                .fill()
                .frame(width: 4, height: 110)
                .offset(y: -55)
                .rotationEffect(minuteAngle)
            
            // Second hand (only if enabled)
            if showSecondsHand {
                Rectangle()
                    .fill(.red)
                    .frame(width: 2, height: 120)
                    .offset(y: -60)
                    .rotationEffect(secondAngle)
            }
            
            // Center dot
            Circle()
                .fill()
                .frame(width: 12, height: 12)
            
            // Date display
            VStack {
                Spacer()
                    .frame(height: 180)
                
                Text(date, format: .dateTime.month(.abbreviated).day())
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.black.opacity(0.2))
                    )
            }
        }
        .frame(width: 300, height: 300)
    }
}