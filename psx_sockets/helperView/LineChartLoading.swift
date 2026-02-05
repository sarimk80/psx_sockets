//
//  LineChartLoading.swift
//  psx_sockets
//
//  Created by sarim khan on 04/02/2026.
//

import SwiftUI

// Line chart loading
struct LineChartLoading: View {
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.15))

            // Fake grid lines
            VStack(spacing: 20) {
                ForEach(0..<4) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 1)
                }
            }
            .padding(.horizontal, 16)

            // Fake line path
            LineShape()
                .stroke(
                    Color.gray.opacity(0.35),
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .padding(24)
        }
        .frame(maxWidth: .infinity, minHeight: 350)
    }
}

struct LineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let points: [CGPoint] = [
            CGPoint(x: rect.minX, y: rect.midY),
            CGPoint(x: rect.width * 0.2, y: rect.height * 0.4),
            CGPoint(x: rect.width * 0.4, y: rect.height * 0.6),
            CGPoint(x: rect.width * 0.6, y: rect.height * 0.3),
            CGPoint(x: rect.width * 0.8, y: rect.height * 0.5),
            CGPoint(x: rect.maxX, y: rect.height * 0.35)
        ]

        path.move(to: points.first!)

        for point in points.dropFirst() {
            path.addLine(to: point)
        }

        return path
    }
}



// Donut chart loading

struct ChartLoading: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.25), lineWidth: 20)
                .frame(width: 180, height: 180)

            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.5))
                    .frame(width: 80, height: 10)

                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.5))
                    .frame(width: 60, height: 10)
            }
        }
        .frame(maxWidth: .infinity,maxHeight: 350)

    }
}

#Preview {
    LineChartLoading()
}
