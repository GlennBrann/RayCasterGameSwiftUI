//
//  RaycasterGame.swift
//  Game
//
//  Created by Glenn Brannelly on 2/18/23.
//

import SwiftUI

extension RaycasterGame {
    struct Player {
        var x: Double = 2
        var y: Double = 2
        var fov: Double = 60
        var rot: Double = 90
        var moveSpeed: Double = 0.15
        var rotSpeed:Double = 8
    }
}

fileprivate var map: [[Int]] {
    [
        [1,1,1,1,1,1,1,1,1,1],
        [1,0,0,0,0,0,1,0,0,1],
        [1,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,1],
        [1,0,0,1,1,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,1,0,0,1],
        [1,0,0,0,0,0,1,0,0,1],
        [1,0,0,0,0,0,0,0,0,1],
        [1,1,1,1,1,1,1,1,1,1]
    ]
}

struct RaycasterGame: View {
    
    let mapWidth: Int = 10
    let mapHeight: Int = 10
    let cellSize: Double = 16
    
    struct Ray {
        var x: Double
        var y: Double
    }
    
    @StateObject var game = GameLoop()
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                Canvas { context, size in
                    var rayAngle = game.player.rot - (game.player.fov / 2)
                    for i in 0..<Int(size.width) {
                        var ray = Ray(x: game.player.x, y: game.player.y)
                        
                        let rayCos = cos(degreesToRadians(rayAngle)) / 64
                        let raySin = sin(degreesToRadians(rayAngle)) / 64
                        
                        var wall: Int = 0
                        while wall == 0 {
                            ray.x += rayCos
                            ray.y += raySin
                            wall = map[Int(floor(ray.y))][Int(floor(ray.x))]
                        }
                        
                        var distance = sqrt(pow(game.player.x - ray.x, 2) + pow(game.player.y - ray.y, 2))
                        
                        distance = distance * cos(degreesToRadians(abs(rayAngle - game.player.rot)))
                        
                        let wallHeight = floor((size.height / 2) / distance)
                        
                        //drawLine(context, x1: Double(i), y1: 0, x2: Double(i), y2: (size.height / 2) - wallHeight, color: Color("darkGray"))
                        
                        drawLine(context, x1: Double(i), y1: (size.height / 2) - wallHeight, x2: Double(i), y2: (size.height / 2) + wallHeight, color: .green)
                        
                        context.draw(.init(Image("wall").resizable()), in: CGRect(x: Double(i) * wallHeight, y: (size.height / 2) - wallHeight, width: 120, height: 120))
                        
                        
                        //drawLine(context, x1: Double(i), y1: (size.height / 2) + wallHeight, x2: Double(i), y2: size.height, color: .gray)
                        
                        rayAngle += game.player.fov / size.width
                    }
                }
                .frame(width: proxy.size.width - 32, height: (proxy.size.width / (4/3)) - 32)
                .border(Color.blue, width: 1)
//                .gesture(
//                    DragGesture(minimumDistance: 0)
//                        .onChanged { state in
//                            print(state.location)
//                        }
//                        .onEnded { _ in }
//                )
                
                
                HudView
                    .frame(width: proxy.size.width)
                
                GamePad
                    .padding(.bottom, 8)
            }
            .onAppear(perform: game.startGameLoop)
        }
    }
    
    func degreesToRadians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }
    
    @ViewBuilder
    var HudView: some View {
        ZStack {
            Canvas { context, size in
                // Draw background
                drawRect(context, x1: 0, y1: 0, width: Double(mapWidth) * cellSize, height: Double(mapHeight) * cellSize, color: .gray, fill: true)
                
                // Draw walls
                for y in 0..<mapHeight {
                    for x in 0..<mapWidth {
                        if map[y][x] == 1 {
                            drawRect(context, x1: Double(x) * cellSize, y1: Double(y) * cellSize, width: cellSize, height: cellSize, color: .green, fill: true)
                        }
                        
                        // Draw vertical lines
                        drawLine(
                            context,
                            x1: (Double(x) * cellSize) + 0.5,
                            y1: (Double(y) * cellSize) + 0.5,
                            x2: (Double(x) * cellSize + 0.5),
                            y2: (Double(y) * cellSize) + cellSize + 0.5,
                            color: .black
                        )
                    }
                    // Draw horizontal lines
                    drawLine(
                        context,
                        x1:  0.5,
                        y1: (Double(y) * cellSize) + 0.5,
                        x2: (Double(mapHeight) * cellSize) + 0.5,
                        y2: (Double(y) * cellSize) + 0.5,
                        color: .black
                    )
                }
                
                // Draw player
                drawCircle(context, x1: game.player.x * cellSize, y1: game.player.y * cellSize, radius: 5, color: Color.yellow)
                
                
                for i in (Int(game.player.rot) - Int(game.player.fov / 2))..<(Int(game.player.rot) + Int(game.player.fov / 2)) {
                    var ray = Ray(x: game.player.x, y: game.player.y)
                    
                    let rayCos = cos(degreesToRadians(Double(i))) / 64
                    let raySin = sin(degreesToRadians(Double(i))) / 64
                    
                    var wall = 0
                    while wall == 0 {
                        ray.x += rayCos
                        ray.y += raySin
                        
                        wall = map[Int(floor(ray.y))][Int(floor(ray.x))]
                    }
                    
                    drawLine(context, x1: game.player.x * cellSize, y1: game.player.y * cellSize, x2: ray.x * cellSize, y2: ray.y * cellSize, color: .pink)
                }
                
            }
//            .frame(width: 320, height: 240)
//            .border(Color.green, width: 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    @ViewBuilder
    var GamePad: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    ButtonPad(onKeyDown: { game.keyPressed = .up }, onKeyUp: { game.keyPressed = nil })
                    Spacer()
                }
                HStack {
                    ButtonPad(onKeyDown: { game.keyPressed = .left }, onKeyUp: { game.keyPressed = nil })
                    Spacer()
                    ButtonPad(onKeyDown: { game.keyPressed = .right }, onKeyUp: { game.keyPressed = nil })
                }
                HStack {
                    Spacer()
                    ButtonPad(onKeyDown: { game.keyPressed = .down }, onKeyUp: { game.keyPressed = nil })
                    Spacer()
                }
            }
            .frame(width: 200, height: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
    
    struct ButtonPad: View {
        let onKeyDown: () -> Void
        let onKeyUp: () -> Void
        
        var body: some View {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .frame(width: 64, height: 64)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            onKeyDown()
                        }
                        .onEnded { _ in
                            onKeyUp()
                        }
                )
        }
    }
}

enum Keys {
    case up
    case down
    case left
    case right
}

class GameLoop: ObservableObject {
    
    @Published var player = RaycasterGame.Player()
    @Published var keyPressed: Keys? = nil
    
    private var displayLink: CADisplayLink?
    private var startTime = CACurrentMediaTime()
    
    func startGameLoop() {
        stopDisplayLink()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.preferredFramesPerSecond = 60
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
    }
    
    @objc
    private func update() {
        guard let keyPressed else { return }
        
        switch keyPressed {
        case .up :
            let playerCos = cos(degreesToRadians(player.rot)) * player.moveSpeed
            let playerSin = sin(degreesToRadians(player.rot)) * player.moveSpeed
            let newX = player.x + playerCos
            let newY = player.y + playerSin
            
            if map[Int(floor(newY))][Int(floor(newX))] == 0 {
                player.x = newX
                player.y = newY
            }
        case .down:
            let playerCos = cos(degreesToRadians(player.rot)) * player.moveSpeed
            let playerSin = sin(degreesToRadians(player.rot)) * player.moveSpeed
            let newX = player.x - playerCos
            let newY = player.y - playerSin
            
            if map[Int(floor(newY))][Int(floor(newX))] == 0 {
                player.x = newX
                player.y = newY
            }
        case .left:
            player.rot -= player.rotSpeed
        case .right:
            player.rot += player.rotSpeed
        }
    }
    
    func degreesToRadians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }
    
    private func move() {
//        var player = player
//        let moveStep = Double(player.speed) * player.moveSpeed
//
//        player.rot += Double(player.dir) * player.rotSpeed
//
//        print(player.rot)
//
//        let newX = Double(player.x) + cos(player.rot) * moveStep
//        let newY = Double(player.y) + sin(player.rot) * moveStep
//
//        player.x = newX
//        player.y = newY
//
//        self.player = player
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
}

struct RaycasterGame_Previews: PreviewProvider {
    static var previews: some View {
        RaycasterGame()
    }
}

// MARK: - Drawing Extensions

extension RaycasterGame {
    /// Draws a line to a GraphicsContext at specific coordinates and color
    /// - Parameters:
    ///    - context: The graphics context we are drawing to.
    ///    - x1: The x coordinate where the line starts.
    ///    - y1: The y coordinate where the line starts.
    ///    - x2: The x coordinate where the line ends.
    ///    - y2: The y coordinate where the line ends.
    ///    - color: The color of the line drawn.
    func drawLine(
        _ context: GraphicsContext,
        x1: Double,
        y1: Double,
        x2: Double,
        y2: Double,
        color: Color = .white
    ) {
        let path = Path { path in
            path.move(to: CGPoint(x: x1, y: y1))
            path.addLine(to: CGPoint(x: x2, y: y2))
        }
        context.stroke(path, with: .color(color), lineWidth: 1)
    }
    
    /// Draws a rectangle to a GraphicsContext at specific coordinates and color and fill
    /// - Parameters:
    ///    - context: The graphics context we are drawing to.
    ///    - x1: The x coordinate where the rectangle starts.
    ///    - y1: The y coordinate where the rectangle starts.
    ///    - width: The width of the rectangle.
    ///    - height: The height of the rectangle.
    ///    - color: The color of the rectangle drawn.
    ///    - fill: A boolean for filling the rectangle or not.
    func drawRect(
        _ context: GraphicsContext,
        x1: Double,
        y1: Double,
        width: Double,
        height: Double,
        color: Color = .white,
        fill: Bool = false
    ) {
        if fill {
            context.fill(
                Path(CGRect(x: x1, y: y1, width: width, height: height)),
                with: .color(color)
            )
        } else {
            context.stroke(
                Path(CGRect(x: x1, y: y1, width: width, height: height)),
                with: .color(color)
            )
        }
    }
    
    /// Draws a circle to a GraphicsContext at specific coordinates and color and fill
    /// - Parameters:
    ///    - context: The graphics context we are drawing to.
    ///    - x1: The x coordinate where the circle starts.
    ///    - y1: The y coordinate where the circle starts.
    ///    - radius: The radius of the circle
    ///    - color: The color of the circle drawn.
    func drawCircle(
        _ context: GraphicsContext,
        x1: Double,
        y1: Double,
        radius: Double,
        color: Color = .white
    ) {
        let path = Path { path in
            path.addArc(
                center: CGPoint(x: x1, y: y1),
                radius: radius,
                startAngle: Angle(radians: 0), endAngle: Angle(radians: 2 * Double.pi),
                clockwise: true
            )
        }
        context.fill(path, with: .color(color))
    }
    
//    func drawTexture(
//        _ context: GraphicsContext,
//
//    ) {
//
//    }
}
