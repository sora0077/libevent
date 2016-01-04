//
//  main.swift
//  libeventDemo
//
//  Created by 林達也 on 2016/01/04.
//  Copyright © 2016年 jp.sora0077. All rights reserved.
//

import Foundation
import libevent

print("Hello, World!")

func http_request_done(req: UnsafeMutablePointer<evhttp_request>, arg: UnsafeMutablePointer<Void>) {
    
    var buf = Array<CChar>(count: 256, repeatedValue: 0)
    var nread: Int32 = 0
    repeat {
        let input = evhttp_request_get_input_buffer(req)
        nread = evbuffer_remove(input, &buf, 255)
        if nread == 0 { break }
        print(String.fromCString(buf))
    } while(nread > 0)
    
    event_base_loopbreak(COpaquePointer(arg))
}

var uri_path: String = ""

let uri = evhttp_uri_parse("http://qiita.com/tattsun58/items/50e606696f1daa607a5f")
let host = evhttp_uri_get_host(uri)
let port = evhttp_uri_get_port(uri) == -1 ? 80 : evhttp_uri_get_port(uri)
let path = evhttp_uri_get_path(uri)
if let path = String.fromCString(path) where path.characters.count != 0 {
    uri_path = path
} else {
    uri_path = "/"
}

let base = event_base_new()
let dns_base = evdns_base_new(base, 1)

let conn = evhttp_connection_base_new(base, dns_base, host, UInt16(port))
let req = evhttp_request_new(http_request_done, UnsafeMutablePointer(base))

evhttp_add_header(req.memory.output_headers, "Host", host)
evhttp_add_header(req.memory.output_headers, "Connection", "close")

evhttp_make_request(conn, req, EVHTTP_REQ_GET, uri_path)
evhttp_connection_set_timeout(req.memory.evcon, 600)
event_base_dispatch(base)

evhttp_connection_free(conn)
event_base_free(base)
