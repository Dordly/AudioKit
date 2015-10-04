//
//  AKStringResonator.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

/** A string resonator with variable fundamental frequency.

AKStringResonator passes the input through a network composed of comb, low-pass and all-pass filters, similar to the one used in some versions of the Karplus-Strong algorithm, creating a string resonator effect. The fundamental frequency of the “string” is controlled by the fundamentalFrequency.  This operation can be used to simulate sympathetic resonances to an input signal.
*/
@objc class AKStringResonator : AKParameter {

    // MARK: - Properties

    private var streson = UnsafeMutablePointer<sp_streson>.alloc(1)
    private var streson2 = UnsafeMutablePointer<sp_streson>.alloc(1)

    private var input = AKParameter()


    /** Fundamental frequency of string. [Default Value: 100.0] */
    var fundamentalFrequency: AKParameter = akp(100.0) {
        didSet {
            fundamentalFrequency.bind(&streson.memory.freq, right:&streson2.memory.freq)
            dependencies.append(fundamentalFrequency)
        }
    }

    /** Feedback amount (value between 0-1). A value close to 1 creates a slower decay and a more pronounced resonance. Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9. [Default Value: 0.95] */
    var feedback: AKParameter = akp(0.95) {
        didSet {
            feedback.bind(&streson.memory.fdbgain, right:&streson2.memory.fdbgain)
            dependencies.append(feedback)
        }
    }


    // MARK: - Initializers

    /** Instantiates the filter with default values

    - parameter input: Input audio signal. 
    */
    init(_ input: AKParameter)
    {
        super.init()
        self.input = input
        setup()
        dependencies = [input]
        bindAll()
    }

    /** Instantiates the filter with all values

    - parameter input: Input audio signal. 
    - parameter fundamentalFrequency: Fundamental frequency of string. [Default Value: 100.0]
    - parameter feedback: Feedback amount (value between 0-1). A value close to 1 creates a slower decay and a more pronounced resonance. Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9. [Default Value: 0.95]
    */
    convenience init(
        _ input:              AKParameter,
        fundamentalFrequency: AKParameter,
        feedback:             AKParameter)
    {
        self.init(input)
        self.fundamentalFrequency = fundamentalFrequency
        self.feedback             = feedback

        bindAll()
    }

    // MARK: - Internals

    /** Bind every property to the internal filter */
    internal func bindAll() {
        fundamentalFrequency.bind(&streson.memory.freq, right:&streson2.memory.freq)
        feedback            .bind(&streson.memory.fdbgain, right:&streson2.memory.fdbgain)
        dependencies.append(fundamentalFrequency)
        dependencies.append(feedback)
    }

    /** Internal set up function */
    internal func setup() {
        sp_streson_create(&streson)
        sp_streson_create(&streson2)
        sp_streson_init(AKManager.sharedManager.data, streson)
        sp_streson_init(AKManager.sharedManager.data, streson2)
    }

    /** Computation of the next value */
    override func compute() {
        sp_streson_compute(AKManager.sharedManager.data, streson, &(input.leftOutput), &leftOutput);
        sp_streson_compute(AKManager.sharedManager.data, streson2, &(input.rightOutput), &rightOutput);
    }

    /** Release of memory */
    override func teardown() {
        sp_streson_destroy(&streson)
        sp_streson_destroy(&streson2)
    }
}