//
//  RaycastingOne.swift
//  Game
//
//  Created by Glenn Brannelly on 2/7/23.
//

import SwiftUI

struct RaycastingOne: View {
    
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
        
        init(x: Double, y: Double) {
            self.pos = CGVector(dx: x, dy: y)
            self.dir = CGVector(dx: 1, dy: 0)
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
            
            let denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
            if denom == 0 { return nil }
            
            let t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom
            let u = ((x1 - x3) * (y1 - y2) - (y1 - y3) * (x1 - x2)) / denom
            
            if t > 0 && t < 1 && u > 0 {
                return CGVector(dx: x1 + t * (x2 - x1), dy: y1 + t * (y2 - y1))
            } else {
                return nil
            }
        }
        
        mutating func setDir(x: Double, y: Double) {
            dir.dx = (x - pos.dx) * 30
            dir.dy = (y - pos.dy) * 30
            
            // Normalizing
            let mag = sqrt(((dir.dx - x) * (dir.dx - x)) + ((dir.dy - y) * (dir.dy - y)))
            if mag == 0 { return }
            let newDx = dir.dx * (1 / mag)
            let newDy = dir.dy * (1 / mag)
            
            dir.dx = newDx
            dir.dy = newDy
        }
    }
    
    let wall = Boundary(x1: 200, y1: 200, x2: 250, y2: 500)
    @State var ray = Ray(x: 150, y: 350)
            
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            Canvas { context, size in
                wall.show(context: context)
                ray.show(context: context)
                
                if let pt = ray.cast(wall) {
                    context.fill(Path(
                        ellipseIn: CGRect(x: pt.dx - 16 / 2, y: pt.dy - 16 / 2, width: 16, height: 16)),
                                 with: .color(.green))
                }
                
//                print(ray.cast(wall))
//                context.fill(
//                    Path(CGRect(x: x * scale, y: y * scale, width: scale, height: scale)),
//                    with: .color(.red)
//                )
                
//                context.fill(
//                    Path(
//                        CGRect(
//                            x: game.player.x,
//                            y: game.player.y,
//                            width: 16,
//                            height: 32
//                        )
//                    ),
//                    with: .color(.blue)
//                )
                
            }
            .border(Color.blue)
            
            VStack {
                Spacer()
                let isIntersecting = ray.cast(wall) != nil
                Text("Intersecting? " + (isIntersecting ? "true" : "false"))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(isIntersecting ? .green : .red)
            }
            .padding(.bottom, 64)
        }
        .gesture(gesture)
//        .onAppear(perform: game.startGameLoop)
    }
    
    private var gesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { state in
//                print(state.location)
                ray.setDir(x: state.location.x, y: state.location.y)
            }
            .onEnded { _ in
//                controller.movement = nil
            }
    }
}

struct RaycastingOne_Previews: PreviewProvider {
    static var previews: some View {
        RaycastingOne()
    }
}
