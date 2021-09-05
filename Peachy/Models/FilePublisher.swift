import Combine
import Foundation

class FileSubscription<S: Subscriber>: Subscription
    where S.Input == Data, S.Failure == Error {

    // fileURL is the url of the file to read
    private let fileURL: URL
    private var subscriber: S?

    init(fileURL: URL, subscriber: S) {
        self.fileURL = fileURL
        self.subscriber = subscriber
    }

    func request(_ demand: Subscribers.Demand) {
        // Load the file at fileURL only when demand is
        // greater than 0, meaning subscribers were added
        // to this subscription and demand values
        if demand > 0 {
            do {
                // Success case, data is loaded and this
                // subscription finishes
                let data = try Data(contentsOf: fileURL)
                subscriber?.receive(data)
                subscriber?.receive(completion: .finished)
            }
            catch let error {
                // Failure case, this subscription finishes
                // and propagates the error
                subscriber?.receive(
                    completion: .failure(error)
                )
            }
        }
    }

    // Set the subscriber reference to nil, cancelling
    // the subscription
    func cancel() {
        subscriber = nil
    }
}

struct FilePublisher: Publisher {
    // The output type of FilePublisher publisher
    // is Data, which will be the Data of the read file
    typealias Output = Data

    typealias Failure = Error
    
    // fileURL is the url of the file to read
    let fileURL: URL
    
    func receive<S>(subscriber: S) where S : Subscriber,
        Failure == S.Failure, Output == S.Input {

        // Create a FileSubscription for the new subscriber
        // and set the file to be loaded to fileURL
        let subscription = FileSubscription(
            fileURL: fileURL,
            subscriber: subscriber
        )
        
        subscriber.receive(subscription: subscription)
    }
}
