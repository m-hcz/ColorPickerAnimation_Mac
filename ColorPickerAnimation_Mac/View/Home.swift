//
//  Home.swift
//  ColorPickerAnimation_Mac
//
//  Created by M H on 20/12/2022.
//

// https://www.youtube.com/watch?v=8sgjvgBasYM

import SwiftUI

struct Home: View {
	
	@State var currentItem: ColorValue?
	@State var expandCard: Bool = false
	@State var moveCardDown: Bool = false
	@State var animateContent: Bool = false
	
	@Namespace var animation
	
    var body: some View {
		GeometryReader { proxy in
			let size = proxy.size
			let safeArea = proxy.safeAreaInsets
			
			ScrollView(.vertical, showsIndicators: false) {
				VStack(spacing: 8) {
					ForEach(colors) { color in
						CardView(item: color, rectSize: size)
					}
				}
				.padding(.horizontal, 10)
				.padding(.vertical, 15)
			}
			.safeAreaInset(edge: .top) {
				Rectangle()
					.fill(.ultraThinMaterial)
					.frame(height: safeArea.top + 5)
					.overlay {
						Text("Color Picker")
							.fontWeight(.semibold)
							.foregroundColor(.white)
							.opacity(0.8)
					}
					.overlay(alignment: .trailing) {
						Text("V1.0.2")
							.font(.caption)
							.foregroundColor(.white)
							.padding(.trailing, 10)
					}
			}
			.ignoresSafeArea(.container, edges: .all)
			.overlay {
				if let currentItem, expandCard {
					DetailView(item: currentItem, rectSize: size)
						.transition(.asymmetric(insertion: .identity, removal: .offset(y: 10)))
				}
			}
		}
		.frame(width: 380, height: 500)
    }
	
	@ViewBuilder
	func DetailView(item: ColorValue, rectSize: CGSize) -> some View {
		ColorView(item: item, rectSize: rectSize)
			.ignoresSafeArea()
			.overlay(alignment: .top) {
				ColorDetals(item: item, rectSize: rectSize)
			}
			.overlay(content: {
				DetailViewContent(item: item)
			})
	}
	@ViewBuilder
	func DetailViewContent(item: ColorValue) -> some View {
		VStack(spacing: 0) {
			Rectangle()
				.fill(.white)
				.frame(height: 1)
				.scaleEffect(x: animateContent ? 1 : 0.001, anchor: .leading)
				.padding(.top, 60)
			
			VStack(spacing: 30) {
				let rgbColor = NSColor(item.color).rgb
				
				CustomProgressView(value: rgbColor.red, label: "Red")
				CustomProgressView(value: rgbColor.green, label: "Green")
				CustomProgressView(value: rgbColor.blue, label: "Blue")
			}
			.padding(15)
			.background {
				RoundedRectangle(cornerRadius: 15, style: .continuous)
					.fill(.ultraThinMaterial)
					.environment(\.colorScheme, .dark)
			}
			.opacity(animateContent ? 1 : 0)
			.offset(y: animateContent ? 0 : 100)
			.animation(.easeInOut(duration: 0.5).delay(animateContent ? 0.2 : 0), value: animateContent)
			.padding(.top, 30)
			.padding(.horizontal, 20)
			.frame(maxHeight: .infinity, alignment: .top)
			
			HStack(spacing: 15) {
				Text("Copy Code")
					.foregroundColor(.black)
					.fontWeight(.semibold)
					.padding(.vertical, 8)
					.padding(.horizontal, 30)
					.background {
						Capsule()
							.fill(.white)
					}
					.onTapGesture {
						NSPasteboard.general.setString("#\(item.colorCode)", forType: .string)
					}
				
				Text("Dismiss")
					.foregroundColor(.black)
					.fontWeight(.semibold)
					.padding(.vertical, 8)
					.padding(.horizontal, 30)
					.background {
						Capsule()
							.fill(.white)
					}
					.onTapGesture {
						withAnimation(.easeInOut(duration: 0.2)) {
							animateContent = false
						}
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
							withAnimation(.easeInOut(duration: 0.4)) {
								expandCard = false
								moveCardDown = false
							}
						}
					}
			}
			.padding(.bottom, 40)
			.opacity(animateContent ? 1 : 0)
			.offset(y: animateContent ? 0 : 150)
			.animation(.easeInOut(duration: 0.5).delay(animateContent ? 0.3 : 0), value: animateContent)
		}
		.padding(.horizontal, 15)
		.frame(maxHeight: .infinity, alignment: .top)
		.onAppear {
			withAnimation(.easeInOut.delay(0.2)) {
				animateContent = true
			}
		}
	}
	@ViewBuilder
	func CardView(item: ColorValue, rectSize: CGSize) -> some View {
		let tappedCard = item.id == currentItem?.id && moveCardDown
		
		if !(item.id == currentItem?.id && expandCard) {
			ColorView(item: item, rectSize: rectSize)
				.overlay {
					ColorDetals(item: item, rectSize: rectSize)
				}
				.frame(height: 110)
				.contentShape(Rectangle())
				.offset(y: tappedCard ? 30 : 0)
				.zIndex(tappedCard ? 100 : 0)
				.onTapGesture {
					currentItem = item
					withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.4, blendDuration: 0.4)) {
						moveCardDown = true
					}
					
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
						withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 1, blendDuration: 1)) {
							expandCard = true
						}
					}
				}
		} else {
			Rectangle()
				.foregroundColor(.clear)
				.frame(height: 110)
		}
	}
	@ViewBuilder
	func ColorView(item: ColorValue, rectSize: CGSize) -> some View {
		Rectangle()
			.overlay {
				Rectangle()
					.fill(item.color.gradient)
			}
			.overlay {
				Rectangle()
					.fill(item.color.opacity(0.5).gradient)
					.rotationEffect(.init(degrees: 180))
			}
			.matchedGeometryEffect(id: item.id.uuidString, in: animation)
	}
	@ViewBuilder
	func ColorDetals(item: ColorValue, rectSize: CGSize) -> some View {
		HStack {
			Text("#\(item.colorCode)")
				.font(.title.bold())
				.foregroundColor(.white)
			
			Spacer(minLength: 0)
			
			VStackLayout(alignment: .leading, spacing: 4) {
				Text(item.title)
					.fontWeight(.semibold)
					.foregroundColor(.white)
				
				Text("Hexadecimal")
					.font(.caption)
					.foregroundColor(.white.opacity(0.7))
			}
			.frame(width: rectSize.width * 0.3, alignment: .leading)
		}
		.padding([.leading, .vertical], 15)
		.matchedGeometryEffect(id: item.id.uuidString + "DETAILS", in: animation)
	}
	@ViewBuilder
	func CustomProgressView(value: CGFloat, label: String) -> some View {
		HStack(spacing: 15) {
			Text(label)
				.fontWeight(.semibold)
				.foregroundColor(.white)
				.frame(width: 40, alignment: .leading)
			
			GeometryReader {
				let size = $0.size
				
				ZStack(alignment: .leading) {
					Rectangle()
						.fill(.black.opacity(0.75))
					
					Rectangle()
						.fill(.white)
						.frame(width: animateContent ? max(size.width * value, 0) : 0)
				}
			}
			.frame(height: 8)
			
			Text("\(Int(value * 255))")
				.fontWeight(.semibold)
				.foregroundColor(.white)
		}
	}
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension NSColor {
	var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat) {
		let colorSpace = usingColorSpace(.extendedSRGB) ?? .init(red: 1, green: 1, blue: 1, alpha: 1)
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alfa: CGFloat = 0
		colorSpace.getRed(&red, green: &green, blue: &blue, alpha: &alfa)
		return (red, green, blue)
	}
}
