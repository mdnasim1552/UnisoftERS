// © 1994-2017 Unisoft Medical Systems
var GRSTabs = "000000000000000000";
var GRSArray = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
var GRSTabsPrev = "000000000000000000";
var GRSTabsLabels = ["GRS A-1", "GRS A-2", "GRS A-3", "GRS A-4", "GRS A-5", "GRS B-1", "GRS B-2", "GRS B-3", "GRS B-4", "GRS B-5", "GRS C-1", "GRS C-2", "GRS C-3", "GRS C-4", "GRS C-5", "GRS C-6", "GRS C-7", "GRS C-8"]
var PVArray = ["GRSA01PV", "GRSA02PV", "GRSA03PV", "GRSA04PV", "GRSA05PV", "GRSB01PV", "GRSB02PV", "GRSB03PV", "GRSB04PV", "GRSB05PV", "GRSC01PV", "GRSC02PV", "GRSC03PV", "GRSC04PV", "GRSC05PV", "GRSC06PV", "GRSC07PV", "GRSC08PV"];
var checkArray = ["cb1GRA2", "cb2GRA2", "cb3GRA2", "cb4GRA2", "cb1GRA3", "cb2GRA3", "cb3GRA3", "cb4GRA3", "cb5GRA3", "cb1GRA4", "cb2GRA4", "cb1GRA5", "cb2GRA5", "cb1GRB1", "cb2GRB1", "cb3GRB1", "cb1GRB2", "cb2GRB2", "cb1GRB3", "cb2GRB3", "cb3GRB3", "cb1Tumour", "cb2Tumour", "cb3Tumour", "cb4Tumour", "cb5Tumour", "cb6Tumour", "cb7Tumour", "cb1GRB5", "cb2GRB5", "cb1GRC1", "cb2GRC1", "cb1GRC2", "cb2GRC2", "cb3GRC2", "cb1GRC3", "cb2GRC3", "cb3GRC3", "cb4GRC3", "cb3GRC7", "cb1GRC8", "cb2GRC8", "cb6GRA3"];
var GRSTabChanged = -1;
var UnisoftReport = "";
var Unisoft = (function () {
    var isConsoleOn = true;
    var Window;
    return {
        WindowFileName: function (r) {
            var dest = getReportTarget(r);
            Unisoft.toConsole(dest);
            return dest;
        },
        Version: function (){
            alert("HD Clinical JS Class V 1.00");
        },
        toConsole: function (str) {
            if (isConsoleOn == true) {
                console.log(str);
            }
        },
        LoadDefaultReport: function (Group, columnName, rowID) {
            var Report = getDefaultColumnReport(Group, columnName);
            return Report;
        },
        PopUpWindow: function (anonimizedId, columnName, procedureTypeId) {
            var url = "PopUp.aspx?anonimizedId=" + anonimizedId + "&columnName=" + columnName + "&procedureTypeId=" + procedureTypeId;
            var own = radopen(url, "Guidelines For Sedation", '1000px', '600px');
            own.set_visibleStatusbar(false);
            //var cellInfo = URL + "?ReportID=" + ReportID + "&columnName=" + columnName + "&rowID=" + rowID;
            //if (URL != "") {

            //    if (URL != "Blank.aspx") {
            //        radopen(cellInfo, null);
            //    }
            //}
            return false;
        },
        PopUpWindowAD: function (URL, ReportID, columnName, rowID, AgeLimit, Drug) {
            var cellInfo = URL + "?ReportID=" + ReportID + "&columnName=" + columnName + "&rowID=" + rowID + "&AgeLimit=" + AgeLimit + "&Drug=" + Drug;
            if (URL != "") {

                if (URL != "Blank.aspx") {
                    radopen(cellInfo, null);
                }
            }
            return false;
        }
    };
})();
function ValidatingDates(sender, args) {
    var validated = Page_ClientValidate('FilterGroup');
    if (!validated) return;
}
function msieversion() {
    var ua = window.navigator.userAgent;
    var msie = ua.indexOf("MSIE ");
    if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./))  // If Internet Explorer, return version number
    {
        console.log("Internet Explorer");
        return true
    }
    else  // If another browser, return 0
    {
        console.log("Internet Explorer");
        return false;
    }
}
