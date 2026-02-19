//
//  CountdownTests.swift
//  CountdownTests
//
//  Created by Antoine Coilliaux on 10/02/2026.
//

import XCTest
@testable import Countdown

final class CountdownTests: XCTestCase {
    let vm = HomeViewModel()

    func testSortEvents() {
        let now = Date()
        
        vm.events = [
            Event(id: UUID(), name: "Past", date: now.addingTimeInterval(-3600), imageName: URL(string: "https://fastly.picsum.photos/id/998/300/300.jpg?hmac=CqTPyw23mdWCpY1vSNoWUU5ipnTa6BtTsGc_ztfonWI")!),
            Event(id: UUID(), name: "Future far", date: now.addingTimeInterval(7200), imageName: URL(string: "https://fastly.picsum.photos/id/998/300/300.jpg?hmac=CqTPyw23mdWCpY1vSNoWUU5ipnTa6BtTsGc_ztfonWI")!),
            Event(id: UUID(), name: "Future near", date: now.addingTimeInterval(600), imageName: URL(string: "https://fastly.picsum.photos/id/998/300/300.jpg?hmac=CqTPyw23mdWCpY1vSNoWUU5ipnTa6BtTsGc_ztfonWI")!)
           ]

           vm.sortEvents()

           XCTAssertEqual(vm.events[0].name, "Future near")
           XCTAssertEqual(vm.events[1].name, "Future far")
           XCTAssertEqual(vm.events[2].name, "Past")
           XCTAssertEqual(vm.events.count, 3)
    }
    
    func testAddEvent_addsAndSorts() {
        vm.events = []

        let future = Event(id: UUID(), name: "Future", date: Date().addingTimeInterval(3600), imageName: URL(string: "https://fastly.picsum.photos/id/998/300/300.jpg?hmac=CqTPyw23mdWCpY1vSNoWUU5ipnTa6BtTsGc_ztfonWI")!)
        vm.addEvent(future)

        XCTAssertEqual(vm.events.count, 1)
        XCTAssertEqual(vm.events.first?.name, "Future")
    }

    func testUpdateEvent_updatesCorrectEvent() {
        let event = Event(id: UUID(), name: "Old", date: Date(), imageName: URL(string: "https://fastly.picsum.photos/id/998/300/300.jpg?hmac=CqTPyw23mdWCpY1vSNoWUU5ipnTa6BtTsGc_ztfonWI")!)
        let vm = HomeViewModel()
        vm.events = [event]

        let updated = Event(id: event.id, name: "New", date: event.date, imageName: URL(string: "https://fastly.picsum.photos/id/998/300/300.jpg?hmac=CqTPyw23mdWCpY1vSNoWUU5ipnTa6BtTsGc_ztfonWI")!)
        vm.updateEvent(updated)

        XCTAssertEqual(vm.events.first?.name, "New")
    }
    
    func testDeleteEvent_removesEvent() {
        let event = Event(id: UUID(), name: "Test", date: Date(), imageName: URL(string: "https://fastly.picsum.photos/id/998/300/300.jpg?hmac=CqTPyw23mdWCpY1vSNoWUU5ipnTa6BtTsGc_ztfonWI")!)
        let vm = HomeViewModel()
        vm.events = [event]
        
        vm.deleteEvent(IndexSet(integer:0))
        
        XCTAssertTrue(vm.events.isEmpty)
    }

}
