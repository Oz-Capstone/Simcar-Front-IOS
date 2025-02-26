struct API {
    static let baseURL = "http://54.180.92.197:8080/api"
    // http://simcar.kro.kr
    
    // Member-Controller
    static let login = baseURL + "/members/login"
    static let logout = baseURL + "/members/logout"
    static let join = baseURL + "/members/join"
    static let profile = baseURL + "/members/profile"
    static let sales = baseURL + "/members/sales"
    
    // Favorite
    static let favorites = baseURL + "/favorites/"
    static let members_favorites = baseURL + "/members/favorites"
    
    // Car
    static let cars = baseURL + "/cars"
    static let car = baseURL + "/cars/"
}
