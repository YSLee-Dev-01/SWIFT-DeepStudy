import Foundation
import PlaygroundSupport

/// Memory Allocation
/// - 메모리 할당은 타입이 아닌 context에 달려있음
///
/// inline 방식
/// - 별도의 메모리 할당 없이 타입의 메모리 블록에 직접 저장되는 것
/// - 부모의 메모리 블록에 직접 포함되어 저장되기 때문에 별도의 heap을 할당하지 않음
/// - 포인터를 따라갈 필요가 없이 때문에 속도가 빠름
/// -> 값 타입 (int, double, enum ..)
///
/// 1. class에 값 타입을 저장한 경우?
/// - heap에 저장됨
/// -> class의 인스턴스 자체가 heap에 존재하기 때문
/// -> 값 타입은 inline 방식이기 때문에 별도의 메모리를 할당하지 않고, 부모의 메모리 블록 안에 저장함
///
/// 2. struct에 참조 타입을 저장한 경우?
/// - 참조타입의 프로퍼티는 stack, 실제 객체는 heap에 저장됨
/// -> 참조 타입은 inline 방식이 아니기 때문에 별도의 heap 메모리를 할당 후 저장함
/// -> stack에는 heap 메모리의 주소만 저장함
///
/// 3. struct을 프로토콜 타입으로 사용한 경우?
/// - Existential Container 사용
/// - 값이 3 words 이하면 stack, 초과하면 heap에 저장 후 포인터만 value buffer (Stack)에 저장
/// -> struct을 프로토콜 타입으로 사용시에만 적용되는 규칙
///
/// words?
/// - cpu가 한번에 처리할 수 있는 데이터 단위
/// - 32bit - 4바이트 - 1 words
/// - 64bit - 8바이트 - 1 words
///
/// bool - 1바이트
/// char - 16바이트
/// int - 8바이트
/// dobule - 8바이트
///
/// Existential Container?
/// - 프로토콜 타입을 저장하기 위한 고정된 크기의 컨테이너
/// - 총 5 words = 64bit 기준 40바이트
/// - 항상 stack에 할당됨
/// -> 구조:
///             value buffer: 3 words, 값 또는 포인터 저장
///             value witness table: 1 words, 값의 생명주기 관리
///             protocol witness table: 1 words, 프로토콜 요구사항 구현체 참조
///
/// - 3 words를 넘으면 내부 value buffer에 값을 저장할 수 없기 때문에 heap으로 옮겨서 저장하는 것

protocol View {
    func draw()
}

struct Point: View { // 16바이트 - 2 words - heap 사용 X
    var x: Double // 8바이트
    var y: Double // 8바이트
    
    func draw() {
        print("Point drawing (\(x), \(y))")
    }
}

struct Size: View { // 32바이트 - 4 words - heap 사용
    var minWidth: Double // 8바이트
    var maxWidth: Double // 8바이트
    var minHeight: Double // 8바이트
    var maxHeight: Double // 8바이트
    
    func draw() {
        print("Size drawing: \(minWidth)~\(maxWidth) x \(minHeight)~\(maxHeight)")
    }
}

struct MainView {
    // inline 방식
    var point: View // stack에 할당
    var size: View // heap에 할당
}

class SubView {
    // inline 방식 X
    var point: View // heap에 할당
    var size: View // heap에 할당
    
    init(
        point: Point,
        size: Size
    ) {
        self.point = point
        self.size = size
    }
}

let mainView = MainView(point: Point(x: 0, y: 50), size: Size(minWidth: 50, maxWidth: 100, minHeight: 100, maxHeight: 200))
print("MainView")
mainView.point.draw()
mainView.size.draw()
print("---------")

let subView = SubView(point: .init(x: 25, y: 25), size: .init(minWidth: 10, maxWidth: 10, minHeight: 10, maxHeight: 10))
print("SubVIew")
subView.point.draw()
subView.size.draw()
