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
        print(req)
        let input = evhttp_request_get_input_buffer(req)
        nread = evbuffer_remove(input, &buf, 255)
        fwrite(buf, Int(nread), 1, stdout)
    } while(nread > 0)
    
    event_base_loopbreak(COpaquePointer(arg))
}

let base = event_base_new()
let conn = evhttp_connection_base_new(base, nil, "https://httpbin.org", 80)
let req = evhttp_request_new(http_request_done, UnsafeMutablePointer(base))

evhttp_add_header(req.memory.output_headers, "Host", "https://httpbin.org")
evhttp_add_header(req.memory.output_headers, "Connection", "close")

evhttp_make_request(conn, req, EVHTTP_REQ_GET, "/")
evhttp_connection_set_timeout(req.memory.evcon, 100)
event_base_dispatch(base)

evhttp_connection_free(conn)
event_base_free(base)

print(base)

