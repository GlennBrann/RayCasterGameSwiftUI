//
//  RaycastingFour.swift
//  Game
//
//  Created by Glenn Brannelly on 2/8/23.
//

import SwiftUI

fileprivate func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}

fileprivate func dist(from: CGVector, to: CGVector) -> Double {
    sqrt(((to.dx - from.dx) * (to.dx - from.dx)) + ((to.dy - from.dy) * (to.dy - from.dy)))
}

struct RaycastingFour: View {
    
    struct Particle {
        var pos: CGVector
        var rays: [Ray] = []
        
        init(pos: CGVector) {
            self.pos = pos
            for a in stride(from: 0, to: 90, by: 2) {
                rays.append(Ray(pos: pos, angle: deg2rad(Double(a))))
            }
        }
        
        func find(walls: [Boundary], context: GraphicsContext) -> [Double?] {
            var scene = [Double?](repeating: nil, count: 90)
            for (index, ray) in rays.enumerated() {
                var closest: CGVector? = nil
                var record: Double = .infinity
                for wall in walls {
                    if let pt = ray.cast(wall) {
                        let distance = dist(from: pos, to: pt)
                        if distance < record {
                            record = distance
                            closest = pt
                        }
                    }
                }
                if let closest {
                    let path = Path { path in
                        path.move(to: CGPoint(x: pos.dx, y: pos.dy))
                        path.addLine(to: CGPoint(x: closest.dx, y: closest.dy))
                    }
                    context.stroke(path, with: .color(.pink), lineWidth: 1)
                }
                scene[index] = record
            }
            return scene
        }
        
        func show(context: GraphicsContext) {
            context.fill(
                Path(ellipseIn: CGRect(x: pos.dx - 16 / 2, y: pos.dy - 16 / 2, width: 16, height: 16)),
                with: .color(.green)
            )
            for ray in rays {
                ray.show(context: context)
            }
        }
    }
    
    struct Boundary {
        var x1: Double, y1: Double = 0.0
        var x2: Double, y2: Double = 0.0
        
        var a: CGVector
        var b: CGVector
        
        init(x1: Double, y1: Double, x2: Double, y2: Double) {
            self.x1 = x1
            self.y1 = y1
            self.x2 = x2
            self.y2 = y2
            
            a = CGVector(dx: x1, dy: y1)
            b = CGVector(dx: x2, dy: y2)
        }
        
        func show(context: GraphicsContext) {
            let path = Path { path in
                path.move(to: CGPoint(x: a.dx, y: a.dy))
                path.addLine(to: CGPoint(x: b.dx, y: b.dy))
            }
            context.stroke(path, with: .color(.white), lineWidth: 1)
        }
    }
    
    struct Ray {
        
        var pos: CGVector
        var dir: CGVector
        
        init(pos: CGVector, angle: Double) {
            self.pos = pos
            self.dir = CGVector(dx: cos(angle), dy: sin(angle))
        }
        
        func show(context: GraphicsContext) {
            let path = Path { path in
                path.move(to: CGPoint(x: pos.dx, y: pos.dy))
                path.addLine(to: CGPoint(x: pos.dx + dir.dx * 30, y: pos.dy + dir.dy * 30))
            }
            context.stroke(path, with: .color(.white), lineWidth: 1)
        }
        
        func cast(_ wall: Boundary) -> CGVector? {
            let x1 = wall.a.dx
            let y1 = wall.a.dy
            let x2 = wall.b.dx
            let y2 = wall.b.dy
            
            let x3 = pos.dx
            let y3 = pos.dy
            let x4 = pos.dx + dir.dx
            let y4 = pos.dy + dir.dy
            
            // Intersecting with a line
            
            let denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
            if denom == 0 { return nil }
            
            let t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom
            let u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom
            
            if t > 0 && t < 1 && u > 0 {
                return CGVector(dx: x1 + t * (x2 - x1), dy: y1 + t * (y2 - y1))
            } else {
                return nil
            }
        }
    }
    
    @State var walls = [
        Boundary(x1: 500, y1: 100, x2: 500, y2: 400)
//        Boundary(x1: 50, y1: 600, x2: 380, y2: 500),
//        Boundary(x1: 0, y1: 0, x2: UIScreen.main.bounds.width, y2: 0),
//        Boundary(x1: UIScreen.main.bounds.width, y1: 0, x2: UIScreen.main.bounds.width, y2: UIScreen.main.bounds.height),
//        Boundary(x1: UIScreen.main.bounds.width, y1: UIScreen.main.bounds.height, x2: 0, y2: UIScreen.main.bounds.height),
//        Boundary(x1: 0, y1: UIScreen.main.bounds.height, x2: 0, y2: 0)
    ]
    
    @State var particle = Particle(pos: CGVector(dx: 600, dy: 100))
    
//    @State var scene: [Double] = []
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                Color.black.edgesIgnoringSafeArea(.all)
            }
            .overlay(
                Canvas { context, size in
                    for wall in walls {
                        wall.show(context: context)
                    }
                    particle.show(context: context)
//                    particle.find(walls: walls, context: context)
                }
                .frame(height: proxy.size.height / 2)
                .border(Color.blue)
                .gesture(gesture)
                , alignment: .bottom
            )
            .overlay(
                Canvas { context, size in
                    let scene = particle.find(walls: walls, context: context)

                    let w = size.width / Double(scene.count)
                    for (i, s) in scene.enumerated() {
                        if let s {
                            context.fill(
                                Path(CGRect(x: CGFloat(i) * w, y: 0, width: w, height: size.height)),
                                with: .color(.init(white: s * 0.01))
                            )
                        }
                    }
                }
                .frame(height: proxy.size.height / 2)
                .border(Color.green)
                , alignment: .top
            )
        }
    }
    
    private var gesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { state in
                let fingerPos = state.location
                print(fingerPos)
                particle = Particle(pos: CGVector(dx: fingerPos.x, dy: fingerPos.y))
            }
            .onEnded { _ in
            }
    }
}

struct RaycastingFour_Previews: PreviewProvider {
    static var previews: some View {
        RaycastingFour()
    }
}
