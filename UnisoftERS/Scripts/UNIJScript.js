function myAlert() {
    alert("Please exit!");
}

function OpenWindow() {
    var wnd = window.radopen("http://www.bing.com", null);
    wnd.setSize(400, 400);
    return false;
}