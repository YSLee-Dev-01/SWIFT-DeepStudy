import Foundation
import PlaygroundSupport

/// Indirect
///
/// - enum에서 자기 자신을 참조할 수 있도록 만들어주는 키워드
/// -> 재귀적인 데이터 구조를 표현할 수 있게 함
/// -> struct에서는 사용 불가
///
/// - case 별로 지정할 수 있고, enum 전체에도 지정할 수 있음
///
/// - enum과 같은 값 타입은 컴파일 시 메모리 크기가 결정되어야 하는데, 재귀구조를 사용하면 컴파일 시 결정되지 않음
/// -> 재귀구조를 사용할 수 없음
///
/// - Indirect 키워드를 사용하면 간접 참조를 허용함
/// -> 간접 참조를 사용할 경우 해당 case는 stack이 아닌 heap 메모리에 할당하고 포인터로 참조하게 됨
/// -> 오버헤드가 발생할 수 있음
///
///- 트리, 연결리스트, AST 같은 재귀구조에 많이 사용됨
///- Indirect를 사용하면 컴파일러는 자동으로 Box<T>와 같은 구조를 만들어줌
///
/// Box 패턴
/// - 값 타입을 참조타입(Class)로 감싸서 간접 참조를 만드는 패턴
/// - Box는 heap에 할당되고, 내부 값 타입은 inline 방식으로 새로운 메모리를 할당하지 않고, 부모의 heap 메모리에 그대로 할당됨
/// + Indirect를 사용하지 않고 Box 패턴을 통해서 재귀가 가능한 enum을 만들 수도 있음

indirect enum Expression {
    case number(Int)
    case add(Expression, Expression)
    case minus(Expression, Expression)
    case multiply(Expression, Expression)
    case division(Expression, Expression)
    
    func evaluate() -> Int {
        switch self {
        case .number(let number):
            return number
            
        case .add(let left, let right):
            return left.evaluate() + right.evaluate()
            
        case .minus(let left, let right):
            return left.evaluate() - right.evaluate()
            
        case .multiply(let left, let right):
            return left.evaluate() * right.evaluate()
            
        case .division(let left, let right):
            return left.evaluate() / right.evaluate()
        }
    }
}

let example = Expression.multiply(
    .add(.number(5), .number(3)),
    .minus(
        .division(.number(10), .number(2)),
        .number(5)
     )
)
print(example.evaluate())
