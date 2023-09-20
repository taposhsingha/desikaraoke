//
//  SpacesFileRepository.swift
//  Runner
//
//  Created by Borhan Uddin on 8/6/20.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import AWSS3
import Foundation

/// An enum representing the regions in which DO Spaces are available
private enum SpaceRegion: String {
    case sfo = "sfo2", ams = "ams3", sgp = "sgp1"

    var endpointUrl: String {
        return "https://\(rawValue).digitaloceanspaces.com"
    }
}

struct SpacesFileRepository {
    private static let accessKey = "MX63A2B35TQPORPAONDQ"
    private static let secretKey = "JQQ6c+G4hxKqOvZ7kuEpM08KfmVnToLrdw7BI9c6y0U"
    private static let bucket = "d-karaoke"
    private let fileName = "example-image"

    private var transferUtility: AWSS3TransferUtility?

    init() {
        // Create a credential using DO Spaces API key (https://cloud.digitalocean.com/account/api/tokens)
        let credential = AWSStaticCredentialsProvider(accessKey: SpacesFileRepository.accessKey, secretKey: SpacesFileRepository.secretKey)

        // Create an endpoint that points to the data centre where you created your Space
        let regionEndpoint = AWSEndpoint(urlString: SpaceRegion.sgp.endpointUrl)

        // Create a configuration using the credential and endpoint. Note that region doesn't matter
        let configuration = AWSServiceConfiguration(region: .USEast1, endpoint: regionEndpoint, credentialsProvider: credential)
        AWSServiceManager.default()?.defaultServiceConfiguration = configuration
        // Setup a configuration to point to your Space. Make bucket the name of your Space
        let transferConfiguration = AWSS3TransferUtilityConfiguration()
        transferConfiguration.isAccelerateModeEnabled = false
        transferConfiguration.bucket = SpacesFileRepository.bucket

        // Now register your Space with the AWS Transfer Utility so you can upload/download files
        AWSS3TransferUtility.register(with: configuration!, transferUtilityConfiguration: transferConfiguration, forKey: SpacesFileRepository.bucket)
        transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: SpacesFileRepository.bucket)
    }

    /// Uploads an example file (see example-image.jpg in the project directory) using the S3 SDK to your space
    func uploadExampleFile() {
        // Get the image URL within the app bundle
        guard let exampleImage = Bundle.main.url(forResource: fileName, withExtension: "jpg") else {
            print("Example image URL not found")
            return
        }

        // Create an upload task
        transferUtility?.uploadFile(exampleImage, key: fileName, contentType: "image/jpeg", expression: nil, completionHandler: { _, error in
            guard error == nil else {
                print("S3 Upload Error: \(error!.localizedDescription)")
                return
            }

            print("S3 Upload Completed")
        }).continueWith(block: { (_) -> Any? in
            // Now lets start the upload task
            print("S3 Upload Starting")
            return nil
        })
    }

    func getPresignedUrl(path: String, callback: @escaping (NSURL?, Error?) -> Void) {
        let date = Date() + 3600
        let getPreSignedURLRequest: AWSS3GetPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
        getPreSignedURLRequest.bucket = SpacesFileRepository.bucket
        getPreSignedURLRequest.expires = date
        getPreSignedURLRequest.httpMethod = AWSHTTPMethod.GET
        getPreSignedURLRequest.key = path
        var preSignedURL: NSURL?
        AWSS3PreSignedURLBuilder.default().getPreSignedURL(getPreSignedURLRequest).continueWith { (task: AWSTask<NSURL>) -> Any? in
            if let error = task.error as NSError? {
                callback(nil, error)
                return nil
            }
            preSignedURL = task.result
            callback(preSignedURL, nil)
            return nil
        }
    }

    func downloadExampleFile(path: String, callback: @escaping ((Data?, Error?) -> Void)) {
        // Create a download task. Replace your-file-name with your actual file name.
        transferUtility?.downloadData(forKey: path, expression: nil, completionHandler: { _, _, data, error in
            guard error == nil else {
                print("S3 Download Error: \(error!.localizedDescription)")
                callback(nil, error)
                return
            }
            print("S3 Download Completed")
            callback(data, nil)
        }).continueWith(block: { (_) -> Any? in
            // Now lets start the download task
            print("S3 Download Starting")
            return nil
        })
    }
}
