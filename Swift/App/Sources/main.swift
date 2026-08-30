//
//  main.swift
//  Swift
//
//  Created by 김민택 on 2022/12/25.
//

// Swift Version Info
// 백준: Swift 5.5.2
// 프로그래머스: Swift 5.2.5
// Samsung SW Expert Academy: 미지원
// Codility: Swift 4
// CODEFORCES: 미지원
// LeetCode: Swift 5.5.2
// CodeUp: 미지원

import Foundation

import Programmers
import Shared

let main = PGM118669()
main.run()

public struct PGM118669: Solvable {
    public init() {}

    public func run() {
        print(solution(6, [[1, 2, 3], [2, 3, 5], [2, 4, 2], [2, 5, 4], [3, 4, 4], [4, 5, 3], [4, 6, 1], [5, 6, 1]], [1, 3], [5]) == [5, 3])
        print(solution(7, [[1, 4, 4], [1, 6, 1], [1, 7, 3], [2, 5, 2], [3, 7, 4], [5, 6, 6]], [1], [2, 3, 4]) == [3, 4])
        print(solution(7, [[1, 2, 5], [1, 4, 1], [2, 3, 1], [2, 6, 7], [4, 5, 1], [5, 6, 1], [6, 7, 1]], [3, 7], [1, 5]) == [5, 1])
        print(solution(5, [[1, 3, 10], [1, 4, 20], [2, 3, 4], [2, 4, 6], [3, 5, 20], [4, 5, 6]], [1, 2], [5]) == [5, 6])
    }

    func solution(_ n: Int, _ paths: [[Int]], _ gates: [Int], _ summits: [Int]) -> [Int] {
        var times = Array(repeating: [(Int, Int)](), count: n+1)
        var start = Array(repeating: false, count: n+1)
        var end = Array(repeating: false, count: n+1)
        var heap = Heap<Point>(compare: <)
        var idx = 0
        var pathTime = Array(repeating: Array(repeating: 2000000000001, count: n+1), count: n+1)

        for path in paths {
            times[path[0]].append((path[1], path[2]))
            times[path[1]].append((path[0], path[2]))
            pathTime[path[0]][path[1]] = path[2]
            pathTime[path[1]][path[0]] = path[2]

            if start[path[0]] && start[path[1]] { continue }
            else if start[path[0]] { heap.push(Point(start: path[0], end: path[1], time: path[2])) }
            else if start[path[1]] { heap.push(Point(start: path[1], end: path[0], time: path[2])) }
        }

        while !heap.isEmpty {
            let now = heap.pop()!
            pathTime[now.start][now.end] = min(pathTime[now.start][now.end], now.time)
            // start end time -> time 정렬
            // start를 mid로 보거나 end를 mid로 보는 경우 생기기도 함
            // 마지막에 참고하는건 그 전까지 쌓인 start-mid, mid-end를 기반으로한 mid-end
            // 가장 긴 time 중 가장 짧은 time => 전체는 가장 긴 time으로, 최종 결과는 그 중에서 가장 짧은 time으로
            // 2차원 배열 재활용 => 원래 사용하던 걸 1차로 임시 저장, 2차로 최종 결과 저장용으로 => 마지막엔 최소만 있으면 되므로 추가 배열 없이 변수 하나 갱신해서 최장 중 최소 추적 => 최소 자체를 저장 및 경로 저장 => 찾는 것이 전체 경로가 아님 => 총 세개의 값 저장 (변수 하나는 최소값, 나머지 하나에 시작점 및 도착점: String or Int)
            // String 사용시 바로 답으로 사용 가능, Int 사용시 조합 쉬움
            // heap 내부에 누적, 가장 큰 값만 꺼내서 사용
            // 가장 큰 값만 꺼내기 때문에 가장 긴 time 보장
            // 다음 값들은 그 안에서 합쳐진다? => 무작정 합쳐지면 안되고 경로가 이어질 경우만
            // 경로가 이어지는 것 중 가장 긴 시간 => heap에 저장된 기존 경로들 중 같은 경로에서 가장 시간이 긴 경우
            // 경로 뽑아서 더 긴 시간일 경우 갱신 => 짧으면 무시 (짧으면 재사용 될 일 없음) => 단 이미 사용된 경우라도 다시 사용될 가능성은 있음 => 이 경우 대비해서 뽑은 경로 다시 집어 넣어야 함
            // 뽑은 경로를 다시 넣었을 때 문제 발생할 수 있음. => 이차원 배열로 테이블 만들어서 저장 => heap에서 꺼내서 배열에 넣고 이 값을 재사용
        }

        return []
    }

    struct Point: Comparable {
        let start: Int
        let end: Int
        let time: Int

        static func < (lhs: Point, rhs: Point) -> Bool {
            return lhs.time < rhs.time
        }
    }

    struct Heap<T: Comparable> {
        private var heap = [T]()
        private var compare: (T, T) -> Bool
        var isEmpty: Bool {
            return heap.isEmpty
        }

        init(compare: @escaping (T, T) -> Bool) {
            self.compare = compare
        }

        mutating func push(_ element: T) {
            var idx = heap.count
            heap.append(element)

            while idx > 0 {
                if compare(heap[(idx-1)/2], heap[idx]) {
                    break
                }

                heap.swapAt(idx, (idx-1)/2)
                idx = (idx - 1) / 2
            }
        }

        mutating func pop() -> T? {
            if isEmpty { return nil }

            heap.swapAt(0, heap.count - 1)
            let res = heap.removeLast()
            var idx = 0

            while idx * 2 < heap.count {
                var next = idx * 2

                if next + 1 < heap.count && compare(heap[next+1], heap[next]) {
                    next += 1
                }

                if compare(heap[next], heap[idx]) {
                    heap.swapAt(idx, next)
                    idx = next
                }
            }

            return res
        }
    }
}

class LinkedList {
    public init() {}

    public func run() {
        var list = LinkedList<Int>()
        print(list)
        list.push(1)
        list.push(2)
        print(list)
        list.insert(3, at: 0)
        print(list)
        list.insert(4, at: 1)
        list.insert(5, at: 1)
        print(list)
        print(list.remove(at: 2)!.value)
        print(list)
        print(list.pop()!.value)
        print(list)
    }

    class Node<T> {
        var value: T
        var next: Node?

        init(value: T, next: Node? = nil) {
            self.value = value
            self.next = next
        }
    }

    struct LinkedList<T>: CustomStringConvertible {
        var head: Node<T>?
        var tail: Node<T>?

        var isEmpty: Bool {
            head == nil
        }

        var count: Int {
            var (idx, current) = (0, head)

            while current != nil {
                current = current!.next
                idx += 1
            }

            return idx
        }

        var description: String {
            if isEmpty {
                return "Empty List"
            }

            var current = head
            var list = ""

            while current != nil {
                list += "\(current!.value) -> "
                current = current!.next
            }

            list.removeLast(4)

            return list
        }

        mutating func push(_ data: T) {
            if isEmpty {
                head = Node(value: data)
                tail = head
                return
            }

            tail!.next = Node(value: data)
            tail = tail!.next
        }

        mutating func insert(_ data: T, at idx: Int) {
            if isEmpty {
                push(data)
                return
            }

            if idx == 0 {
                let node = Node(value: data, next: head)
                head = node
                return
            }

            let prev = find(at: idx-1)
            prev!.next = Node(value: data, next: prev!.next)
        }

        mutating func find(at idx: Int) -> Node<T>? {
            var current = (idx: 0, node: head)

            while current.node != nil && current.idx < idx {
                current.node = current.node!.next
                current.idx += 1
            }

            return current.node
        }

        mutating func pop() -> Node<T>? {
            if count == 1 {
                let node = head
                head = nil

                return node
            }

            let node = find(at: count-1)
            let prev = find(at: count-2)
            tail = prev
            tail!.next = nil

            return node
        }

        mutating func remove(at idx: Int) -> Node<T>? {
            if idx == 0 {
                let node = find(at: 0)
                head = find(at: 1)
                return node
            }

            let node = find(at: idx)
            find(at: idx-1)!.next = node!.next

            return node
        }
    }
}

func getAddress(address o: UnsafeRawPointer) -> String {
    String(format: "%p", Int(bitPattern: o))
}

class Ex3_4 {
    public init() {}

    public func run() {
        let A = Polynomial(degree: 3, coef: [4, 3, 5, 0])
        let B = Polynomial(degree: 4, coef: [3, 1, 0, 2, 1])
        let C = addPoly(A, B)

        print("A(x) = \(printPoly(A))")
        print("B(x) = \(printPoly(B))")
        print("C(x) = \(printPoly(C))")
    }

    private func addPoly(_ A: Polynomial, _ B: Polynomial) -> Polynomial {
        var (A_index, B_index, C_index) = (0, 0, 0)
        var (A_degree, B_degree) = (A.degree, B.degree)
        var C = Polynomial(degree: max(A.degree, B.degree))

        while A_index <= A.degree && B_index <= B.degree {
            if A_degree > B_degree {
                C.coef[C_index] = A.coef[A_index]
                C_index += 1
                A_index += 1
                A_degree -= 1
            } else if A_degree == B_degree {
                C.coef[C_index] = A.coef[A_index] + B.coef[B_index]
                C_index += 1
                A_index += 1
                B_index += 1
                A_degree -= 1
                B_degree -= 1
            } else {
                C.coef[C_index] = B.coef[B_index]
                C_index += 1
                B_index += 1
                B_degree -= 1
            }
        }

        return C
    }

    private func printPoly(_ P: Polynomial) -> String {
        var expression = ""
        var degree = P.degree

        for i in 0...P.degree {
            expression += "\(P.coef[i])x^\(degree)\(i < P.degree ? " + " : "")"
            degree -= 1
        }

        return expression
    }

    struct Polynomial {
        var degree: Int
        var coef: [Int]

        init(degree: Int) {
            self.degree = degree
            self.coef = Array(repeating: 0, count: degree+1)
        }

        init(degree: Int, coef: [Int]) {
            self.degree = degree
            self.coef = coef
        }
    }
}

class SequenceList {
    public init() {}

    public func run() {
        var array = [[[1, 2, 3, 4], [5, 6, 7, 8]], [[9, 10, 11, 12], [13, 14, 15, 16]]]
        for i in array.indices {
            for j in array[i].indices {
                for k in array[i][j].indices {
                    withUnsafePointer(to: &array[i][j][k]) {
                        print("&array[\(i)][\(j)][\(k)]: \($0)")
                    }
                }
            }
        }
//        for row in array.indices {
//            for col in array[row].indices {
//                withUnsafePointer(to: &array[row][col]) {
//                    print("&array[\(row)][\(col)]: \($0)")
//                }
//            }
//        }
    }
}
