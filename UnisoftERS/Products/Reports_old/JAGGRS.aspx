<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="JAGGRS.aspx.vb" Inherits="UnisoftERS.JAGGRS" Debug="true" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %><!DOCTYPE html><html><head runat="server"><title></title><script type="text/javascript" src="../../Scripts/global.js"></script><script type="text/javascript" src="../../Scripts/jquery-1.11.0.min.js"></script><telerik:RadScriptBlock  runat="server">
    <link href="../../Styles/Site.css" rel="stylesheet" />
    <link href="/Styles/Reporting.css" rel="stylesheet" />
    <script type="text/javascript" src="/Scripts/Reports.js"></script>
    <script type="text/javascript">
        var docURL = document.URL;
        var grid;
        var OGD = {}
        OGD.columnName = "";
        OGD.rowID = "";
        var PEG = {}
        PEG.columnName = "";
        PEG.rowID = "";
        var ERC = {}
        ERC.columnName = "";
        ERC.rowID = "";
        var SIG = {}
        SIG.columnName = "";
        SIG.rowID = "";
        var COL = {}
        COL.columnName = "";
        COL.rowID = "";
        var BPS = {}
        BPS.columnName = "";
        BPS.rowID = "";
        var BPB = {}
        BPB.columnName = "";
        BPB.rowID = "";
        var CON = {}
        CON.columnName = "";
        CON.rowID = "";
        function getReportTarget(rti) {
            var res;
            var jsondata = {
                ReportID: rti
            };
            $.ajax({
                type: "POST",
                async: false,
                url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Reports/WebMethods.aspx/getReportTarget",
                data: JSON.stringify(jsondata),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) { res = msg.d; },
            });
            return res;
        }
        function getDefaultColumnReport(pt, cn) {
            var res;
            var jsondata = {
                Group: pt,
                columnName: cn
            };
            $.ajax({
                type: "POST",
                async: false,
                url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Reports/WebMethods.aspx/getDefaultColumnReport",
                data: JSON.stringify(jsondata),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) { res = msg.d; },
            });
            return res;
        }
        function getMenuXML(pt, cn) {
            var res;
            var jsondata = {
                Group: pt,
                columnName: cn
            };
            $.ajax({
                type: "POST",
                async: false,
                url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Reports/WebMethods.aspx/getMenuXML",
                data: JSON.stringify(jsondata),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) { res = msg.d; },
            });
            return res;
        }
        function getContextMenuOGD(sender, args) {
            var Report = args.get_item().get_value();
            Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, OGD.columnName, OGD.rowID);
        }
        function getContextMenuPEG(sender, args) {
            var Report = args.get_item().get_value();
            Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, PEG.columnName, PEG.rowID);
        }
        function getContextMenuERC(sender, args) {
            var Report = args.get_item().get_value();
            Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, ERC.columnName, ERC.rowID);
        }
        function getContextMenuSIG(sender, args) {
            var Report = args.get_item().get_value();
            Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, SIG.columnName, SIG.rowID);
        }
        function getContextMenuCOL(sender, args) {
            var Report = args.get_item().get_value();
            Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, COL.columnName, COL.rowID);
        }
        function getContextMenuBPS(sender, args) {
            var Report = args.get_item().get_value();
            Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, BPS.columnName, BPS.rowID);
        }
        function getContextMenuBPB(sender, args) {
            var Report = args.get_item().get_value();
            Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, BPB.columnName, BPB.rowID);
        }
        function getContextMenuCON(sender, args) {
            var Report = args.get_item().get_value();
            Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, CON.columnName, CON.rowID);
        }
        function SelectCellOGD(sender, args) {
            columnName = args.get_column().get_uniqueName();
            rowID = args.get_gridDataItem().getDataKeyValue("AnonimizedID");
            $find("<%= RadContextMenuOGD.ClientID%>").get_items().clear();
            var menuOGD = $find("<%= RadContextMenuOGD.ClientID%>");
            text = getMenuXML('OGD', columnName);
            parser = new DOMParser();
            xmlDoc = parser.parseFromString(text, "text/xml");
            var key = "OGD" + columnName;
            x = xmlDoc.documentElement.getElementsByTagName("row");
            var MenuText = "";
            var MenuValue = "";
            var MenuToolTip = "";
            for (var i = 0; i < x.length; i++) {
                MenuText = x[i].getAttribute("Text");
                MenuValue = x[i].getAttribute("Value");
                MenuToolTip = x[i].getAttribute("ToolTip");
                AddNewOGDItem(MenuText, MenuValue, MenuToolTip);
            }
            OGD.columnName = columnName;
            OGD.rowID = rowID;
            var Report = Unisoft.LoadDefaultReport('OGD', columnName, rowID);
            switch (columnName) {
                case "MeanSedationRateLT70Years_Midazolam":
                    Unisoft.PopUpWindowAD(Unisoft.WindowFileName(Report), Report, columnName, rowID, "LT70", "Midazolam");
                    break;
                case "MeanSedationRateGE70Years_Midazolam":
                    Unisoft.PopUpWindowAD(Unisoft.WindowFileName(Report), Report, columnName, rowID, "GE70", "Midazolam");
                    break;
                case "MeanAnalgesiaRateLT70Years_Pethidine":
                    Unisoft.PopUpWindowAD(Unisoft.WindowFileName(Report), Report, columnName, rowID, "LT70", "Pethidine");
                    break;
                case "MeanAnalgesiaRateGE70Years_Pethidine":
                    Unisoft.PopUpWindowAD(Unisoft.WindowFileName(Report), Report, columnName, rowID, "GE70", "Pethidine");
                    break;
                case "MeanAnalgesiaRateLT70Years_Fentanyl":
                    Unisoft.PopUpWindowAD(Unisoft.WindowFileName(Report), Report, columnName, rowID, "LT70", "Fentanyl");
                    break;
                case "MeanAnalgesiaRateGE70Years_Fentanyl":
                    Unisoft.PopUpWindowAD(Unisoft.WindowFileName(Report), Report, columnName, rowID, "GE70", "Fentanyl");
                    break;
                default:
                    Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, columnName, rowID);
                    break;
            }            
            return false;
        }
        function SelectCellPEG(sender, args) {
            columnName = args.get_column().get_uniqueName();
            rowID = args.get_gridDataItem().getDataKeyValue("AnonimizedID");
            $find("<%= RadContextMenuPEG.ClientID%>").get_items().clear();
            var menuPEG = $find("<%= RadContextMenuPEG.ClientID%>");
            var text = '' + getMenuXML('PEG', columnName);
            if (text == '') {
            } else {
                var parser = new DOMParser();
                var xmlDoc = parser.parseFromString(text, "text/xml");
                var key = "PEG" + PEG.columnName;
                var x = xmlDoc.documentElement.getElementsByTagName("row");
                var MenuText = "";
                var MenuValue = "";
                var MenuToolTip = "";
                for (var i = 0; i < x.length; i++) {
                    MenuText = x[i].getAttribute("Text");
                    MenuValue = x[i].getAttribute("Value");
                    MenuToolTip = x[i].getAttribute("ToolTip");
                    AddNewPEGItem(MenuText, MenuValue, MenuToolTip);
                }
                PEG.columnName = columnName;
                PEG.rowID = rowID;
                var Report = Unisoft.LoadDefaultReport('PEG', columnName, rowID);
                Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, columnName, rowID);
                return false;
            }
        }
        function SelectCellERC(sender, args) {
            columnName = args.get_column().get_uniqueName();
            rowID = args.get_gridDataItem().getDataKeyValue("AnonimizedID");
            $find("<%= RadContextMenuERC.ClientID%>").get_items().clear();
            var menuERC = $find("<%= RadContextMenuERC.ClientID%>");
            var text = '' + getMenuXML('ERC', columnName);
            if (text == '') {
            } else {
                var parser = new DOMParser();
                var xmlDoc = parser.parseFromString(text, "text/xml");
                var key = "ERC" + ERC.columnName;
                var x = xmlDoc.documentElement.getElementsByTagName("row");
                var MenuText = "";
                var MenuValue = "";
                var MenuToolTip = "";
                for (var i = 0; i < x.length; i++) {
                    MenuText = x[i].getAttribute("Text");
                    MenuValue = x[i].getAttribute("Value");
                    MenuToolTip = x[i].getAttribute("ToolTip");
                    AddNewERCItem(MenuText, MenuValue, MenuToolTip);
                }
            }
            ERC.columnName = columnName;
            ERC.rowID = rowID;
            var Report = Unisoft.LoadDefaultReport('ERC', columnName, rowID);
            Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, columnName, rowID);
            return false;
        }
        function SelectCellSIG(sender, args) {
            columnName = args.get_column().get_uniqueName();
            rowID = args.get_gridDataItem().getDataKeyValue("AnonimizedID");
            $find("<%= RadContextMenuSIG.ClientID%>").get_items().clear();
            var menuSIG = $find("<%= RadContextMenuSIG.ClientID%>");
            var text = '' + getMenuXML('SIG', columnName);
            if (text == '') {
            } else {
                var parser = new DOMParser();
                var xmlDoc = parser.parseFromString(text, "text/xml");
                var key = "SIG" + SIG.columnName;
                var x = xmlDoc.documentElement.getElementsByTagName("row");
                var MenuText = "";
                var MenuValue = "";
                var MenuToolTip = "";
                for (var i = 0; i < x.length; i++) {
                    MenuText = x[i].getAttribute("Text");
                    MenuValue = x[i].getAttribute("Value");
                    MenuToolTip = x[i].getAttribute("ToolTip");
                    AddNewSIGItem(MenuText, MenuValue, MenuToolTip);
                }
            }
            SIG.columnName = columnName;
            SIG.rowID = rowID;
            var Report = Unisoft.LoadDefaultReport('SIG', columnName, rowID);
            Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, columnName, rowID);
            return false;
        }
        function SelectCellCOL(sender, args) {
            columnName = args.get_column().get_uniqueName();
            rowID = args.get_gridDataItem().getDataKeyValue("AnonimizedID");
            $find("<%= RadContextMenuCOL.ClientID%>").get_items().clear();
            var menuCOL = $find("<%= RadContextMenuCOL.ClientID%>");
            var text = '' + getMenuXML('COL', columnName);
            if (text == '') {
            } else {
                var parser = new DOMParser();
                var xmlDoc = parser.parseFromString(text, "text/xml");
                var key = "COL" + COL.columnName;
                var x = xmlDoc.documentElement.getElementsByTagName("row");
                var MenuText = "";
                var MenuValue = "";
                var MenuToolTip = "";
                for (var i = 0; i < x.length; i++) {
                    MenuText = x[i].getAttribute("Text");
                    MenuValue = x[i].getAttribute("Value");
                    MenuToolTip = x[i].getAttribute("ToolTip");
                    AddNewCOLItem(MenuText, MenuValue, MenuToolTip);
                }
            }
            COL.columnName = columnName;
            COL.rowID = rowID;
            var Report = Unisoft.LoadDefaultReport('COL', columnName, rowID);
            Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, columnName, rowID);
            return false;
        }
        function SelectCellBPS(sender, args) {
            columnName = args.get_column().get_uniqueName();
            rowID = args.get_gridDataItem().getDataKeyValue("AnonimizedID");
            $find("<%= RadContextMenuBPS.ClientID%>").get_items().clear();
            var menuBPS = $find("<%= RadContextMenuBPS.ClientID%>");
            var text = '' + getMenuXML('BPS', columnName);
            if (text == '') {
            } else {
                var parser = new DOMParser();
                var xmlDoc = parser.parseFromString(text, "text/xml");
                var key = "BPS" + BPS.columnName;
                var x = xmlDoc.documentElement.getElementsByTagName("row");
                var MenuText = "";
                var MenuValue = "";
                var MenuToolTip = "";
                for (var i = 0; i < x.length; i++) {
                    MenuText = x[i].getAttribute("Text");
                    MenuValue = x[i].getAttribute("Value");
                    MenuToolTip = x[i].getAttribute("ToolTip");
                    AddNewBPSItem(MenuText, MenuValue, MenuToolTip);
                }
            }
            BPS.columnName = columnName;
            BPS.rowID = rowID;
            var Report = Unisoft.LoadDefaultReport('BPS', columnName, rowID);
            Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, columnName, rowID);
            return false;
        }
        function SelectCellBPB(sender, args) {
            columnName = args.get_column().get_uniqueName();
            rowID = args.get_gridDataItem().getDataKeyValue("AnonimizedID");
            $find("<%= RadContextMenuBPB.ClientID%>").get_items().clear();
            var menuBPB = $find("<%= RadContextMenuBPB.ClientID%>");
            var text = '' + getMenuXML('BPB', columnName);
            if (text == '') {
            } else {
                var parser = new DOMParser();
                var xmlDoc = parser.parseFromString(text, "text/xml");
                var key = "BPB" + BPB.columnName;
                var x = xmlDoc.documentElement.getElementsByTagName("row");
                var MenuText = "";
                var MenuValue = "";
                var MenuToolTip = "";
                for (var i = 0; i < x.length; i++) {
                    MenuText = x[i].getAttribute("Text");
                    MenuValue = x[i].getAttribute("Value");
                    MenuToolTip = x[i].getAttribute("ToolTip");
                    AddNewBPBItem(MenuText, MenuValue, MenuToolTip);
                }
            }
            BPB.columnName = columnName;
            BPB.rowID = rowID;
            var Report = Unisoft.LoadDefaultReport('BPB', columnName, rowID);
            Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, columnName, rowID);
            return false;
        }
        function SelectCellCON(sender, args) {
            columnName = args.get_column().get_uniqueName();
            rowID = args.get_gridDataItem().getDataKeyValue("AnonimizedID");
            $find("<%= RadContextMenuCON.ClientID%>").get_items().clear();
            var menuCON = $find("<%= RadContextMenuCON.ClientID%>");
            var text = '' + getMenuXML('CON', columnName);
            if (text == '') {
            } else {
                var parser = new DOMParser();
                var xmlDoc = parser.parseFromString(text, "text/xml");
                var key = "CON" + CON.columnName;
                var x = xmlDoc.documentElement.getElementsByTagName("row");
                var MenuText = "";
                var MenuValue = "";
                var MenuToolTip = "";
                for (var i = 0; i < x.length; i++) {
                    MenuText = x[i].getAttribute("Text");
                    MenuValue = x[i].getAttribute("Value");
                    MenuToolTip = x[i].getAttribute("ToolTip");
                    AddNewCONItem(MenuText, MenuValue, MenuToolTip);
                }
            }
            CON.columnName = columnName;
            CON.rowID = rowID;
            var Report = Unisoft.LoadDefaultReport('CON', columnName, rowID);
            Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, columnName, rowID);
            return false;
        }

        function AddNewOGDItem(Text, Value, ToolTip) {
            var menuOGD = $find("<%=RadContextMenuOGD.ClientID%>");
            var menuItem = new Telerik.Web.UI.RadMenuItem();
            menuItem.get_value.Value = Value;
            menuItem.ToolTip = ToolTip;
            menuItem.set_text(Text);
            menuItem.set_value(Value);
            menuOGD.trackChanges();
            menuOGD.get_items().add(menuItem);
            menuOGD.commitChanges();
        }
        function AddNewPEGItem(Text, Value, ToolTip) {
            var menuPEG = $find("<%=RadContextMenuPEG.ClientID%>");
            var menuItem = new Telerik.Web.UI.RadMenuItem();
            menuItem.get_value.Value = Value;
            menuItem.ToolTip = ToolTip;
            menuItem.set_text(Text);
            menuItem.set_value(Value);
            menuPEG.trackChanges();
            menuPEG.get_items().add(menuItem);
            menuPEG.commitChanges();
        }
        function AddNewERCItem(Text, Value, ToolTip) {
            var menuERC = $find("<%=RadContextMenuERC.ClientID%>");
            var menuItem = new Telerik.Web.UI.RadMenuItem();
            menuItem.get_value.Value = Value;
            menuItem.ToolTip = ToolTip;
            menuItem.set_text(Text);
            menuItem.set_value(Value);
            menuERC.trackChanges();
            menuERC.get_items().add(menuItem);
            menuERC.commitChanges();
        }
        function AddNewSIGItem(Text, Value, ToolTip) {
            var menuSIG = $find("<%=RadContextMenuSIG.ClientID%>");
            var menuItem = new Telerik.Web.UI.RadMenuItem();
            menuItem.get_value.Value = Value;
            menuItem.ToolTip = ToolTip;
            menuItem.set_text(Text);
            menuItem.set_value(Value);
            menuSIG.trackChanges();
            menuSIG.get_items().add(menuItem);
            menuSIG.commitChanges();
        }
        function AddNewCOLItem(Text, Value, ToolTip) {
            var menuCOL = $find("<%=RadContextMenuCOL.ClientID%>");
            var menuItem = new Telerik.Web.UI.RadMenuItem();
            menuItem.get_value.Value = Value;
            menuItem.ToolTip = ToolTip;
            menuItem.set_text(Text);
            menuItem.set_value(Value);
            menuCOL.trackChanges();
            menuCOL.get_items().add(menuItem);
            menuCOL.commitChanges();
        }
        function AddNewBPSItem(Text, Value, ToolTip) {
            var menuBPS = $find("<%=RadContextMenuBPS.ClientID%>");
            var menuItem = new Telerik.Web.UI.RadMenuItem();
            menuItem.get_value.Value = Value;
            menuItem.ToolTip = ToolTip;
            menuItem.set_text(Text);
            menuItem.set_value(Value);
            menuBPS.trackChanges();
            menuBPS.get_items().add(menuItem);
            menuBPS.commitChanges();
        }
        function AddNewBPBItem(Text, Value, ToolTip) {
            var menuBPB = $find("<%=RadContextMenuBPB.ClientID%>");
            var menuItem = new Telerik.Web.UI.RadMenuItem();
            menuItem.get_value.Value = Value;
            menuItem.ToolTip = ToolTip;
            menuItem.set_text(Text);
            menuItem.set_value(Value);
            menuBPB.trackChanges();
            menuBPB.get_items().add(menuItem);
            menuBPB.commitChanges();
        }
        function AddNewCONItem(Text, Value, ToolTip) {
            var menuCON = $find("<%=RadContextMenuCON.ClientID%>");
            var menuItem = new Telerik.Web.UI.RadMenuItem();
            menuItem.get_value.Value = Value;
            menuItem.ToolTip = ToolTip;
            menuItem.set_text(Text);
            menuItem.set_value(Value);
            menuCON.trackChanges();
            menuCON.get_items().add(menuItem);
            menuCON.commitChanges();
        }        
        function ValidatingDates(sender, args) {
            var validated = Page_ClientValidate('FilterGroup');
            if (!validated) return;
        }
        $(document).ready(function () {
            $("#AllOf").hide();
            $("#Since_wrapper").hide();
            $("#lbFor").hide();
            $("#n").hide();
            $("#DWMQY").hide();
            if ($("#cbReports_5").prop('checked')) {
                $("#RadioBowel").show();
            }
            else {
                $("#RadioBowel").hide();
            }
            $("#selectAll").change(function () {
                $("#EndoList :checkbox").prop('checked', $(this).prop("checked"));
            });
            $("#ISMFilter").keyup(function () {
                var item;
                var search;
                search = $(this).val(); //get textBox value
                var availableUserList = $find("<%=RadListBox1.ClientID%>"); //Get RadList
                if (search.length > 0) {
                    for (var i = 0; i < availableUserList._children.get_count() ; i++) {
                        if (availableUserList.getItem(i).get_text().toLowerCase().match(search.toLowerCase())) {
                            availableUserList.getItem(i).select();
                        }
                        else {
                            availableUserList.getItem(i).unselect();
                        }
                    }
                }
                else {
                    availableUserList.clearSelection();
                    availableUserList.selectedIndex = -1;
                }
            });
            $.extend($.expr[":"],
            {
                "contains-ci": function (elem, i, match, array) {
                    return (elem.TextContent || elem.innerText || $(elem).text() || "").toLowerCase().indexOf((match[3] || "").toLowerCase()) >= 0;
                }
            });
            //$("#cbHideSuppressed").change(function () {
            //    if ($("#cbHideSuppressed").is(":checked")) {
            //        $("#EndoList .ONFalse").find(":checkbox").prop('checked', false);
            //        $("#EndoList .ONFalse").hide();
            //    }
            //    else {
            //        $("#EndoList .ONFalse").show();
            //    }
            //});
            $("#TypeOfConsultant_0").change(function () {
                $("#EndoList .USNcb").show();
                $("#EndoList .USNcb").find(":checkbox").prop('checked', false);
            });
            $("#TypeOfConsultant_1").change(function () {
                $("#EndoList .E1True").show();
                $("#EndoList .E1False").find(":checkbox").prop('checked', false);
                $("#EndoList .E1False").hide();
            });
            $("#TypeOfConsultant_2").change(function () {
                $("#EndoList .E2True").show();
                $("#EndoList .E2False").find(":checkbox").prop('checked', false);
                $("#EndoList .E2False").hide();
            });
            $("#TypeOfConsultant_3").change(function () {
                $("#EndoList .LCTrue").show();
                $("#EndoList .LCFalse").find(":checkbox").prop('checked', false);
                $("#EndoList .LCFalse").hide();
            });
            $("#TypeOfConsultant_4").change(function () {
                $("#EndoList .ASTrue").show();
                $("#EndoList .ASFalse").find(":checkbox").prop('checked', false);
                $("#EndoList .ASFalse").hide();
            });
            $("#TypeOfConsultant_5").change(function () {
                $("#EndoList .N1True").show();
                $("#EndoList .N1False").find(":checkbox").prop('checked', false);
                $("#EndoList .N1False").hide();
            });
            $("#TypeOfConsultant_6").change(function () {
                $("#EndoList .N2True").show();
                $("#EndoList .N2False").find(":checkbox").prop('checked', false);
                $("#EndoList .N2False").hide();
            });
            $("#TypeOfPeriod_0").change(function () {
                $("#AllOf").hide();
                $("#Since_wrapper").hide();
                $("#lbFor").hide();
                $("#n").hide();
                $("#DWMQY").hide();
            });
            $("#TypeOfPeriod_1").change(function () {
                $("#AllOf").show();
                $("#Since_wrapper").show();
                $("#lbFor").hide();
                $("#n").hide();
                $("#DWMQY").hide();
            });
            $("#TypeOfPeriod_2").change(function () {
                $("#AllOf").hide();
                $("#Since_wrapper").show();
                $("#lbFor").hide();
                $("#n").hide();
                $("#DWMQY").hide();
            });
            $("#TypeOfPeriod_3").change(function () {
                $("#AllOf").hide();
                $("#Since_wrapper").show();
                $("#lbFor").show();
                $("#n").show();
                $("#DWMQY").show();
            });
            $("#TypeOfPeriod_4").change(function () {
                $("#AllOf").hide();
                $("#Since_wrapper").hide();
                $("#lbFor").hide();
                $("#n").show();
                $("#DWMQY").show();
            });
            $("#cbReports_5").change(function () {
                if ($(this).prop('checked')) {
                    $("#RadioBowel").show();
                }
                else {
                    $("#RadioBowel").hide();
                }
            });
            $("#form1").fadeIn("slow");
            $("#RadButtonFilter").click(function () {
                //$("form").fadeOut("slow");
            })
            $("#RadContextMenuOGD");
            $("#RadContextMenuPEG");
            $("#RadContextMenuERC");
            $("#RadContextMenuSIG");
            $("#RadContextMenuCOL");
            $("#RadContextMenuBPS");
            $("#RadContextMenuBPB");
            $("#RadContextMenuCON");
            $("#cbHideSuppressed").change(function () {
                formChange();
            });
            $("#ComboConsultants_Input").change(function () {
                formChange();
            });
        });
        //$("#form1").fadeOut("slow");
        function formChange() {
            $("#ISMFilter").val("");
            ct = $("#ComboConsultants_Input").val();
            var cb = document.getElementById("<%=cbHideSuppressed.ClientID%>").checked;
            var hs = "";
            if (cb === true) {
                hs = "1";
            } else {
                hs = "0";
            }
            var listbox1 = $find("<%=RadListBox1.ClientID%>");
            var item1 = new Telerik.Web.UI.RadListBoxItem();
            var ItemsNo1 = listbox1.get_items().get_count();
            var usr = document.getElementById("<%=SUID.ClientID%>").getAttribute("value");
            var text = getConsultants("1", ct, "1", usr);
            var parser = new DOMParser();
            var xmlDoc = parser.parseFromString(text, "text/xml");
            x = xmlDoc.documentElement.getElementsByTagName("row");
            var Consultant = "";
            var ReportID = "";
            listbox1.get_items().clear();
            for (var i = 0; i < x.length; i++) {
                Consultant = x[i].getAttribute("Consultant");
                ReportID = x[i].getAttribute("ReportID");
                var item1 = new Telerik.Web.UI.RadListBoxItem();
                item1.set_text(Consultant);
                item1.set_value(ReportID);
                listbox1.get_items().add(item1);
            }
            var listbox2 = $find("<%=RadListBox2.ClientID%>");
            var item2 = new Telerik.Web.UI.RadListBoxItem();
            var ItemsNo2 = listbox2.get_items().get_count();
            listbox2.get_items().clear();
        }
        function getConsultants(lb, ct, hs, usr) {
            var docURL = document.URL;
            var res;
            var jsondata = {
                listboxNo: lb,
                ConsultantType: ct,
                HideSuppressed: hs,
                UserID: usr
            };
            $.ajax({
                type: "POST",
                async: false,
                url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Reports/WebMethods.aspx/getConsultants",
                data: JSON.stringify(jsondata),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    console.log(msg.d);
                    res = msg.d;
                },
                error: function (request, status, error) {
                    console.log(request.responseText);
                }
            });
            return res;
        }
    </script>
    </telerik:RadScriptBlock>
</head>
<body class="loader">
    <form id="form1" runat="server">
    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" >
    </telerik:RadAjaxLoadingPanel>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server">
        </telerik:RadStyleSheetManager>
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="ContentDiv">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadTabStrip1" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadTabStrip2" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadGridGastroscopy" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadGridPEGPEJ" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadGridERCP" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadGridColonoscopy" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadGridSigmoidoscopy" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadGridEndoscopists" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadPageView1" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadPageView2" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="Panel1" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
        <telerik:RadScriptManager ID="RadScriptManager1" Runat="server">
        </telerik:RadScriptManager>
        <telerik:RadSkinManager ID="RadSkinManager1" runat="server" Skin="Web20"/>
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <div id="ContentDiv">
        <div class="otherDataHeading">
            JAG/GRS Report
        </div>
        <asp:Panel ID="Panel1" runat="server" Height="380px" CssClass="background1">
        <div class="optionsBodyText">
            <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" SelectedIndex="0" Skin="WebBlue" EnableTheming="True" >
                <Tabs>
                    <telerik:RadTab runat="server" Text="Filter" Selected="True">
                    </telerik:RadTab>
                    <telerik:RadTab runat="server" Enabled="false" Selected="false" Text="Preview">
                    </telerik:RadTab>
                </Tabs>
            </telerik:RadTabStrip>
            <div id="ButtonExport">
                <telerik:RadButton ID="RadButtonExportGrids" runat="server" Text="Export Grids to Excel" Enabled="False" Skin="Web20" Visible="false" >
                </telerik:RadButton>
            </div>
            <telerik:RadMultiPage ID="RadMultiPage1" Runat="server" SelectedIndex="0">
                <telerik:RadPageView ID="RadPageView1" runat="server" SkinID="">
                    <asp:Panel ID="FilterPanel" runat="server">
                        <div class="multiPageDivTab">
                        <fieldset>
                            <legend>Consultant</legend>
                            <table id="FilterConsultant" class="checkboxesTable">
                                <tr>
                                    <td style="min-width:145px;text-align:left;"><asp:Label ID="Label1" runat="server" Text="Type word(s) to filter on: "></asp:Label></td>
                                    <td><input id="ISMFilter" type="text" placeholder="Consultant name" /></td>
                                    <td style="text-align:right;min-width:100px;"><asp:Label ID="Label2" runat="server" Text="Consultants type: "></asp:Label></td>
                                    <td  style="text-align:right;">
                                        <telerik:RadComboBox ID="ComboConsultants" runat="server" AutoPostBack="false" Skin="Windows7">
                                            <Items>
                                                <telerik:RadComboBoxItem runat="server" Text="All" Value="AllConsultants" />
                                                <telerik:RadComboBoxItem runat="server" Text="Endoscopist 1" Value="Endoscopist1" />
                                                <telerik:RadComboBoxItem runat="server" Text="Endoscopist 2" Value="Endoscopist2" />
                                                <telerik:RadComboBoxItem runat="server" Text="List Consultant" Value="ListConsultant" />
                                                <telerik:RadComboBoxItem runat="server" Text="Assistants or trainees" Value="Assistant" />
                                                <telerik:RadComboBoxItem runat="server" Text="Nurse 1" Value="Nurse1" />
                                                <telerik:RadComboBoxItem runat="server" Text="Nurse 2" Value="Nurse2" />
                                            </Items>
                                        </telerik:RadComboBox>
                                    </td>
                                </tr>
                            </table>
                            <telerik:RadAjaxPanel ID="RadAjaxPanel2" runat="server" height="200px" width="700px">
                                <div id="Consultants">
                                    <div class="lb">
                                        <telerik:RadListBox ID="RadListBox1" runat="server" Width="287px" Height="200px"
                                    SelectionMode="Multiple" AllowTransfer="True" TransferToID="RadListBox2" EnableDragAndDrop="True" DataSourceID="SqlDSAllConsultants" DataKeyField="ReportID" DataTextField="Consultant" DataValueField="ReportID" ButtonSettings-VerticalAlign="Middle" >
                                        </telerik:RadListBox>
                                    </div>
                                    <div class="lb">
                                        <telerik:RadListBox ID="RadListBox2" runat="server" Width="287px" Height="200px"
                                    SelectionMode="Multiple" AutoPostBackOnReorder="False" EnableDragAndDrop="True" 
                                    DataKeyField="ReportID" DataTextField="Consultant" DataValueField="ReportID" DataSourceID="SqlDSSelectedConsultants" >
                                        </telerik:RadListBox>
                                    </div>
                                </div>
                            </telerik:RadAjaxPanel>
                            <div id="Together">
                                <b><asp:Label ID="lTogether" runat="server" Text="Together with these criteria"></asp:Label></b><br />
                                <asp:CheckBox ID="cbHideSuppressed" runat="server" Text="Hide suppressed endoscopists" Skin="Windows7" cssClass="mutuallyexclusive" />
                                <asp:CheckBox ID="cbRandomize" runat="server" Text="Randomize and anonymise endoscopists position in report" Skin="Windows7" CssClass="mutuallyexclusive" /><br />
                            </div>
                        </fieldset>
                        <asp:ObjectDataSource ID="SqlDSAllConsultants" runat="server" SelectMethod="GetSqlDSAllConsultants" TypeName="UnisoftERS.Reports">
                            <SelectParameters>
                                  <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="SqlDSSelectedConsultants" runat="server" SelectMethod="GetSqlDSSelectedConsultants" TypeName="UnisoftERS.Reports">
                            <SelectParameters>
                                  <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <fieldset>
                            <legend><b>Dates</b></legend>
                            <table class="checkboxesTable">
                                <tr>
                                    <td>From: 
                                        <telerik:RadDatePicker ID="RDPFrom" Runat="server" Culture="en-GB" SkinID="RadSkinManager1" ToolTip="First date to be used in the report" Skin="Bootstrap" >
                                        <Calendar EnableWeekends="True" FastNavigationNextText="&amp;lt;&amp;lt;" UseColumnHeadersAsSelectors="False" UseRowHeadersAsSelectors="False" runat="server" Culture="en-GB" >
                                        </Calendar>
                                        <DateInput runat="server" DateFormat="dd/MM/yyyy" DisplayDateFormat="dd/MM/yyyy" LabelWidth="40%" value="" ValidationGroup="FilterGroup">
                                        <EmptyMessageStyle Resize="None" />
                                        <ReadOnlyStyle Resize="None" />
                                        <FocusedStyle Resize="None" />
                                        <DisabledStyle Resize="None" />
                                        <InvalidStyle Resize="None" />
                                        <HoveredStyle Resize="None" />
                                        <EnabledStyle Resize="None" />
                                        </DateInput>
                                        </telerik:RadDatePicker>
                                    </td>
                                <td style="text-align:right;">To <telerik:RadDatePicker ID="RDPTo" Runat="server" Culture="en-GB" SkinID="RadSkinManager1" Skin="Bootstrap">
                                    <Calendar EnableWeekends="True" FastNavigationNextText="&amp;lt;&amp;lt;" UseColumnHeadersAsSelectors="False" UseRowHeadersAsSelectors="False" runat="server" SkinID="RadSkinManager1" Culture="en-GB">
                                    </Calendar>
                                    <DateInput DateFormat="dd/MM/yyyy" DisplayDateFormat="dd/MM/yyyy" LabelWidth="40%" runat="server" ValidationGroup="FilterGroup">
                                    <EmptyMessageStyle Resize="None" />
                                    <ReadOnlyStyle Resize="None" />
                                    <FocusedStyle Resize="None" />
                                    <DisabledStyle Resize="None" />
                                    <InvalidStyle Resize="None" />
                                    <HoveredStyle Resize="None" />
                                    <EnabledStyle Resize="None" />
                                    </DateInput>
                                    <DatePopupButton/>
                                    </telerik:RadDatePicker>
                                </td>
                                </tr>
                            </table>
                            <asp:TextBox runat="server" ID="SUID" CssClass="secret"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidatorFromDate" ControlToValidate="RDPFrom" ErrorMessage="Enter a date!" SetFocusOnError="True" ValidationGroup="FilterGroup"></asp:RequiredFieldValidator>
                            <asp:RequiredFieldValidator runat="server" ID="RequiredfieldvalidatorToDate" ControlToValidate="RDPTo" ErrorMessage="Enter a date!" ValidationGroup="FilterGroup"></asp:RequiredFieldValidator>
                            <asp:CompareValidator ID="dateCompareValidator" runat="server" ControlToValidate="RDPTo" ControlToCompare="RDPFrom" Operator="GreaterThan" ValidationGroup="FilterGroup" Type="Date" ErrorMessage="The second date must be after the first one." SetFocusOnError="True"></asp:CompareValidator>
                        </fieldset>
                        <fieldset>
                            <legend><b>Summary reports</b></legend>
                            <table class="checkboxesTable">
                                <tr>
                                    <td style="min-width:250px;">
                                        <div id="EndoList">
                                            <asp:CheckBoxList ID="cbReports" runat="server" RepeatColumns="3" Skin="Windows7" CssClass="mutuallyexclusive" >
                                                <asp:ListItem Selected="True" Value="OGD">OGD</asp:ListItem>
                                                <asp:ListItem Selected="True" Value="PEGPEJ">PEG/PEJ</asp:ListItem>
                                                <asp:ListItem Selected="True" Value="ERCP">ERCP</asp:ListItem>
                                                <asp:ListItem Selected="True" Value="Sigmoidoscopy">Sigmoidoscopy</asp:ListItem>
                                                <asp:ListItem Selected="True" Value="Colonoscopy">Colonoscopy</asp:ListItem>
                                                <asp:ListItem Selected="True" Value="Bowel">Bowel preparation</asp:ListItem>
                                            </asp:CheckBoxList>
                                        </div>
                                    </td>
                                    <td style="min-width:100px;">
                                        <asp:RadioButtonList ID="RadioBowel" runat="server" RepeatDirection="Vertical">
                                            <asp:ListItem Selected="True" Value="Standard">Standard bowel prep. scale</asp:ListItem>
                                            <asp:ListItem Value="Period">Boston bowel prep. scale</asp:ListItem>
                                        </asp:RadioButtonList>
                                    </td>
                                    <td>
                                        <div id="ApplyZone">
                                            <telerik:RadButton ID="RadButtonFilter" runat="server" Text="Apply filter" Skin="Web20" ValidationGroup="FilterGroup" OnClientClicking="ValidatingDates" ButtonType="SkinnedButton" SkinID="RadSkinManager1" ></telerik:RadButton>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                        </div>
                    </asp:Panel>
                </telerik:RadPageView>
                <telerik:RadPageView ID="RadPageView2" runat="server">
                    <br />
                    <telerik:RadTabStrip ID="RadTabStrip2" runat="server" MultiPageID="RadMultiPage2" SelectedIndex="0" Skin="WebBlue" >
                        <Tabs>
                            <telerik:RadTab runat="server" Text="Gastroscopy" Selected="True">
                            </telerik:RadTab>
                            <telerik:RadTab runat="server" Text="PEG-PEJ">
                            </telerik:RadTab>
                            <telerik:RadTab runat="server" Text="ERCP">
                            </telerik:RadTab>
                            <telerik:RadTab runat="server" Text="Sigmoidoscopy">
                            </telerik:RadTab>
                            <telerik:RadTab runat="server" Text="Colonoscopy">
                            </telerik:RadTab>
                            <telerik:RadTab runat="server" Text="Standard Bowel preparation">
                            </telerik:RadTab>
                            <telerik:RadTab runat="server" Text="Boston Bowel preparation">
                            </telerik:RadTab>
                            <telerik:RadTab runat="server" Text="Endoscopists">
                            </telerik:RadTab>
                        </Tabs>
                    </telerik:RadTabStrip>
                    <telerik:RadMultiPage ID="RadMultiPage2" Runat="server" SelectedIndex="0">
                        <telerik:RadPageView ID="RadPageGastroscopy" runat="server" Width="100%">
                            <div class="TextContainer qsf-ib">
                                <h1>JAG/GRS Report: Gastroscopy results</h1>
<%--                                <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanelGastroscopy" runat="server" MinDisplayTime="5" Transparency="50" HorizontalAlign="Center">
                                </telerik:RadAjaxLoadingPanel>--%>
                                <!--Ojo-->
                                <telerik:RadContextMenu ID="RadContextMenuOGD" runat="server" OnClientItemClicked="getContextMenuOGD">
                                    <Targets>
                                        <telerik:ContextMenuControlTarget ControlID="RadGridGastroscopy" />
                                        <telerik:ContextMenuElementTarget ElementID="" />
                                    </Targets>
                                    <Items>
                                    </Items>
                                </telerik:RadContextMenu>
                                <asp:ObjectDataSource ID="DSGastroscopy" runat="server" SelectMethod="GetOGDQry" TypeName="UnisoftERS.Reports">
                                    <SelectParameters>
                                          <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                    </SelectParameters>
                                </asp:ObjectDataSource>
                                <telerik:RadGrid ID="RadGridGastroscopy" runat="server" AllowPaging="True" Skin="Office2007" AutoGenerateColumns="False" GroupPanelPosition="Top" PagerStyle-AlwaysVisible="true">
                                    <GroupingSettings />
                                    <ClientSettings>
                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                        <Selecting EnableDragToSelectRows="True" CellSelectionMode="SingleCell"></Selecting>
                                        <ClientEvents OnCellSelected="SelectCellOGD" ></ClientEvents>
                                    </ClientSettings>
                                    <MasterTableView DataKeyNames="Endoscopist1" ClientDataKeyNames="AnonimizedID">
                                        <Columns>
                                            <telerik:GridBoundColumn DataField="Endoscopist1" DataType="System.String" FilterControlAltText="Filter Endoscopist1 column" HeaderText="Endoscopist Number" ReadOnly="True" SortExpression="Endoscopist1" UniqueName="EndoscopistID"   >
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="AnonimizedID" Display="false" DataType="System.String" FilterControlAltText="Filter Endoscopist1 column" HeaderText="Endoscopist Number" ReadOnly="True" SortExpression="AnonimizedID" UniqueName="AnonimizedID" >
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee" FilterControlAltText="Filter IndependentDirectlySupervisedTraineeDistantSupervisionTrainee column" HeaderText="Independent Directly Supervised/Trainee Distant Supervision Trainee" ReadOnly="True" SortExpression="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee" UniqueName="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee">
                                                <HeaderStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="NumberOfProcedures" DataType="System.Int32" FilterControlAltText="Filter NumberOfProcedures column" HeaderText="Number Of Procedures" ReadOnly="True" SortExpression="NumberOfProcedures" UniqueName="NumberOfProcedures">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle BorderStyle="Solid" HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanSedationRateLT70Years_Midazolam" DataType="System.Double" FilterControlAltText="Filter MeanSedationRateLT70Years_Midazolam column" HeaderText="Mean Sedation Rate &lt; 70 Years (Midazolam)" ReadOnly="True" SortExpression="MeanSedationRateLT70Years_Midazolam" UniqueName="MeanSedationRateLT70Years_Midazolam">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanSedationRateGE70Years_Midazolam" DataType="System.Double" FilterControlAltText="Filter MeanSedationRateGE70Years_Midazolam column" HeaderText="Mean Sedation Rate ≥ 70 Years (Midazolam)" ReadOnly="True" SortExpression="MeanSedationRateGE70Years_Midazolam" UniqueName="MeanSedationRateGE70Years_Midazolam">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanAnalgesiaRateLT70Years_Pethidine" DataType="System.Double" FilterControlAltText="Filter MeanAnalgesiaRateLT70Years_Pethidine column" HeaderText="Mean Analgesia Rate &lt; 70 Years (Pethidine)" ReadOnly="True" SortExpression="MeanAnalgesiaRateLT70Years_Pethidine" UniqueName="MeanAnalgesiaRateLT70Years_Pethidine">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanAnalgesiaRateGE70Years_Pethidine" DataType="System.Double" FilterControlAltText="Filter MeanAnalgesiaRateGE70Years_Pethidine column" HeaderText="Mean Analgesia Rate ≥ 70 Years (Pethidine)" ReadOnly="True" SortExpression="MeanAnalgesiaRateGE70Years_Pethidine" UniqueName="MeanAnalgesiaRateGE70Years_Pethidine">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanAnalgesiaRateLT70Years_Fentanyl" DataType="System.Double" FilterControlAltText="Filter MeanAnalgesiaRateLT70Years_Fentanyl column" HeaderText="Mean Analgesia Rate &lt; 70 Years (Fentanyl)" ReadOnly="True" SortExpression="MeanAnalgesiaRateLT70Years_Fentanyl" UniqueName="MeanAnalgesiaRateLT70Years_Fentanyl">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanAnalgesiaRateGE70Years_Fentanyl" DataType="System.Double" FilterControlAltText="Filter MeanAnalgesiaRateGE70Years_Fentanyl column" HeaderText="Mean Analgesia Rate ≥ 70Years (Fentanyl)" ReadOnly="True" SortExpression="MeanAnalgesiaRateGE70Years_Fentanyl" UniqueName="MeanAnalgesiaRateGE70Years_Fentanyl">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN" FilterControlAltText="Filter ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN column" HeaderText="Concerns Regarding High Doses Of Sedation Or Analgesia (Y/N)" ReadOnly="True" SortExpression="ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN" UniqueName="ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="ComfortScoreGT4P" DataFormatString="{0:N2}" DataType="System.Decimal" FilterControlAltText="Filter ComfortScoreGT4P column" HeaderText="Comfort Score &gt; 4%" ReadOnly="True" SortExpression="Comfort Score&gt; 4%" UniqueName="ComfortScoreGT4P">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="SuccesfullProcedureCompletionP" DataFormatString="{0:N2}" DataType="System.Decimal" FilterControlAltText="Filter SuccesfullProcedureCompletionP column" HeaderText="Succesfull Procedure Completion %" ReadOnly="True" SortExpression="SuccesfullProcedureCompletionP" UniqueName="SuccesfullProcedureCompletionP">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="FailedProcedureCompletionP" DataFormatString="{0:N2}" DataType="System.Decimal" FilterControlAltText="Filter FailedProcedureCompletionP column" HeaderText="Failed Procedure Completion %" ReadOnly="True" SortExpression="FailedProcedureCompletionP" UniqueName="FailedProcedureCompletionP">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Repeat12Weeks" DataType="System.Int32" FilterControlAltText="Filter Repeat12Weeks column" HeaderText="Repeat procedures for gastric ulcers within 12 wks" ReadOnly="True" SortExpression="Repeat12Weeks" UniqueName="Repeat12Weeks">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Comments_ActionTaken" FilterControlAltText="Filter Comments_ActionTaken column" HeaderText="Comments Action Taken" ReadOnly="True" SortExpression="Comments_ActionTaken" UniqueName="Comments_ActionTaken">
                                            </telerik:GridBoundColumn>
                                        </Columns>
                                    </MasterTableView>
                                </telerik:RadGrid>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="RadPagePEGPEJ" runat="server">
                            <div class="TextContainer qsf-ib">
                                <h1>JAG/GRS Report: PEG/PEJ results</h1>
                                <telerik:RadContextMenu ID="RadContextMenuPEG" runat="server" OnClientItemClicked="getContextMenuPEG">
                                    <Targets>
                                        <telerik:ContextMenuControlTarget ControlID="RadGridPEGPEJ" />
                                        <telerik:ContextMenuElementTarget ElementID="" />
                                    </Targets>
                                    <Items>
                                    </Items>
                                </telerik:RadContextMenu>
                                <asp:ObjectDataSource ID="DSPEGPEJ" runat="server" SelectMethod="GetPEGQry" TypeName="UnisoftERS.Reports">
                                    <SelectParameters>
                                          <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                    </SelectParameters>
                                </asp:ObjectDataSource>
                                <telerik:RadGrid ID="RadGridPEGPEJ" runat="server" Skin="Office2007" GroupPanelPosition="Top" AllowPaging="True" AutoGenerateColumns="False" PagerStyle-AlwaysVisible="true">
                                    <ClientSettings>
                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                        <Selecting  CellSelectionMode="SingleCell" EnableDragToSelectRows="True"></Selecting>
                                        <ClientEvents OnCellSelected="SelectCellPEG" ></ClientEvents>
                                    </ClientSettings>
                                    <MasterTableView DataKeyNames="Endoscopist1" ClientDataKeyNames="AnonimizedID">
                                        <Columns>
                                            <telerik:GridBoundColumn DataField="AnonimizedID" Display="false" DataType="System.String" FilterControlAltText="Filter Endoscopist1 column" HeaderText="Endoscopist Number" ReadOnly="True" SortExpression="AnonimizedID" UniqueName="AnonimizedID" >
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Endoscopist1" DataType="System.String" FilterControlAltText="Filter Endoscopist1 column" HeaderText="Endoscopist Number" ReadOnly="True" SortExpression="Endoscopist1" UniqueName="EndoscopistID" >
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee" FilterControlAltText="Filter IndependentDirectlySupervisedTraineeDistantSupervisionTrainee column" HeaderText="Independent Directly Supervised Trainee/Distant Supervision Trainee" ReadOnly="True" SortExpression="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee" UniqueName="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Number_of_PEG_PEJ_procedures" DataType="System.Int32" FilterControlAltText="Filter Number_of_PEG_PEJ_procedures column" HeaderText="Number of PEG/PEJ procedures" ReadOnly="True" SortExpression="Number_of_PEG_PEJ_procedures" UniqueName="Number_of_PEG_PEJ_procedures">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Satisfactory_placement_of_PEG_PEJ" DataType="System.Decimal" FilterControlAltText="Filter Satisfactory_placement_of_PEG_PEJ column" HeaderText="Satisfactory placement of PEG/PEJ" ReadOnly="True" SortExpression="Satisfactory_placement_of_PEG_PEJ" UniqueName="Satisfactory_placement_of_PEG_PEJ">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Failed_PEG_PEJ_placement" DataType="System.Decimal" FilterControlAltText="Filter Failed_PEG_PEJ_placement column" HeaderText="Failed PEG/PEJ placement" ReadOnly="True" SortExpression="Failed_PEG_PEJ_placement" UniqueName="Failed_PEG_PEJ_placement">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Comments_ActionTaken" FilterControlAltText="Filter Comments_ActionTaken column" HeaderText="Comments Action Taken" ReadOnly="True" SortExpression="Comments_ActionTaken" UniqueName="Comments_ActionTaken">
                                                <HeaderStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                        </Columns>
                                    </MasterTableView>
                                </telerik:RadGrid>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="RadPageERCP" runat="server">
                            <div class="TextContainer qsf-ib">
                                <h1>JAG/GRS Report: ERCP results</h1>
                                <telerik:RadContextMenu ID="RadContextMenuERC" runat="server" OnClientItemClicked="getContextMenuERC">
                                    <Targets>
                                        <telerik:ContextMenuControlTarget ControlID="RadGridERCP" />
                                        <telerik:ContextMenuElementTarget ElementID="" />
                                    </Targets>
                                    <Items>
                                    </Items>
                                </telerik:RadContextMenu>
                                <asp:ObjectDataSource ID="DSERCP" runat="server" SelectMethod="GetERCQry" TypeName="UnisoftERS.Reports">
                                    <SelectParameters>
                                          <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                    </SelectParameters>
                                </asp:ObjectDataSource>

                                <telerik:RadGrid ID="RadGridERCP" runat="server" AllowPaging="True" Skin="Office2007" GroupPanelPosition="Top" AutoGenerateColumns="False" CellSpacing="-1" PagerStyle-AlwaysVisible="true">
                                    <ClientSettings>
                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                        <Selecting  CellSelectionMode="SingleCell" EnableDragToSelectRows="True"></Selecting>
                                        <ClientEvents OnCellSelected="SelectCellERC" ></ClientEvents>
                                    </ClientSettings>
                                    <MasterTableView DataKeyNames="Endoscopist1">
                                        <Columns>
                                            <telerik:GridBoundColumn DataField="Endoscopist1" DataType="System.Int32" FilterControlAltText="Filter Endoscopist1 column" HeaderText="Endoscopist" ReadOnly="True" SortExpression="Endoscopist1" UniqueName="Endoscopist1">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee" FilterControlAltText="Filter IndependentDirectlySupervisedTraineeDistantSupervisionTrainee column" HeaderText="Independent Directly Supervised Trainee/Distant Supervision Trainee" ReadOnly="True" SortExpression="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee" UniqueName="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="NumberOfProcedures" DataType="System.Int32" FilterControlAltText="Filter NumberOfProcedures column" HeaderText="Number Of Procedures" ReadOnly="True" SortExpression="NumberOfProcedures" UniqueName="NumberOfProcedures">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanSedationRateLT70Years_Midazolam" DataType="System.Double" FilterControlAltText="Filter MeanSedationRateLT70Years_Midazolam column" HeaderText="Mean Sedation Rate&lt; 70 Years (Midazolam)" ReadOnly="True" SortExpression="MeanSedationRateLT70Years_Midazolam" UniqueName="MeanSedationRateLT70Years_Midazolam">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanSedationRateGE70Years_Midazolam" DataType="System.Double" FilterControlAltText="Filter MeanSedationRateGE70Years_Midazolam column" HeaderText="Mean Sedation Rate ≥ 70 Years (Midazolam)" ReadOnly="True" SortExpression="MeanSedationRateGE70Years_Midazolam" UniqueName="MeanSedationRateGE70Years_Midazolam">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanAnalgesiaRateLT70Years_Pethidine" DataType="System.Double" FilterControlAltText="Filter MeanAnalgesiaRateLT70Years_Pethidine column" HeaderText="Mean Analgesia Rate &lt; 70 Years (Pethidine)" ReadOnly="True" SortExpression="MeanAnalgesiaRateLT70Years_Pethidine" UniqueName="MeanAnalgesiaRateLT70Years_Pethidine">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanAnalgesiaRateGE70Years_Pethidine" DataType="System.Double" FilterControlAltText="Filter MeanAnalgesiaRateGE70Years_Pethidine column" HeaderText="Mean Analgesia Rate ≥ 70 Years (Pethidine)" ReadOnly="True" SortExpression="MeanAnalgesiaRateGE70Years_Pethidine" UniqueName="MeanAnalgesiaRateGE70Years_Pethidine">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanAnalgesiaRateLT70Years_Fentanyl" DataType="System.Double" FilterControlAltText="Filter MeanAnalgesiaRateLT70Years_Fentanyl column" HeaderText="Mean Analgesia Rate &lt; 70 Years (Fentanyl)" ReadOnly="True" SortExpression="MeanAnalgesiaRateLT70Years_Fentanyl" UniqueName="MeanAnalgesiaRateLT70Years_Fentanyl">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanAnalgesiaRateGE70Years_Fentanyl" DataType="System.Double" FilterControlAltText="Filter MeanAnalgesiaRateGE70Years_Fentanyl column" HeaderText="Mean Analgesia Rate ≥ 70 Years (Fentanyl)" ReadOnly="True" SortExpression="MeanAnalgesiaRateGE70Years_Fentanyl" UniqueName="MeanAnalgesiaRateGE70Years_Fentanyl">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN" FilterControlAltText="Filter ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN column" HeaderText="Concerns Regarding High Doses Of Sedation Or Analgesia (Y/N)" ReadOnly="True" SortExpression="ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN" UniqueName="ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="ComfortScoreGT4P" DataType="System.Decimal" FilterControlAltText="Filter ComfortScoreGT4P column" HeaderText="Comfort Score &gt; 4%" ReadOnly="True" SortExpression="ComfortScoreGT4P" UniqueName="ComfortScoreGT4P">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Completion_of_Intended_Therapeutic_ERCP_Rate_P" DataType="System.Decimal" FilterControlAltText="Filter Completion_of_Intended_Therapeutic_ERCP_Rate_P column" HeaderText="Completion of Intended Therapeutic ERCP Rate %" ReadOnly="True" SortExpression="Completion_of_Intended_Therapeutic_ERCP_Rate_P" UniqueName="Completion_of_Intended_Therapeutic_ERCP_Rate_P">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Decompression_of_Obstructed_Ducts_Success_Rate_P" DataType="System.Decimal" FilterControlAltText="Filter Decompression_of_Obstructed_Ducts_Success_Rate_P column" HeaderText="Decompression of Obstructed Ducts Success Rate %" ReadOnly="True" SortExpression="Decompression_of_Obstructed_Ducts_Success_Rate_P" UniqueName="Decompression_of_Obstructed_Ducts_Success_Rate_P">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Decompression_of_Obstructed_Ducts_Unsuccessful_Rate_P" DataType="System.Decimal" FilterControlAltText="Filter Decompression_of_Obstructed_Ducts_Unsuccessful_Rate_P column" HeaderText="Decompression of Obstructed Ducts Unsuccessful Rate %" ReadOnly="True" SortExpression="Decompression_of_Obstructed_Ducts_Unsuccessful_Rate_P" UniqueName="Decompression_of_Obstructed_Ducts_Unsuccessful_Rate_P">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Decompression_of_Obstructed_Ducts_Unknown_Rate_P" DataType="System.Decimal" FilterControlAltText="Filter Decompression_of_Obstructed_Ducts_Unknown_Rate_P column" HeaderText="Decompression of Obstructed Ducts Unknown Rate %" ReadOnly="True" SortExpression="Decompression_of_Obstructed_Ducts_Unknown_Rate_P" UniqueName="Decompression_of_Obstructed_Ducts_Unknown_Rate_P">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Comments_ActionTaken" FilterControlAltText="Filter Comments_ActionTaken column" HeaderText="Comments Action Taken" ReadOnly="True" SortExpression="Comments_ActionTaken" UniqueName="Comments_ActionTaken">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </telerik:GridBoundColumn>
                                        </Columns>
                                    </MasterTableView>
                                </telerik:RadGrid>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="RadPageSigmoidoscopy" runat="server">
                            <div class="TextContainer qsf-ib">
                                <h1>JAG/GRS Report: Sigmoidoscopy results</h1>
                                <telerik:RadContextMenu ID="RadContextMenuSIG" runat="server" OnClientItemClicked="getContextMenuSIG">
                                    <Targets>
                                        <telerik:ContextMenuControlTarget ControlID="RadGridSigmoidoscopy" />
                                        <telerik:ContextMenuElementTarget ElementID="" />
                                    </Targets>
                                    <Items>
                                    </Items>
                                </telerik:RadContextMenu>
                                <asp:ObjectDataSource ID="DSSigmoidoscopy" runat="server" SelectMethod="GetSIGQry" TypeName="UnisoftERS.Reports">
                                    <SelectParameters>
                                          <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                    </SelectParameters>
                                </asp:ObjectDataSource>

                                <telerik:RadGrid ID="RadGridSigmoidoscopy" runat="server" AllowPaging="True" Skin="Office2007" GroupPanelPosition="Top" AutoGenerateColumns="False" CellSpacing="-1"  PagerStyle-AlwaysVisible="true">
                                    <ClientSettings>
                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                        <Selecting  CellSelectionMode="SingleCell" EnableDragToSelectRows="True"></Selecting>
                                        <ClientEvents OnCellSelected="SelectCellSIG" ></ClientEvents>
                                    </ClientSettings>
                                    <MasterTableView DataKeyNames="Endoscopist1">
                                        <Columns>
                                            <telerik:GridBoundColumn DataField="Endoscopist1" DataType="System.Int32" FilterControlAltText="Filter Endoscopist1 column" HeaderText="Endoscopist" ReadOnly="True" SortExpression="Endoscopist1" UniqueName="Endoscopist1">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee" FilterControlAltText="Filter IndependentDirectlySupervisedTraineeDistantSupervisionTrainee column" HeaderText="Independent Directly Supervised Trainee/Distant Supervision Trainee" ReadOnly="True" SortExpression="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee" UniqueName="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee">
                                                <ItemStyle HorizontalAlign="Center" Width="100" />
                                                <HeaderStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Number_of_procedures" DataType="System.Int32" FilterControlAltText="Filter Number_of_procedures column" HeaderText="Number of procedures" ReadOnly="True" SortExpression="Number_of_procedures" UniqueName="Number_of_procedures">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanSedationRateLT70Years_Midazolam" DataType="System.Double" FilterControlAltText="Filter MeanSedationRateLT70Years_Midazolam column" HeaderText="Mean Sedation Rate &lt; 70 Years (Midazolam)" ReadOnly="True" SortExpression="MeanSedationRateLT70Years_Midazolam" UniqueName="MeanSedationRateLT70Years_Midazolam">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanSedationRateGE70Years_Midazolam" DataType="System.Double" FilterControlAltText="Filter MeanSedationRateGE70Years_Midazolam column" HeaderText="Mean Sedation Rate ≥ 70 Years (Midazolam)" ReadOnly="True" SortExpression="MeanSedationRateGE70Years_Midazolam" UniqueName="MeanSedationRateGE70Years_Midazolam">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanAnalgesiaRateLT70Years_Pethidine" DataType="System.Double" FilterControlAltText="Filter MeanAnalgesiaRateLT70Years_Pethidine column" HeaderText="Mean Analgesia Rate &lt; 70 Years (Pethidine)" ReadOnly="True" SortExpression="MeanAnalgesiaRateLT70Years_Pethidine" UniqueName="MeanAnalgesiaRateLT70Years_Pethidine">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanAnalgesiaRateGE70Years_Pethidine" DataType="System.Double" FilterControlAltText="Filter MeanAnalgesiaRateGE70Years_Pethidine column" HeaderText="Mean Analgesia Rate ≥ 70 Years (Pethidine)" ReadOnly="True" SortExpression="MeanAnalgesiaRateGE70Years_Pethidine" UniqueName="MeanAnalgesiaRateGE70Years_Pethidine">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanAnalgesiaRateLT70Years_Fentanyl" DataType="System.Double" FilterControlAltText="Filter MeanAnalgesiaRateLT70Years_Fentanyl column" HeaderText="Mean Analgesia Rate &lt; 70 Years (Fentanyl)" ReadOnly="True" SortExpression="MeanAnalgesiaRateLT70Years_Fentanyl" UniqueName="MeanAnalgesiaRateLT70Years_Fentanyl">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanAnalgesiaRateGE70Years_Fentanyl" DataType="System.Double" FilterControlAltText="Filter MeanAnalgesiaRateGE70Years_Fentanyl column" HeaderText="Mean Analgesia Rate ≥ 70 Years (Fentanyl)" ReadOnly="True" SortExpression="MeanAnalgesiaRateGE70Years_Fentanyl" UniqueName="MeanAnalgesiaRateGE70Years_Fentanyl">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN" FilterControlAltText="Filter ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN column" HeaderText="Concerns Regarding High Doses Of Sedation Or Analgesia (Y/N)" ReadOnly="True" SortExpression="ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN" UniqueName="ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="ComfortScoreGT4P" DataType="System.Decimal" FilterControlAltText="Filter ComfortScoreGT4P column" HeaderText="Comfort Score&gt; 4 %" ReadOnly="True" SortExpression="ComfortScoreGT4P" UniqueName="ComfortScoreGT4P">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Identification_and_position_of_colonic_tumours" FilterControlAltText="Filter Identification_and_position_of_colonic_tumours column" HeaderText="Identification and position of colonic tumours" ReadOnly="True" SortExpression="Identification_and_position_of_colonic_tumours" UniqueName="Identification_and_position_of_colonic_tumours">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Polyps_detection_rate_P" DataType="System.Decimal" FilterControlAltText="Filter Polyps_detection_rate_P column" HeaderText="Polyp detection rate %" ReadOnly="True" SortExpression="Polyps_detection_rate_P" UniqueName="Polyps_detection_rate_P">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Polyps_retrieval_rate_P" DataType="System.Decimal" FilterControlAltText="Filter Polyps_retrieval_rate_P column" HeaderText="Polyps retrieval rate %" ReadOnly="True" SortExpression="Polyps_retrieval_rate_P" UniqueName="Polyps_retrieval_rate_P">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Comments_ActionTaken" FilterControlAltText="Filter Comments_ActionTaken column" HeaderText="Comments Action Taken" ReadOnly="True" SortExpression="Comments_ActionTaken" UniqueName="Comments_ActionTaken">
                                                <HeaderStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                        </Columns>
                                    </MasterTableView>
                                </telerik:RadGrid>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="RadPageColonoscopy" runat="server">
                            <div class="TextContainer qsf-ib">
                                <h1>JAG/GRS Report: Colonoscopy results</h1>
                                <telerik:RadContextMenu ID="RadContextMenuCOL" runat="server" OnClientItemClicked="getContextMenuCOL">
                                    <Targets>
                                        <telerik:ContextMenuControlTarget ControlID="RadGridColonoscopy" />
                                        <telerik:ContextMenuElementTarget ElementID="" />
                                    </Targets>
                                    <Items>
                                    </Items>
                                </telerik:RadContextMenu>
                                <asp:ObjectDataSource ID="DSColonoscopy" runat="server" SelectMethod="GetCOLQry" TypeName="UnisoftERS.Reports">
                                    <SelectParameters>
                                          <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                    </SelectParameters>
                                </asp:ObjectDataSource>
                                <telerik:RadGrid ID="RadGridColonoscopy" runat="server" AllowPaging="True" Skin="Office2007" AutoGenerateColumns="False" GroupPanelPosition="Top" PagerStyle-AlwaysVisible="true">
                                    <ClientSettings>
                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                        <Selecting  CellSelectionMode="SingleCell" EnableDragToSelectRows="True"></Selecting>
                                        <ClientEvents OnCellSelected="SelectCellCOL" ></ClientEvents>
                                    </ClientSettings>
                                    <MasterTableView DataKeyNames="Endoscopist1">
                                        <Columns>
                                            <telerik:GridBoundColumn DataField="Endoscopist1" DataType="System.Int32" FilterControlAltText="Filter Endoscopist1 column" HeaderText="Endoscopist" ReadOnly="True" SortExpression="Endoscopist1" UniqueName="Endoscopist1">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee" FilterControlAltText="Filter IndependentDirectlySupervisedTraineeDistantSupervisionTrainee column" HeaderText="Independent Directly Supervised Trainee/Distant Supervision Trainee" ReadOnly="True" SortExpression="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee" UniqueName="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Number_of_procedures" DataType="System.Int32" FilterControlAltText="Filter Number_of_procedures column" HeaderText="Number of procedures" ReadOnly="True" SortExpression="Number_of_procedures" UniqueName="Number_of_procedures">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanSedationRateLT70Years_Midazolam" DataType="System.Double" FilterControlAltText="Filter MeanSedationRateLT70Years_Midazolam column" HeaderText="Mean Sedation Rate &lt; 70 Years (Midazolam)" ReadOnly="True" SortExpression="MeanSedationRateLT70Years_Midazolam" UniqueName="MeanSedationRateLT70Years_Midazolam">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanSedationRateGE70Years_Midazolam" DataType="System.Double" FilterControlAltText="Filter MeanSedationRateGE70Years_Midazolam column" HeaderText="Mean Sedation Rate ≥ 70 Years (Midazolam)" ReadOnly="True" SortExpression="MeanSedationRateGE70Years_Midazolam" UniqueName="MeanSedationRateGE70Years_Midazolam">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanAnalgesiaRateLT70Years_Pethidine" DataType="System.Double" FilterControlAltText="Filter MeanAnalgesiaRateLT70Years_Pethidine column" HeaderText="Mean Analgesia Rate &lt; 70 Years (Pethidine)" ReadOnly="True" SortExpression="MeanAnalgesiaRateLT70Years_Pethidine" UniqueName="MeanAnalgesiaRateLT70Years_Pethidine">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanAnalgesiaRateGE70Years_Pethidine" DataType="System.Double" FilterControlAltText="Filter MeanAnalgesiaRateGE70Years_Pethidine column" HeaderText="Mean Analgesia Rate ≥ 70 Years (Pethidine)" ReadOnly="True" SortExpression="MeanAnalgesiaRateGE70Years_Pethidine" UniqueName="MeanAnalgesiaRateGE70Years_Pethidine">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanAnalgesiaRateLT70Years_Fentanyl" DataType="System.Double" FilterControlAltText="Filter MeanAnalgesiaRateLT70Years_Fentanyl column" HeaderText="Mean Analgesia Rate &lt; 70 Years (Fentanyl)" ReadOnly="True" SortExpression="MeanAnalgesiaRateLT70Years_Fentanyl" UniqueName="MeanAnalgesiaRateLT70Years_Fentanyl">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="MeanAnalgesiaRateGE70Years_Fentanyl" DataType="System.Double" FilterControlAltText="Filter MeanAnalgesiaRateGE70Years_Fentanyl column" HeaderText="Mean Analgesia Rate ≥ 70 Years (Fentanyl)" ReadOnly="True" SortExpression="MeanAnalgesiaRateGE70Years_Fentanyl" UniqueName="MeanAnalgesiaRateGE70Years_Fentanyl">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN" FilterControlAltText="Filter ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN column" HeaderText="Concerns Regarding High Doses Of Sedation Or Analgesia (Y/N)" ReadOnly="True" SortExpression="ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN" UniqueName="ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="ComfortScoreGT4P" DataType="System.Decimal" FilterControlAltText="Filter ComfortScoreGT4P column" HeaderText="Comfort Score&gt; 4%" ReadOnly="True" SortExpression="ComfortScoreGT4P" UniqueName="ComfortScoreGT4P">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Colonoscopy_Completion_Rate" DataType="System.Int32" FilterControlAltText="Filter Colonoscopy_Completion_Rate column" HeaderText="Colonoscopy Completion Rate" ReadOnly="True" SortExpression="Colonoscopy_Completion_Rate" UniqueName="Colonoscopy_Completion_Rate">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Polyps_detection_rate_P" DataType="System.Decimal" FilterControlAltText="Filter Polyps_detection_rate_P column" HeaderText="Polyps detection rate %" ReadOnly="True" SortExpression="Polyps_detection_rate_P" UniqueName="Polyps_detection_rate_P">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Polyps_retrieval_rate_P" DataType="System.Decimal" FilterControlAltText="Filter Polyps_retrieval_rate_P column" HeaderText="Polyps retrieval rate %" ReadOnly="True" SortExpression="Polyps_retrieval_rate_P" UniqueName="Polyps_retrieval_rate_P">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Comments_ActionTaken" FilterControlAltText="Filter Comments_ActionTaken column" HeaderText="Comments Action Taken" ReadOnly="True" SortExpression="Comments_ActionTaken" UniqueName="Comments_ActionTaken">
                                                <HeaderStyle HorizontalAlign="Center" />
                                                <ItemStyle HorizontalAlign="Center" />
                                            </telerik:GridBoundColumn>
                                        </Columns>
                                    </MasterTableView>
                                </telerik:RadGrid>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="RadPageStandard" runat="server" BorderColor="#cccccc" BorderStyle="Solid" BorderWidth="1">
                            <div class="TextContainer qsf-ib">
                                <h1>JAG/GRS Report: Standard Bowel preparations</h1>
                                <telerik:RadContextMenu ID="RadContextMenuBPS" runat="server" OnClientItemClicked="getContextMenuBPS">
                                    <Targets>
                                        <telerik:ContextMenuControlTarget ControlID="RadGridStandard" />
                                        <telerik:ContextMenuElementTarget ElementID="" />
                                    </Targets>
                                    <Items>
                                    </Items>
                                </telerik:RadContextMenu>
                                <asp:ObjectDataSource ID="DSStandard" runat="server" SelectMethod="GetBPSQry" TypeName="UnisoftERS.Reports">
                                    <SelectParameters>
                                          <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                    </SelectParameters>
                                </asp:ObjectDataSource>
                                <telerik:RadGrid ID="RadGridStandard" runat="server" AllowPaging="True" Skin="Office2007" AutoGenerateColumns="False" GroupPanelPosition="Top" PagerStyle-AlwaysVisible="true">
                                    <ClientSettings>
                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                        <Selecting  CellSelectionMode="SingleCell" EnableDragToSelectRows="True"></Selecting>
                                        <ClientEvents OnCellSelected="SelectCellBPS" ></ClientEvents>
                                    </ClientSettings>
                                    <MasterTableView>
                                        <Columns>
                                            <telerik:GridBoundColumn DataField="ListItemText" FilterControlAltText="Filter ListItemText column" HeaderText="Bowel preparation" SortExpression="ListItemText" UniqueName="ListItemText">
                                                <HeaderStyle HorizontalAlign="Center" CssClass="div150" />
                                                <ItemStyle HorizontalAlign="Center" CssClass="div150" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Good" DataType="System.Int32" FilterControlAltText="Filter Good column" HeaderText="Good" ReadOnly="True" SortExpression="Good" UniqueName="Good">
                                                <HeaderStyle HorizontalAlign="Center" CssClass="div75" />
                                                <ItemStyle HorizontalAlign="Center" CssClass="div75" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="GoodP" DataType="System.Decimal" FilterControlAltText="Filter GoodP column" HeaderText="Good %" ReadOnly="True" SortExpression="GoodP" UniqueName="GoodP">
                                                <HeaderStyle HorizontalAlign="Center" CssClass="div75" />
                                                <ItemStyle HorizontalAlign="Center" CssClass="div75" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Satisfactory" DataType="System.Int32" FilterControlAltText="Filter Satisfactory column" HeaderText="Satisfactory" ReadOnly="True" SortExpression="Satisfactory" UniqueName="Satisfactory">
                                                <HeaderStyle HorizontalAlign="Center" CssClass="div75" />
                                                <ItemStyle HorizontalAlign="Center" CssClass="div75" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="SatisfactoryP" DataType="System.Decimal" FilterControlAltText="Filter SatisfactoryP column" HeaderText="Satisfactory %" ReadOnly="True" SortExpression="SatisfactoryP" UniqueName="SatisfactoryP">
                                                <HeaderStyle HorizontalAlign="Center" CssClass="div75" />
                                                <ItemStyle HorizontalAlign="Center" CssClass="div75" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Poor" DataType="System.Int32" FilterControlAltText="Filter Poor column" HeaderText="Poor" ReadOnly="True" SortExpression="Poor" UniqueName="Poor">
                                                <HeaderStyle HorizontalAlign="Center" CssClass="div75" />
                                                <ItemStyle HorizontalAlign="Center" CssClass="div75" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="PoorP" DataType="System.Decimal" FilterControlAltText="Filter PoorP column" HeaderText="Poor %" ReadOnly="True" SortExpression="PoorP" UniqueName="PoorP">
                                                <HeaderStyle HorizontalAlign="Center" CssClass="div75" />
                                                <ItemStyle HorizontalAlign="Center" CssClass="div75" />
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Total" DataType="System.Int32" FilterControlAltText="Filter Total column" HeaderText="Total" ReadOnly="True" SortExpression="Total" UniqueName="Total">
                                                <HeaderStyle HorizontalAlign="Center" CssClass="div75" />
                                                <ItemStyle HorizontalAlign="Center" CssClass="div75" />
                                            </telerik:GridBoundColumn>
                                        </Columns>
                                    </MasterTableView>
                                </telerik:RadGrid>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="RadPageBoston" runat="server" Width="100%">
                            <div class="TextContainer qsf-ib">
                                <h1>JAG/GRS Report: Boston Bowel preparations</h1>
                                <telerik:RadContextMenu ID="RadContextMenuBPB" runat="server" OnClientItemClicked="getContextMenuBPB">
                                    <Targets>
                                        <telerik:ContextMenuControlTarget ControlID="RadGridBoston1" />
                                        <telerik:ContextMenuElementTarget ElementID="" />
                                    </Targets>
                                    <Items>
                                    </Items>
                                </telerik:RadContextMenu>
                                <telerik:RadGrid ID="RadGridBoston1" runat="server" GroupPanelPosition="Top" Skin="Office2007" AutoGenerateColumns="False" PagerStyle-AlwaysVisible="true">
                                <ClientSettings>
                                    <Selecting AllowRowSelect="True" />
                                    <Selecting  CellSelectionMode="SingleCell" EnableDragToSelectRows="True"></Selecting>
                                    <ClientEvents OnCellSelected="SelectCellBPB" ></ClientEvents>
                                </ClientSettings>
                                <MasterTableView DataKeyNames="Formulation" >
                                    <DetailTables>
                                        <telerik:GridTableView runat="server" DataKeyNames="Formulation" Name="Boston1" AutoGenerateColumns="false" PageSize="5">
                                            <Columns>
                                                <telerik:GridBoundColumn DataField="Scale" DataType="System.Int32" FilterControlAltText="Filter Scale column" HeaderText="Scale" SortExpression="Scale" UniqueName="Scale">
                                                    <HeaderStyle HorizontalAlign="Center" />
                                                    <ItemStyle HorizontalAlign="Center" />
                                                </telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="Right" DataType="System.Int32" FilterControlAltText="Filter Right column" HeaderText="Right" SortExpression="Right" UniqueName="Right">
                                                    <HeaderStyle HorizontalAlign="Center" />
                                                    <ItemStyle HorizontalAlign="Center" />
                                                </telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="RightP" DataType="System.Decimal" FilterControlAltText="Filter RightP column" HeaderText="Right %" SortExpression="RightP" UniqueName="RightP">
                                                    <HeaderStyle HorizontalAlign="Center" />
                                                    <ItemStyle HorizontalAlign="Center" />
                                                </telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="Transverse" DataType="System.Int32" FilterControlAltText="Filter Transverse column" HeaderText="Transverse" SortExpression="Transverse" UniqueName="Transverse">
                                                    <HeaderStyle HorizontalAlign="Center" />
                                                    <ItemStyle HorizontalAlign="Center" />
                                                </telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="TransverseP" DataType="System.Decimal" FilterControlAltText="Filter TransverseP column" HeaderText="Transverse %" SortExpression="TransverseP" UniqueName="TransverseP">
                                                    <HeaderStyle HorizontalAlign="Center" />
                                                    <ItemStyle HorizontalAlign="Center" />
                                                </telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="Left" DataType="System.Int32" FilterControlAltText="Filter Left column" HeaderText="Left" SortExpression="Left" UniqueName="Left">
                                                    <HeaderStyle HorizontalAlign="Center" />
                                                    <ItemStyle HorizontalAlign="Center" />
                                                </telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="LeftP" DataType="System.Decimal" FilterControlAltText="Filter LeftP column" HeaderText="Left %" SortExpression="LeftP" UniqueName="LeftP">
                                                    <HeaderStyle HorizontalAlign="Center" />
                                                    <ItemStyle HorizontalAlign="Center" />
                                                </telerik:GridBoundColumn>
                                            </Columns>
                                        </telerik:GridTableView>
                                        <telerik:GridTableView runat="server" DataKeyNames="Formulation" Name="Boston3" AutoGenerateColumns="false" PageSize="9">
                                            <Columns>
                                                <telerik:GridBoundColumn DataField="Score" DataType="System.Int32" FilterControlAltText="Filter Score column" HeaderText="Score" SortExpression="Score" UniqueName="Score">
                                                    <HeaderStyle HorizontalAlign="Center" Width="5" />
                                                    <ItemStyle HorizontalAlign="Center" Width="5" />
                                                </telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="Frecuency" DataType="System.Int32" FilterControlAltText="Filter Frecuency column" HeaderText="Frecuency" SortExpression="Frecuency" UniqueName="Frecuency">
                                                    <HeaderStyle HorizontalAlign="Center" />
                                                    <ItemStyle HorizontalAlign="Center" />
                                                </telerik:GridBoundColumn>
                                            </Columns>
                                        </telerik:GridTableView>
                                    </DetailTables>
                                    <Columns>
                                        <telerik:GridBoundColumn DataField="Formulation" FilterControlAltText="Filter Formulation column" HeaderText="Formulation" SortExpression="Formulation" UniqueName="Formulation">
                                            <HeaderStyle HorizontalAlign="Center" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </telerik:GridBoundColumn>
                                        <telerik:GridBoundColumn DataField="NoOfProcs" DataType="System.Int32" FilterControlAltText="Filter NoOfProcs column" HeaderText="Number Of Procedures" SortExpression="NoOfProcs" UniqueName="NoOfProcs">
                                            <HeaderStyle HorizontalAlign="Center" />
                                            <ItemStyle HorizontalAlign="Center" />
                                        </telerik:GridBoundColumn>
                                        <telerik:GridBoundColumn DataField="MeanScore" DataType="System.Decimal" FilterControlAltText="Filter MeanScore column" HeaderText="Mean Score" SortExpression="MeanScore" UniqueName="MeanScore">
                                            <HeaderStyle HorizontalAlign="Center" />
                                            <ItemStyle HorizontalAlign="Center" />
                                        </telerik:GridBoundColumn>
                                    </Columns>
                                </MasterTableView>
                            </telerik:RadGrid>
                                <asp:ObjectDataSource ID="DSBoston1" runat="server" SelectMethod="Boston1Qry" TypeName="UnisoftERS.Reports">
                                    <SelectParameters>
                                          <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                    </SelectParameters>
                                </asp:ObjectDataSource>
                                <asp:ObjectDataSource ID="DSBoston2" runat="server" SelectMethod="Boston2Qry" TypeName="UnisoftERS.Reports">
                                    <SelectParameters>
                                          <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                    </SelectParameters>
                                </asp:ObjectDataSource>
                                <asp:ObjectDataSource ID="DSBoston3" runat="server" SelectMethod="Boston3Qry" TypeName="UnisoftERS.Reports">
                                    <SelectParameters>
                                          <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                    </SelectParameters>
                                </asp:ObjectDataSource>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="RadPageEndoscopists" runat="server">
                            <div class="TextContainer qsf-ib">
                                <h1>JAG/GRS Report: Consultants</h1>
                                <telerik:RadContextMenu ID="RadContextMenuCON" runat="server" OnClientItemClicked="getContextMenuCON">
                                    <Targets>
                                        <telerik:ContextMenuControlTarget ControlID="RadGridEndoscopists" />
                                        <telerik:ContextMenuElementTarget ElementID="" />
                                    </Targets>
                                    <Items>
                                    </Items>
                                </telerik:RadContextMenu>
                                <asp:ObjectDataSource ID="DSEndoscopists" runat="server" SelectMethod="GetConsultantsQry" TypeName="UnisoftERS.Reports">
                                    <SelectParameters>
                                          <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                    </SelectParameters>
                                </asp:ObjectDataSource>
                                <telerik:RadGrid ID="RadGridEndoscopists" runat="server" AllowPaging="True" Skin="Office2007" AutoGenerateColumns="False" GroupPanelPosition="Top" PagerStyle-AlwaysVisible="true">
                                    <ClientSettings>
                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                        <Selecting  CellSelectionMode="SingleCell" EnableDragToSelectRows="True"></Selecting>
                                        <ClientEvents OnCellSelected="SelectCellCON" ></ClientEvents>
                                    </ClientSettings>
                                    <MasterTableView DataKeyNames="UserID">
                                        <Columns>
                                            <telerik:GridBoundColumn DataField="UserID" DataType="System.Int32" FilterControlAltText="Filter UserID column" HeaderText="User ID" ReadOnly="True" SortExpression="UserID" UniqueName="UserID">
                                                <HeaderStyle HorizontalAlign="Center" CssClass="div50"/>
                                                <ItemStyle HorizontalAlign="Center" CssClass="div50"/>
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Consultant" FilterControlAltText="Filter Consultant column" HeaderText="Consultant" ReadOnly="True" SortExpression="Consultant" UniqueName="Consultant">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </telerik:GridBoundColumn>
                                        </Columns>
                                        <GroupHeaderItemStyle Wrap="True" />
                                    </MasterTableView>
                                </telerik:RadGrid>
                            </div>
                        </telerik:RadPageView>
                    </telerik:RadMultiPage>
                </telerik:RadPageView>
            </telerik:RadMultiPage>
        </div>
        </asp:Panel>
        <telerik:RadWindow ID="RadWindow1" runat="server" Title="Related procedures" VisibleOnPageLoad="False" MinHeight="300px" MinWidth="400px">
            <ContentTemplate>
            <div id="MiniWindow1">
            </div>
            </ContentTemplate>
        </telerik:RadWindow>
        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Animation="Fade" AutoSize="true" Modal="True" RenderMode="Classic" VisibleStatusbar="False" Skin="Office2007">
            <Windows>
            </Windows>
        </telerik:RadWindowManager>
        </div>
    </form>
</body>
</html>
