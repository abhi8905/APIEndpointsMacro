

import APIEndpoints

@APIEndpoints()
    enum Paths: String {
        case popular, topRated, upcoming, nowPlaying
        
    }
let _ = Paths.nowPlaying.endpointUrl



