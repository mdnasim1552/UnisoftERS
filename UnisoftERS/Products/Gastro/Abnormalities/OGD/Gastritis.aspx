<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Gastritis" CodeBehind="Gastritis.aspx.vb" %>



<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />    

    <telerik:RadScriptBlock runat="server">


        <script type="text/javascript">
            var gastritisValueChanged = false;
            var validationMessage = "";
            //var buttons = [];
            //function ButtonLoad(sender, args) {
            //    Array.add(buttons, sender);
            //}

            function refreshDiagramGastritis(siteid) {
                parent.refreshDiagramGastritis(siteid);
            }
           
            function validateInspectionTime(sender, args) {
                 var isValid = true;

                if ($find('<%=Atrophic_CheckBox.ClientID%>').get_checked() || $find('<%=Intestinal_Metaplasia_CheckBox.ClientID%>').get_checked()) {
                    var startTime = $find('<%=InspectionStartRadTimePicker.ClientID%>').get_timeView().getTime();
                    var endTime = $find('<%=InspectionEndRadTimePicker.ClientID%>').get_timeView().getTime();

                    if (startTime == null || endTime == null) {
                        isValid = false;                       
                        //highlight required fields
                        $find('<%=InspectionStartRadTimePicker.ClientID%>').get_textBox().className = $find('<%=InspectionStartRadTimePicker.ClientID%>').get_textBox().className + ' validation-error-field';
                        $find('<%=InspectionEndRadTimePicker.ClientID%>').get_textBox().className = $find('<%=InspectionEndRadTimePicker.ClientID%>').get_textBox().className + ' validation-error-field';
                       validationMessage = "An inspection start and end time is required for a diagnoses of Atrophy or Intestinal Metaplasia.";
               
                        //error message
                       // $find('<%=ErrorRadNotification.ClientID%>').set_text("An inspection start and end time is required for a diagnoses of Atrophy or Intestinal Metaplasia");
                        //$find('<%=ErrorRadNotification.ClientID%>').set_position(Telerik.Web.UI.NotificationPosition.Center);
                       // $find('<%=ErrorRadNotification.ClientID%>').show();
                    }
                }

                //if (!isValid) {
                //    args.set_cancel(true);
                //}
                return isValid;
            }

            $(window).on('load', function () {
                checkAllRadControls($find("NoneCheckBox").get_checked());
                //$('input[type="checkbox"]').each(function () {
                //    ToggleTRs($(this));
                //});
                toggleSydneyProtocol();
                toggleInspectionField();

            });

            $(document).ready(function () {

                $('#<%=ChooseStartFromImageRadButton.ClientID%>').on('click', function () {
                    showImagePicker('start');
                });

                $('#<%=ChooseEndFromImageRadButton.ClientID%>').on('click', function () {
                    showImagePicker('end');
                });

                $(window).on('beforeunload', function () {
                   if (validationMessage !== "") {
                        if ($find('<%=Atrophic_CheckBox.ClientID%>').get_checked()) $find('<%=Atrophic_CheckBox.ClientID%>').set_checked(false);
                        if ($find('<%=Intestinal_Metaplasia_CheckBox.ClientID%>').get_checked()) $find('<%=Intestinal_Metaplasia_CheckBox.ClientID%>').set_checked(false);
                    }
                    if (gastritisValueChanged) {
                        ValueChnaged();
                        $("#SaveButton").click();
                    }                                 
                });

                $(window).on('unload', function () {       
                    localStorage.clear();   
                });
            });
            var countCheck = 0;
            function ValueChnaged() {

                var allRadControls = $telerik.radControls;
                for (var i = 0; i < allRadControls.length; i++) {
                    var element = allRadControls[i];
                    var elemId = element.get_element().id;
                    if ($find("NoneCheckBox").get_checked() || (elemId.indexOf("_CheckBox") > 0 && $find(elemId).get_checked())) {
                        countCheck++;
                        break;
                    }
                }
                if (countCheck > 0) {
                    localStorage.setItem('valueChanged', 'true');
                } else {
                    localStorage.setItem('valueChanged', 'false');
                }
            }



            function gastritisChangedLocalStorage() {
                
                gastritisValueChanged = true;
               
                if (!validateInspectionTime()) {
                    localStorage.setItem('validationRequired', 'true');
                    if (validationMessage !== "") {
                        localStorage.setItem('validationRequiredMessage', validationMessage);                
                    } 

                } else {
                    localStorage.setItem('validationRequired', 'false');
                    if (validationMessage !== "") localStorage.setItem('validationRequiredMessage', '');
                    validationMessage = '';
                }
            }

            var documentUrl = document.URL;

            function showImagePicker(section) {
                var url = documentUrl.slice(0, documentUrl.indexOf("/Products/")) + "/Products/Common/ImagePicker.aspx?control=gastritis&section=" + section;

                var oWnd = $find('<%=ImagePickerRadWindow.ClientID%>');
                oWnd.setUrl(url);
                oWnd.setSize(500, 550);
                oWnd.show();
                gastritisChangedLocalStorage();
            }

            function startGastritisImageSelected(section, imageTimeStamp) {
                var time = new Date(imageTimeStamp);

                if (section == 'start') {
                    $find('<%=InspectionStartDateRadTimeInput.ClientID%>').set_selectedDate(time);
                    $find('<%=InspectionStartRadTimePicker.ClientID%>').get_timeView().setTime(time.getHours(),
                        time.getMinutes(),
                        time.getSeconds(),
                        time);
                }
                else if (section == 'end') {
                    //check that end date is after start date (if present)
                    $find('<%=InspectionEndDateRadTimeInput.ClientID%>').set_selectedDate(time);
                    $find('<%=InspectionEndRadTimePicker.ClientID%>').get_timeView().setTime(time.getHours(),
                        time.getMinutes(),
                        time.getSeconds(),
                        time);
                }
                gastritisChangedLocalStorage();
            }

            function updateInspectionTimings() {
                var startDate = $find('<%=InspectionStartDateRadTimeInput.ClientID%>').get_selectedDate();
                var startTime = $find('<%=InspectionStartRadTimePicker.ClientID%>').get_timeView().getTime();

                var endDate = $find('<%=InspectionEndDateRadTimeInput.ClientID%>').get_selectedDate();
                var endTime = $find('<%=InspectionEndRadTimePicker.ClientID%>').get_timeView().getTime();

                if (startTime != null) {
                    //join controls to make datetime 
                    startDate.setHours(startTime.getHours());
                    startDate.setMinutes(startTime.getMinutes());
                }
                if (endTime != null) {
                    endDate.setHours(endTime.getHours());
                    endDate.setMinutes(endTime.getMinutes());
                }
                else {
                    endDate.setHours(startTime.getHours());
                    endDate.setMinutes(startTime.getMinutes());
                }

                //validate date validility
                if (startDate > endDate) {
                    alert('Start date/time cannot be after the end date/time');
                    return;
                }

                var obj = {};
                obj.siteId = <%=siteId%>;
                obj.startDateTime = startDate;
                obj.endDateTime = endDate;

                $.ajax({
                    type: "POST",
                    url: "../../../Procedure.aspx/saveGastricInspectionTiming",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function () {
                        //
                    },
                    error: function (x, y, z) {
                        //show a message
                        console.log(x.responseText);
                    }
                });
                gastritisChangedLocalStorage();
            }

            function toggleInspectionField() {
                if ($find('<%=Atrophic_CheckBox.ClientID%>').get_checked() || $find('<%=Intestinal_Metaplasia_CheckBox.ClientID%>').get_checked()) {
                    $('.inspection-timings').show();
                    //NED Requirement. Inspection time must be provided when gastric atrophy OR gastric intestinal metaplasia
                    setRequiredField('<%=InspectionStartRadTimePicker.ClientID%>', 'inspection start time');
                    setRequiredField('<%=InspectionEndRadTimePicker.ClientID%>', 'inspection end time');
                }
                else {
                    $('.inspection-timings').hide();
                    removeRequiredField('<%=InspectionStartRadTimePicker.ClientID%>', 'inspection start time');
                    removeRequiredField('<%=InspectionEndRadTimePicker.ClientID%>', 'inspection end time');
                }
            }

            function savePage() {
                $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest();
            }


            function CloseWindow() {
                window.parent.CloseWindow();
            }

            function ToggleTRs(sender, args) {
                var enableCombo = args.get_checked();
                var elemId = sender.get_element().id;
                var newElemId = elemId.replace("_CheckBox", "_Severity_ComboBox");
                clearCombo(newElemId, enableCombo);
                newElemId = elemId.replace("_CheckBox", "_Bleeding_ComboBox");
                clearCombo(newElemId, enableCombo);

                if (elemId.indexOf("Atrophic_") !== -1 || elemId.indexOf("Intestinal_Metaplasia") !== -1) {
                    toggleInspectionField();
                }

                var isChecked = false;

                toggleSydneyProtocol();
                gastritisChangedLocalStorage();
            }

            function toggleSydneyProtocol() {
                var isChecked = false;
                 $('.GastritisCheckbox').each(function(idx, itm) {
                    if ($find($(itm)[0].id).get_checked() == true) {
                        isChecked = true;
                    }
                });

                if (isChecked == true) {
                    $('#SydneyProtocolDiv').show();
                }
                else {
                    $('#SydneyProtocolDiv').hide();               
                }
                gastritisChangedLocalStorage();
            }

            function clearCombo(elemId, enableCombo) {
                var dropdownlist = $find(elemId);
                if (dropdownlist != null) {
                    if (elemId.indexOf("_Bleeding_") !== -1) {
                        dropdownlist.findItemByValue("9").select();
                    } else {
                        dropdownlist.findItemByValue("0").select();
                    }
                    //var item = dropdownlist.findItemByValue("0");
                    //item.select();
                    if (enableCombo) {
                        dropdownlist.enable();
                        $find("NoneCheckBox").set_checked(false);
                    } else {
                        dropdownlist.disable();
                    }
                }
            }

            function ToggleNoneCheckBox(sender, args) {
                checkAllRadControls(args.get_checked());
                gastritisChangedLocalStorage();
                //$("#GastritisTable tbody tr td:first-child").each(function () {
                //});
            }

            function checkAllRadControls(noneChecked) {
                if (!noneChecked) { return; }
                var allRadTreeViews = [];
                var allRadControls = $telerik.radControls;
                for (var i = 0; i < allRadControls.length; i++) {
                    var element = allRadControls[i];
                    //if (RadButton && RadButton.isInstanceOfType(element)) {
                    var elemId = element.get_element().id;
                    if ((elemId != "NoneCheckBox") && elemId.indexOf("_CheckBox") > 0) {
                        element.set_checked(false);
                    }
                    //}
                    //if (RadComboBox && RadComboBox.isInstanceOfType(element)) {
                    //    alert(2);
                    //    var elemId = element.get_element().id;
                    //    if ((elemId.indexOf("_Severity_ComboBox") > 0) || (elemId.indexOf("_Bleeding_ComboBox") > 0)) {
                    //        clearCombo(elemId, false);
                    //    }
                    //}
                }
                gastritisChangedLocalStorage();
            }


            function toggleClass(sender, args) {
                var elemId = sender.get_element();
                var dropdownlist = $find(sender.get_element().id);
                var val = dropdownlist.get_selectedItem().get_value();
                if (elemId.id.indexOf("_Bleeding_") > 0) { val++; }
                var elemId = sender.get_element();
                var className = elemId.className;
                var pos = className.indexOf(" abnor_cb");
                var newClassName;
                if (pos > 0) {
                    newClassName = className.substring(0, pos) + " abnor_cb" + val;
                }
                else {
                    newClassName = className + " abnor_cb" + val;
                }
                elemId.className = newClassName;
                gastritisChangedLocalStorage();
            }



        </script>
    </telerik:RadScriptBlock>

    <style type="text/css">
        .abnor_cb1.RadComboBox .rcbInputCell .rcbArrowCell .rcbFocused .rcbScroll .rcbList .rcbItem .rcbHovered .rcbDisabled .rcbNoWrap .rcbLoading .rcbMoreResults .rcbImage .rcbEmptyMessage .rcbSeparator .rcbLabel,
        .abnor_cb1 .rcbInputCell INPUT.rcbInput,
        .abnor_cb1 {
            color: black !important;
        }
        /*green to black*/

        .abnor_cb2.RadComboBox .rcbInputCell .rcbArrowCell .rcbFocused .rcbScroll .rcbList .rcbItem .rcbHovered .rcbDisabled .rcbNoWrap .rcbLoading .rcbMoreResults .rcbImage .rcbEmptyMessage .rcbSeparator .rcbLabel,
        .abnor_cb2 .rcbInputCell INPUT.rcbInput,
        .abnor_cb2 {
            color: black !important;
        }
        /*orange to black*/

        /*cb3.RadComboBox .rcbDisabled,
        cb3.RadComboBox .rcbInputCell .rcbArrowCell .rcbFocused .rcbScroll .rcbList .rcbItem .rcbHovered .rcbDisabled .rcbNoWrap .rcbLoading .rcbMoreResults .rcbImage .rcbEmptyMessage .rcbSeparator .rcbLabel,*/
        /*.cb3 .rcbInputCell .rcbArrowCell .rcbFocused .rcbScroll .rcbList .rcbItem .rcbHovered .rcbDisabled .rcbNoWrap .rcbLoading .rcbMoreResults .rcbImage .rcbEmptyMessage .rcbSeparator .rcbLabel*/

        .abnor_cb3.RadComboBox .rcbInputCell .rcbArrowCell .rcbFocused .rcbScroll .rcbList .rcbItem .rcbHovered .rcbDisabled .rcbNoWrap .rcbLoading .rcbMoreResults .rcbImage .rcbEmptyMessage .rcbSeparator .rcbLabel,
        .abnor_cb3 .rcbInputCell INPUT.rcbInput,
        .abnor_cb3 {
            color: black !important;
        }
        /*red to black*/


        .ContentTable {
            /*width: 100%;*/
            /*border-collapse: collapse;*/
        }

            .ContentTable th {
                /*border: #4e95f4 1px solid;*/
                /*padding-top: 5px;
                padding-bottom: 4px;
                background-color: #A7C942;
                color: #fff;*/
                height: 25px;
                width: 200px;
            }

            .ContentTable td {
                /*border: #4e95f4 1px solid;*/
                height: 28px;
            }

            .ContentTable tr {
                /*background: #b8d1f3;*/
            }

                .ContentTable tr:nth-child(odd) {
                    /*background: #b8d1f3;*/
                }

                .ContentTable tr:nth-child(even) {
                    background: #dae5f4;
                }

        #SydneyProtocolDiv {
            display: none;
        }


        .rgview_right td {
            padding: 7px 8px !important;
        }

        .rgview_right th {
            padding: 10px 8px !important;
        }
    </style>
</head>

<body>

    <form id="form1" runat="server">
        <telerik:RadNotification ID="ErrorRadNotification" ShowCloseButton="true" AutoCloseDelay="0" runat="server" VisibleOnPageLoad="false" Skin="Metro" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>" Position="TopCenter" />

        <telerik:RadScriptManager ID="GastritisRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="GastritisRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
       
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Gastritis</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="None" Width="95%" Height="470">
                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server" style="float: left;">

                            <table id="GastritisTable" class="rgview" cellpadding="0" cellspacing="0" style="min-width: 545px">
                                <colgroup>
                                    <col>
                                    <col>
                                    <col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th width="210px" class="rgHeader" style="text-align: left;">
                                            <telerik:RadButton ID="NoneCheckBox" runat="server" Text="None" Skin="Web20" OnClientCheckedChanged="ToggleNoneCheckBox"></telerik:RadButton>
                                        </th>
                                        <th width="110px" class="rgHeader">Severity</th>
                                        <th width="110px" class="rgHeader">Bleeding</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr class="rgRow">
                                        <td>
                                            <telerik:RadButton ID="Atrophic_CheckBox" runat="server" Text="Atrophic" Skin="Web20" OnClientCheckedChanged="ToggleTRs" CssClass="GastritisCheckbox"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Atrophic_Severity_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Atrophic_Bleeding_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgRow">
                                        <td>
                                            <telerik:RadButton ID="Erythematous_CheckBox" runat="server" Text="Erythematous/exudative" Skin="Web20" OnClientCheckedChanged="ToggleTRs" CssClass="GastritisCheckbox"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Erythematous_Severity_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Erythematous_Bleeding_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td>
                                            <telerik:RadButton ID="FlatErosive_CheckBox" runat="server" Text="Flat erosive" Skin="Web20" OnClientCheckedChanged="ToggleTRs" CssClass="GastritisCheckbox"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="FlatErosive_Severity_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="FlatErosive_Bleeding_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                    </tr>


                                    <tr class="rgRow">
                                        <td>
                                            <telerik:RadButton ID="Haemorrhagic_CheckBox" runat="server" Text="Haemorrhagic" Skin="Web20" OnClientCheckedChanged="ToggleTRs" CssClass="GastritisCheckbox"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Haemorrhagic_Severity_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Haemorrhagic_Bleeding_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgRow">
                                        <td>
                                            <telerik:RadButton ID="RaisedErosive_CheckBox" runat="server" Text="Raised erosive" Skin="Web20" OnClientCheckedChanged="ToggleTRs" CssClass="GastritisCheckbox"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="RaisedErosive_Severity_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="RaisedErosive_Bleeding_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td>
                                            <telerik:RadButton ID="Reflux_CheckBox" runat="server" Text="Reflux" Skin="Web20" OnClientCheckedChanged="ToggleTRs" CssClass="GastritisCheckbox"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Reflux_Severity_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Reflux_Bleeding_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgRow">
                                        <td>
                                            <telerik:RadButton ID="RugalHyperplastic_CheckBox" runat="server" Text="Rugal hyperplastic" Skin="Web20" OnClientCheckedChanged="ToggleTRs" CssClass="GastritisCheckbox"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="RugalHyperplastic_Severity_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="RugalHyperplastic_Bleeding_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgRow">
                                        <td>
                                            <telerik:RadButton ID="PromAreaeGastricae_CheckBox" runat="server" Text="Prominent areae gastricae" Skin="Web20" OnClientCheckedChanged="ToggleTRs" CssClass="GastritisCheckbox"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="PromAreaeGastricae_Severity_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell"></td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td>
                                            <telerik:RadButton ID="Vomiting_CheckBox" runat="server" Text="Vomiting or prolapsed induced" Skin="Web20" OnClientCheckedChanged="ToggleTRs" CssClass="GastritisCheckbox"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Vomiting_Severity_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Vomiting_Bleeding_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td>
                                            <telerik:RadButton ID="Corrosive_Burns_CheckBox" runat="server" Text="Corrosive ingestion burns" Skin="Web20" OnClientCheckedChanged="ToggleTRs" CssClass="GastritisCheckbox"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Corrosive_Burns_Severity_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Corrosive_Burns_Bleeding_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td>
                                            <telerik:RadButton ID="Intestinal_Metaplasia_CheckBox" runat="server" Text="Gastric intestinal metaplasia" Skin="Web20" OnClientCheckedChanged="ToggleTRs" CssClass="GastritisCheckbox"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Intestinal_Metaplasia_Severity_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell"></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        &nbsp;
                        <div class="rgview" style="float: left; padding-left: 5px;">
                        <div id="SydneyProtocolDiv" >
                            <asp:Repeater ID="SydneyProtocalSitesRepeater" runat="server">
                                <HeaderTemplate>
                                     <table class="rgview_right" cellpadding="0" cellspacing="0">
                                <colgroup>
                                    <col>
                                    <col>
                                    <col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th style="height: 10px;" class="rgHeader">Biopsy Sites</th>
                                        <th style="height: 10px;" class="rgHeader">Quantity</th>
                                    </tr>
                                </thead>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <tr>
                                    <td><asp:HiddenField ID="SydneyProtocolSiteIdHiddenField" runat="server" Value='<%#Eval("SydneyProtocolSitesId") %>' />
                                        <asp:HiddenField ID="SydneyProtocolSiteSpecimenIdHiddenField" runat="server" Value='0' />
                                        <%#Eval("Description") %>
                                    </td>
                                    <td>
                                        <telerik:RadNumericTextBox ID="BiopsyQtyNumericTextBox" runat="server"
                                            IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="1"
                                            Width="35px"
                                            MinValue="0">
                                            <NumberFormat DecimalDigits="0" />
                                        </telerik:RadNumericTextBox>
                                    </td>
                                </tr>
                                </ItemTemplate>
                                <FooterTemplate>
                                    </table>
                                </FooterTemplate>
                            </asp:Repeater>
                        </div>
                        <div class="inspection-timings" style="display: none; width:50px;">
                           <div class="info">
                                <asp:Label ID="SaveErrorMessageLabel" runat="server" Text="There was a problem saving your data. Please save manually or contact support for help" ForeColor="Red" Style="display: none;" />
                            </div>
                            <div id="ProcTimingsDiv" style="width:230px; margin-top:10px;">
                                <table class="rgview_right" cellpadding="0" cellspacing="0" style=" width:100%;">
                                <%--<table style="font-family: 'Segoe UI',Arial,Helvetica,sans-serif; font-size: 12px; width:93%;">--%>
                                    <tr>
                                        <th colspan="2">Inspection time</th>
                                    </tr>
                                    <tr>
                                        <td colspan="2" style="border-bottom:none;">
                                            <span>Start time:</span>&nbsp;<telerik:RadButton ID="ChooseStartFromImageRadButton" runat="server" Text="Choose from photo" AutoPostBack="false" />
                                        </td>
                                        </tr>
                                    <tr>
                                        <td style="border-top:none;">
                                            <telerik:RadDateInput ID="InspectionStartDateRadTimeInput" runat="server" Width="100" DisplayDateFormat="dd/MM/yyyy" />
                                   
                                            
                                            <telerik:RadTimePicker ID="InspectionStartRadTimePicker" runat="server" Enabled="true" DateInput-OnClientDateChanged="updateInspectionTimings" Width="100px" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" style="border-bottom:none;">
                                            <span>End time:</span>&nbsp;<telerik:RadButton ID="ChooseEndFromImageRadButton" runat="server" Text="Choose from photo" AutoPostBack="false" />
                                        </td>
                                        </tr>
                                    <tr>
                                        <td style="border-top:none;">
                                            <telerik:RadDateInput ID="InspectionEndDateRadTimeInput" runat="server" Width="100" />
                                   
                                            <telerik:RadTimePicker ID="InspectionEndRadTimePicker" runat="server" Enabled="true" DateInput-OnClientDateChanged="updateInspectionTimings" Width="100px" />
                                        </td>
                                    </tr>
                                </table>

                            </div>
                        
                    </div>
                            </div>
                    </div>
                    
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; display:none; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" OnClientClicking="validateInspectionTime" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        <telerik:RadWindowManager ID="WindowManager1" runat="server" ShowContentDuringLoad="false" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move">
            <Windows>
                <telerik:RadWindow ID="ImagePickerRadWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="340px" Height="150px" Skin="Metro" Title="Choose image" VisibleStatusbar="false" Animation="None">
                    <ContentTemplate></ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
        <telerik:RadScriptBlock runat="server">
            <script type="text/javascript">

</script>
        </telerik:RadScriptBlock>
        </ContentTemplate>
        </asp:UpdatePanel>

    </form>

</body>
</html>
