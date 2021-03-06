//
//  html5parserTests.swift
//  html5parserTests
//
//  Created by Johannes Schriewer on 17/11/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the conditions of the 3-clause
// BSD license (see LICENSE.txt for full license text)

import XCTest
@testable import html5tokenizer

class html5tokenizerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testText() {
        let tokens = HTML5Tokenizer(htmlString: "Text").tokenize()
        XCTAssert(tokens.count == 1)
        if case .text(let data) = tokens[0] {
            XCTAssert(data == "Text")
        }
        else {
            XCTFail("Not a text token")
        }
    }

    func testTextWithNamedCharacter() {
        let tokens = HTML5Tokenizer(htmlString: "Text&amp;&uuml;").tokenize()
        XCTAssert(tokens.count == 1)
        if case .text(let data) = tokens[0] {
            XCTAssert(data == "Text&ü")
        }
        else {
            XCTFail("Not a text token")
        }
    }

    func testTextWithHexCharacter() {
        let tokens = HTML5Tokenizer(htmlString: "Text&#x0020;").tokenize()
        XCTAssert(tokens.count == 1)
        if case .text(let data) = tokens[0] {
            XCTAssert(data == "Text ")
        }
        else {
            XCTFail("Not a text token")
        }
    }

    func testTextWithNumberedCharacter() {
        let tokens = HTML5Tokenizer(htmlString: "Text&#32;").tokenize()
        XCTAssert(tokens.count == 1)
        if case .text(let data) = tokens[0] {
            XCTAssert(data == "Text ")
        }
        else {
            XCTFail("Not a text token")
        }
    }


    func testSimpleHTML() {
        let tokens = HTML5Tokenizer(htmlString: "<strong>Text</strong>").tokenize()
        XCTAssert(tokens.count == 3)
        if case .startTag(let name, let selfClosing, let attributes) = tokens[0] {
            XCTAssert(name == "strong")
            XCTAssert(selfClosing == false)
            XCTAssert(attributes == nil)
        }
        else {
            XCTFail("Not a start tag")
        }

        if case .text(let data) = tokens[1] {
            XCTAssert(data == "Text")
        }
        else {
            XCTFail("Not a text node")
        }

        if case .endTag(let name) = tokens[2] {
            XCTAssert(name == "strong")
        }
        else {
            XCTFail("Not an end tag")
        }
    }

    func testSelfClosing() {
        let tokens = HTML5Tokenizer(htmlString: "<br/>").tokenize()
        XCTAssert(tokens.count == 1)
        if case .startTag(let name, let selfClosing, let attributes) = tokens[0] {
            XCTAssert(name == "br")
            XCTAssert(selfClosing == true)
            XCTAssert(attributes == nil)
        }
        else {
            XCTFail("Not a start tag")
        }
    }

    func testSelfClosing2() {
        let tokens = HTML5Tokenizer(htmlString: "<br />").tokenize()
        XCTAssert(tokens.count == 1)
        if case .startTag(let name, let selfClosing, let attributes) = tokens[0] {
            XCTAssert(name == "br")
            XCTAssert(selfClosing == true)
            XCTAssert(attributes == nil)
        }
        else {
            XCTFail("Not a start tag")
        }
    }

    func testCapsulatedHTML() {
        let tokens = HTML5Tokenizer(htmlString: "<em><strong>Text</strong></em>").tokenize()
        XCTAssert(tokens.count == 5)
        if case .startTag(let name, let selfClosing, let attributes) = tokens[0] {
            XCTAssert(name == "em")
            XCTAssert(selfClosing == false)
            XCTAssert(attributes == nil)
        }
        else {
            XCTFail("Not a start tag")
        }

        if case .startTag(let name, let selfClosing, let attributes) = tokens[1] {
            XCTAssert(name == "strong")
            XCTAssert(selfClosing == false)
            XCTAssert(attributes == nil)
        }
        else {
            XCTFail("Not a start tag")
        }

        if case .text(let data) = tokens[2] {
            XCTAssert(data == "Text")
        }
        else {
            XCTFail("Not a text node")
        }

        if case .endTag(let name) = tokens[3] {
            XCTAssert(name == "strong")
        }
        else {
            XCTFail("Not an end tag")
        }

        if case .endTag(let name) = tokens[4] {
            XCTAssert(name == "em")
        }
        else {
            XCTFail("Not an end tag")
        }
    }

    func testSelfClosingWithAttributes() {
        let tokens = HTML5Tokenizer(htmlString: "<img src='http://google.com/bla.jpg' alt='Google Logo' />").tokenize()
        XCTAssert(tokens.count == 1)
        if case .startTag(let name, let selfClosing, let attributes) = tokens[0] {
            XCTAssert(name == "img")
            XCTAssertNotNil(attributes)
            XCTAssert(attributes!.count == 2)
            for (key, value) in attributes! {
                if (key == "src" && value != "http://google.com/bla.jpg") ||
                   (key == "alt" && value != "Google Logo") {
                    XCTFail("attribute parsing failed")
                }
            }
            XCTAssert(selfClosing == true)
        }
        else {
            XCTFail("Not a start tag")
        }
    }

    func testComplexHTML() {
        let file = Bundle(for: type(of: self)).path(forResource: "html5tokenization", ofType: "html")
        XCTAssertNotNil(file)
        do {
            let string = try String(contentsOfFile: file!)
            XCTAssertNotNil(string)
            let tokens = HTML5Tokenizer(htmlString: string).tokenize()
            for t in tokens {
                print(t.debugDescription)
            }
        }
        catch {
            XCTFail("Could not load HTML file")
        }
    }

    func testComplexHTMLPerformance() {
        let file = Bundle(for: type(of: self)).path(forResource: "html5tokenization", ofType: "html")
        XCTAssertNotNil(file)
        do {
            let string = try String(contentsOfFile: file!)
            XCTAssertNotNil(string)
            let tokenizer = HTML5Tokenizer(htmlString: string)
            measure {
                _ = tokenizer.tokenize()
            }
        }
        catch {
            XCTFail("Could not load HTML file")
        }

    }
}
