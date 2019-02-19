// Copyright Keefer Taylor, 2019

import Foundation

/**
 * A response handler handles responses that are received when network requests are completed.
 */
public class RPCResponseHandler {
  // TODO: Remove
  /** The queue that callbacks from requests will be made on. */
  private let callbackQueue: DispatchQueue

  /** Initialize a new response handler with the given callback queue. */
  public init(callbackQueue: DispatchQueue) {
    self.callbackQueue = callbackQueue
  }

  // TODO: Create a convenience method for error handling

  /**
   * Handle a response from the network.
   * - Parameter rpc: The RPC which made the request to the network.
   * - Parameter data: Raw data returned from the network, if it exists.
   * - Parameter response: The URLResponse associated with the request, if it exists.
   * - Parameter error: An error in the request, if one occurred.
   * - Returns: A tuple containing the results of the parsing operation if successful, otherwise an error.
   */
  public func handleResponse<T>(
    rpc: TezosRPC<T>,
    data: Data?,
    response: URLResponse?,
    error: Error?
  ) -> (result: T?, error: Error?) {
    // Check if the response contained a 200 HTTP OK response. If not, then propagate an error.
    if let httpResponse = response as? HTTPURLResponse,
      httpResponse.statusCode != 200 {
      // Default to unknown error and try to give a more specific error code if it can be narrowed
      // down based on HTTP response code.
      var errorKind: TezosClientError.ErrorKind = .unknown
      // Status code 40X: Bad request was sent to server.
      if httpResponse.statusCode >= 400, httpResponse.statusCode < 500 {
        errorKind = .unexpectedRequestFormat
      // Status code 50X: Bad request was sent to server.
      } else if httpResponse.statusCode >= 500 {
        errorKind = .unexpectedResponse
      }

      // Decode the server's response to a string in order to bundle it with the error if it is in
      // a readable format.
      var errorMessage = ""
      if let data = data,
        let dataString = String(data: data, encoding: .utf8) {
        errorMessage = dataString
      }

      // Drop data and send our error to let subsequent handlers know something went wrong and to
      // give up.
      let error = TezosClientError(kind: errorKind, underlyingError: errorMessage)
      rpc.handleResponse(data: nil, error: error, callbackQueue: self.callbackQueue)
      return (nil, error)
    }

    // Check for a generic error on the request. If so, propagate.
    if let error = error {
      let desc = error.localizedDescription
      let tezosClientError = TezosClientError(kind: .rpcError, underlyingError: desc)
      callbackQueue.async {
        // TODO: Make completion public
        rpc.completion(nil, tezosClientError)
      }
      return (nil, error)
    }

    // Ensure that data came back.
    guard let data = data,
      let parsedData = parse(data, with: rpc.responseAdapterClass) else {
        let tezosClientError = TezosClientError(kind: .unexpectedResponse, underlyingError: nil)
        return (nil, tezosClientError)
    }

    return (parsedData, nil)
  }

  /**
   * Parse the given data to an object with the given response adapter.
   * - Parameter data: Data to parse.
   * - Paramater responseAdapterClass: A response adapter class to use for parsing the data.
   * - Returns: The parsed type if the data was was valid, otherwise nil.
   */
  private func parse<T>(_ data: Data, with responseAdapterClass: AbstractResponseAdapter<T>.Type) -> T? {
    // TODO: Drop input:
    guard let result = responseAdapterClass.parse(input: data) else {
      return nil
    }
    return result;
  }
}
