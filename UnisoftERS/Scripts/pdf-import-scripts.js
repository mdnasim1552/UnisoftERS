(function (global, undefined) {
    var demo = {};

    function populateValue() {
        $get(demo.label).innerHTML = $get(demo.textBox).value;
        //the RadWindow's content template is an INaming container and the server code block is needed
        $find(demo.contentTemplateID).close();
    }

    function openWinContentTemplate() {
        $find(demo.templateWindowID).show();
    }

    function openWinNavigateUrl() {
        $find(demo.urlWindowID).show();
    }

    function setCustomPosition(sender, args) {
        sender.moveTo(sender.getWindowBounds().x, 280);
    }

    function CancelPopupClose(e) {
        if (e.stopPropagation)
            e.stopPropagation();
        e.cancelBubble = true;
    }

    global.$windowContentDemo = demo; 
    global.populateValue = populateValue;
    global.openWinContentTemplate = openWinContentTemplate;
    global.setCustomPosition = setCustomPosition;
    global.CancelPopupClose = CancelPopupClose;
    
})(window);
    