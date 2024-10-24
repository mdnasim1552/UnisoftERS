<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="AddEditListTemplate.aspx.vb" Inherits="UnisoftERS.AddEditListTemplate" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>List template details</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../../Scripts/rgbcolor.js"></script>

    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />


    <style type="text/css">
        .repeat-pattern {
            width: 330px;
        }

        .list-repeat-controls, .monthlyfrequency {
            display: none;
        }
        /*hides hourly occurrence in recurrent rules setion*/
        .rsRecurrenceOptionList li:first-child {
            display: none;
        }

        .rsAdvRecurrenceRangePanel ul li:nth-child(2) {
            display: none;
        }

        .buttonClass {
            padding: 2px 20px;
            text-decoration: solid;
            text-decoration-color: black !important;
            border: 1px solid black;
        }

        .RadScheduler_Metro a, .RadScheduler_Metro input, .RadScheduler_Metro select, .RadScheduler_Metro textarea {
            color: black;
        }

        .new-list-table td {
            padding: 2px;
        }
    </style>
    <telerik:RadScriptBlock runat="server" ID="ScriptBlock1">

        <script type="text/javascript">
            var changed_ctrl;

            function getWeekNumber(d) {
                // Copy date so don't modify original
                d = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
                // Set to nearest Thursday: current date + 4 - current day number
                // Make Sunday's day number 7
                d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7));
                // Get first day of year
                var yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
                // Calculate full weeks to nearest Thursday
                var weekNo = Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
                // Return array of year and week number
                return weekNo;
            }

            function cbGenericTemplate_changed(sender, args) {
                var selectedValue = parseInt(args.get_item().get_value());

                //if (selectedValue == 0) {
                //    $('.list-slots').hide();
                //}
                //else {
                //    $('.list-slots').show();
                //}
            }

            function proceduretype_changed(sender, args) {
                changed_ctrl = sender;
                var proceduretypeid = parseInt(args.get_item().get_value());

                if (proceduretypeid > 0) {
                    var obj = {};
                    obj.procedureTypeId = proceduretypeid;
                    obj.operatingHospitalId = parseInt($('#<%=OperatingHospitalIdHiddenField.ClientID%>').val());
                    obj.isTraining = $('#<%=chkIsTraining.ClientID%>').is(':checked');
                    obj.isNonGI = false;
                    obj.isDiagnostic = true;

                    $.ajax({
                        type: "POST",
                        url: "../DiarySchedule.aspx/getProcedurePoints",
                        data: JSON.stringify(obj),
                        dataType: "json",
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            if (data.d != null) {
                                var res = JSON.parse(data.d);
                                if (res.points > 0)
                                    $('#' + changed_ctrl.get_id()).closest('tr').find('.slot-points').val(res.points);
                                else
                                    $('#' + changed_ctrl.get_id()).closest('tr').find('.slot-points').val(1);

                                if (res.length > 0)
                                    $('#' + changed_ctrl.get_id()).closest('tr').find('.slot-length').val(res.length);
                                else
                                    $('#' + changed_ctrl.get_id()).closest('tr').find('.slot-length').val(15);

                            }

                            //need to calculate the overall points and set the counter
                            var totalSlotPoints = parseFloat(0);
                            $('.slot-points').not('.new-slot').each(function (idx, itm) {
                                totalSlotPoints += parseFloat($(itm).val());
                            });

                            $('#<%=TotalPointsLabel.ClientID%>').text(totalSlotPoints);
                        },
                        error: function (x, y, z) {
                            console.log(x.responseJSON.Message);
                        }
                    });
                }
            }

            function showListTemplateWindow() {
                var oWnd = $find('<%=ListTemplateRadWindow.ClientID%>');
                oWnd.setUrl('../Products/Scheduler/Windows/AddEditListTemplate.aspx');
                oWnd.setSize(500, 550);
                oWnd.show();
            }

            function startdate_changed(sender, args) {

                //set max value based on the amount of weeks in the current month here?
                var templateId = $find('<%=cbGenericTemplate.ClientID%>').get_value();
                if (templateId > 0)
                    getTemplateEndTime(templateId);
                else
                    $find('<%=EndTimePicker.ClientID%>').get_dateInput().set_value($find('<%=StartTimePicker.ClientID%>').get_selectedDate());

            }

            function FormatDateForURL(dateStr) {
                var day = dateStr.getDate();
                var month = dateStr.getMonth() + 1;
                var year = dateStr.getFullYear();
                var minutes = dateStr.getMinutes();
                var hours = dateStr.getHours();
                if (day < 10)
                    day = "0" + day;
                if (hours < 10)
                    hours = "0" + hours;
                if (month < 10)
                    month = "0" + month;
                if (minutes < 10)
                    minutes = "0" + minutes;
                return year + "/" + month + "/" + day + " " + hours + ":" + minutes;
            }

            function getTemplateEndTime(templateId) {
                var selectedDate = $find('<%=StartTimePicker.ClientID%>').get_selectedDate();
                var startDate = FormatDateForURL(selectedDate);
                var obj = {};
                obj.templateId = templateId;
                obj.startDateTime = startDate;

                var obj = {};
                obj.templateId = templateId;
                obj.startDateTime = startDate;

                $.ajax({
                    type: "POST",
                    url: "../DiarySchedule.aspx/GetTemplateEnd",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {
                        $find('<%=EndTimePicker.ClientID%>').get_dateInput().set_value(data.d);
                    },
                    error: function (x, y, z) {
                        console.log(x.responseJSON.Message);
                    }
                });
            }

            function setEndTime(endtime) {
                if ($find('<%=EndTimePicker.ClientID%>') != null)
                    $find('<%=EndTimePicker.ClientID%>').get_dateInput().set_value(endtime);
            }


            function calculatePoints() {
            <%--var obj = {};
            obj.templateId = templateId;
            obj.startDateTime = $find('<%=StartTimePicker.ClientID%>').get_selectedDate();

            $.ajax({
                type: "POST",
                url: "DiaryPages.aspx/GetTemplateEnd",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function (data) {
                    $find('<%=EndTimePicker.ClientID%>').get_dateInput().set_value(data.d);
                },
                error: function (x, y, z) {
                    console.log(x.responseJSON.Message);
                }
            });--%>
            }

            function dropdown_changed(sender, args) {
                var GITemplate = true;
                var templateId = $find('<%=cbGenericTemplate.ClientID%>').get_value();
                var endoId = $find('<%=cbEndoscopist.ClientID%>').get_value();
                if (GITemplate == true && templateId > 0 && endoId > 0) {
                    var obj = {};
                    obj.endoID = endoId
                    obj.listRulesId = templateId;

                    $.ajax({
                        type: "POST",
                        url: "../DiarySchedule.aspx/ContainsEndoscopistProcedures",
                        data: JSON.stringify(obj),
                        dataType: "json",
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            if (data.d == false) {
                                alert('This template has procedures that your selected endoscopist cannot perform.');
                            }
                        }
                    });
                }
            }

            function showAddNewWindow(sender, args) {
                var oWnd = $find("<%= NewSlotRadWindow.ClientID%>");
                if (oWnd != null) {

                    $find('<%=SlotComboBox.ClientID%>').get_items().getItem(0).select();
                    $find('<%=ProcedureTypesComboBox.ClientID%>').get_items().getItem(0).select();
                    $find('<%=PointsRadNumericTextBox.ClientID%>').set_value(1);

                    //Mahfuz changed on 10 Oct 2021
                    $find('<%=SlotLengthRadNumericTextBox.ClientID%>').set_value(15);
                    $find('<%=SlotQtyRadNumericTextBox.ClientID%>').set_value(1);

                    oWnd.show();

                }
            }

            function closeAddNewWindow() {
                var oWnd = $find("<%= NewSlotRadWindow.ClientID%>");
                if (oWnd != null) {
                    oWnd.close();
                }
            }

            function CloseWindow() {
                GetRadWindow().close();
            }

            function GetRadWindow() {
                var oWindow = null; if (window.radWindow)
                    oWindow = window.radWindow; else if (window.frameElement.radWindow)
                    oWindow = window.frameElement.radWindow; return oWindow;
            }

            $(document).ready(function () {
                bindEvents();
                $('.repeat-pattern input').on('change', function () {
                    bindEvents();
                });
            });

            //$(document).ready(function () {
            //    $('.repeat-pattern input').on('change', function () {
            //        if ($('.repeat-pattern input:checked').val() == 'd') {
            //            $('.list-repeat-controls').show();
            //            $('.repeat-frequency').text('day(s)');
            //        }
            //        else if ($('.repeat-pattern input:checked').val() == 'w') {
            //            $('.list-repeat-controls').show();
            //            $('.repeat-frequency').text('week(s)');
            //        }
            //        else if ($('.repeat-pattern input:checked').val() == 'm') {
            //            $('.list-repeat-controls').show();
            //            $('.repeat-frequency').text('month(s)');
            //        }
            //        else if ($('.repeat-pattern input').val() == 'n') {
            //            $('.list-repeat-controls').hide();
            //        }
            //    });
            //
            //
            //});

            function bindEvents() {
                $('.monthlyfrequency').hide();

                if ($('.repeat-pattern input:checked').val() == 'd') {
                    $('.list-repeat-controls').show();
                    $('.repeat-frequency').text('day(s)');
                }
                else if ($('.repeat-pattern input:checked').val() == 'w') {
                    $('.list-repeat-controls').show();
                    $('.repeat-frequency').text('week(s)');
                }
                else if ($('.repeat-pattern input:checked').val() == 'm') {
                    $('.list-repeat-controls').show();
                    $('.monthlyfrequency').show();

                    //set month frequency
                    setMonthlyFrequency();

                    $('.repeat-frequency').text('month(s)');
                }
                else if ($('.repeat-pattern input').val() == 'n') {
                    $('.list-repeat-controls').hide();
                }
            }

            function CloseAndRebind() {
                GetRadWindow().BrowserWindow.reloadDiary();
                GetRadWindow().close();
            }

            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow; //Will work in Moz in all cases, including clasic dialog
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow; //IE (and Moz as well)

                return oWindow;
            }

            function setMonthlyFrequency() {
                var freqDay = '<%=ListStart.DayOfWeek.ToString()%>';

                var freqencyPeriod = String($find('<%=MonthFrequencyRadNumericTextBox.ClientID%>').get_value());
                if (freqencyPeriod != 11 && freqencyPeriod.split("").reverse().join("").substring(0, 1) == "1") {
                    $('#monthlyfrequencylabel').text('st ' + freqDay);
                }
                else if (freqencyPeriod != 12 && freqencyPeriod.split("").reverse().join("").substring(0, 1) == "2") {
                    $('#monthlyfrequencylabel').text('nd ' + freqDay);
                }
                else if (freqencyPeriod != 13 && freqencyPeriod.split("").reverse().join("").substring(0, 1) == "3") {
                    $('#monthlyfrequencylabel').text('rd ' + freqDay);
                }
                else {
                    $('#monthlyfrequencylabel').text('th ' + freqDay);
                }
            }

            function toggleSelectAll(source) {
                var grid = $find('<%= RecurringDatesRadGrid.ClientID %>');
                var masterTable = grid.get_masterTableView();
                var rows = masterTable.get_dataItems();

                for (var i = 0; i < rows.length; i++) {
                    var checkbox = rows[i].findElement("EditListCheckBox");
                    checkbox.checked = source.checked;
                }
            }

        </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="CustomEditFormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Position="Center" AutoCloseDelay="0" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="GenerateSlotButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="cbGenericTemplate">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="EndTimePicker" />
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SaveButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="chkShowCustom">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="cbGenericTemplate" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SlotsRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" />
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                        <telerik:AjaxUpdatedControl ControlID="EndTimePicker" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="OperatingHospitalDropdown">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="OperatingHospitalDropdown" />
                        <telerik:AjaxUpdatedControl ControlID="ProcedureTypesComboBox" />
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="TrainingCheckbox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="TrainingCheckbox" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="ProcedureTypesComboBox" />
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="ProcedureTypesComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ProcedureTypesComboBox" />
                        <telerik:AjaxUpdatedControl ControlID="PointsRadNumericTextBox" />
                        <telerik:AjaxUpdatedControl ControlID="SlotLengthRadNumericTextBox" />
                        <telerik:AjaxUpdatedControl ControlID="SlotQtyRadNumericTextBox" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="btnSaveAndApply">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <%--  <telerik:AjaxUpdatedControl ControlID="PointsRadNumericTextBox" />l
                       <telerik:AjaxUpdatedControl ControlID="ProcedureTypesComboBox" />
                        <telerik:AjaxUpdatedControl ControlID="SlotLengthRadNumericTextBox" />
                        <telerik:AjaxUpdatedControl ControlID="SlotQtyRadNumericTextBox" />
                        <telerik:AjaxUpdatedControl ControlID="SlotComboBox" />--%>
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                        <telerik:AjaxUpdatedControl ControlID="EndTimePicker" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="StartTimePicker">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="EndTimePicker" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

        <div class="rsDialog rsAdvancedEdit rsAdvancedModal" style="position: relative" id="CustomEditFormDiv">
            <asp:HiddenField ID="DiaryIdHiddenField" runat="server" />
            <asp:HiddenField ID="OperatingHospitalIdHiddenField" runat="server" />
            <div class="rsAdvTitle rsTitle">
                <div class="rsAdvInnerTitle">
                    <%-- The rsAdvInnerTitle element is used as a drag handle when the form is modal. --%>
                </div>
            </div>
            <%--  --%>
            <div class="rsAdvContentWrapper rsBody">
                <fieldset>
                    <legend>Select template</legend>
                    <div style="padding: 10px;">
                        <table style="width: 75%; height: 115px; margin-top: 10px;" class="new-list-table">
                            <tr>
                                <td style="vertical-align: top;">
                                    <label>List name:</label></td>
                                <td>
                                    <telerik:RadTextBox ID="ListNameRadTextBox" runat="server" autocomplete="off" MaxLength="15" />
                                    <asp:RequiredFieldValidator ID="rf1" runat="server" ControlToValidate="ListNameRadTextBox" ErrorMessage="*" ForeColor="Red" ValidationGroup="savetemplate" />
                                    &nbsp;<asp:CheckBox ID="chkIsTraining" runat="server" Text="Training" />

                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <label>List gender:</label></td>
                                <td>
                                    <telerik:RadComboBox ID="cbListGender" runat="server" AutoPostBack="false" Filter="StartsWith" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <label>Endoscopist:</label></td>
                                <td>
                                    <telerik:RadComboBox ID="cbEndoscopist" runat="server" OnClientSelectedIndexChanged="dropdown_changed" Filter="StartsWith" />
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="cbEndoscopist" ErrorMessage="*" ForeColor="Red" ValidationGroup="savetemplate" />

                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <label>List consultant:</label></td>
                                <td>
                                    <telerik:RadComboBox ID="cbListConsultant" runat="server" AutoPostBack="false" Filter="StartsWith" />
                                </td>
                            </tr>
                            <tr id="GenericTemplateTR" runat="server">
                                <td style="vertical-align: top;">
                                    <label>Template:</label></td>
                                <td>
                                    <telerik:RadComboBox ID="cbGenericTemplate" runat="server" Filter="StartsWith" OnItemDataBound="Template_ItemDataBound" AutoPostBack="true" OnClientSelectedIndexChanged="cbGenericTemplate_changed" OnSelectedIndexChanged="cbGenericTemplate_SelectedIndexChanged" />
                                    <asp:CheckBox ID="chkShowCustom" runat="server" Text="Show custom templates" OnCheckedChanged="chkShowCustom_CheckedChanged" AutoPostBack="true" />
                                </td>
                            </tr>
                            <tr>
                                <td style="vertical-align: top;">
                                    <label>Start time:</label></td>
                                <td>
                                    <table style="width: 70%;">
                                        <tr>
                                            <td>
                                                <telerik:RadTimePicker runat="server" ID="StartTimePicker" CssClass="rsAdvTimePicker" Width="70px" AutoPostBack="true" Skin="Metro" DateInput-ShowButton="false" OnSelectedDateChanged="StartTimePicker_SelectedDateChanged">
                                                    <DateInput ID="DateInput3" runat="server" />
                                                    <TimeView ID="TimeView1" runat="server" Columns="2" ShowHeader="false" StartTime="06:00"
                                                        EndTime="23:30" Interval="00:30" />
                                                </telerik:RadTimePicker>
                                            </td>
                                            <td>&nbsp;</td>
                                            <td>
                                                <label>End time:</label></td>
                                            <td>
                                                <telerik:RadTimePicker runat="server" ID="EndTimePicker" CssClass="rsAdvTimePicker" Width="70px" Skin="Metro" DateInput-ShowButton="false" Enabled="false">
                                                    <DateInput ID="DateInput1" runat="server" />
                                                    <TimeView ID="TimeView2" runat="server" Columns="2" ShowHeader="false" StartTime="06:00"
                                                        EndTime="23:30" Interval="00:30" />
                                                </telerik:RadTimePicker>
                                            </td>
                                        </tr>
                                    </table>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="StartTimePicker" ErrorMessage="Choose a start time" ForeColor="Red" ValidationGroup="savetemplate" Font-Size="Small" />

                                </td>
                            </tr>
                        </table>
                        <div class="list-slots" id="RecurringListsDiv" runat="server" visible="false">

                            <telerik:RadGrid ID="RecurringDatesRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="true" Width="650" Height="240" Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px;" ClientSettings-Scrolling-AllowScroll="true">
                                <HeaderStyle Font-Bold="true" />
                                <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="DiaryId" DataKeyNames="DiaryId, DiaryStart, DiaryEnd" TableLayout="Fixed" CssClass="recurring-list-table">
                                    <Columns>
                                        <telerik:GridTemplateColumn>
                                            <HeaderTemplate>
                                                <asp:CheckBox ID="SelectAllCheckBox" runat="server" onclick="toggleSelectAll(this)" />&nbsp;Select list(s)
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <asp:CheckBox ID="EditListCheckBox" runat="server" />
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                        <telerik:GridBoundColumn DataField="DiaryStart" HeaderText="List date" />
                                        <telerik:GridBoundColumn DataField="EndoscopistName" HeaderText="List Endoscopist" />
                                        <telerik:GridBoundColumn DataField="ListConsultant" HeaderText="List Consultant" />
                                        <telerik:GridBoundColumn DataField="ListGender" HeaderText="List Gender" />
                                    </Columns>
                                </MasterTableView>
                            </telerik:RadGrid>
                        </div>
                        <div class="list-slots" id="ListSlotsDiv" runat="server">
                            <table>
                                <tr>
                                    <td style="width: 11%;">
                                        <label>Repeat list:</label></td>
                                    <td style="padding-left: 15px;">
                                        <asp:RadioButtonList ID="RepeatPatternRadioButtonList" runat="server" RepeatDirection="Horizontal" TextAlign="Left" CssClass="repeat-pattern">
                                            <asp:ListItem Value="n" Selected="True">Never</asp:ListItem>
                                            <asp:ListItem Value="d">Daily</asp:ListItem>
                                            <asp:ListItem Value="w">Weekly</asp:ListItem>
                                            <asp:ListItem Value="m">Monthly</asp:ListItem>
                                        </asp:RadioButtonList>
                                    </td>
                                    <td class="monthlyfrequency">
                                        <label>Every</label>
                                        <telerik:RadNumericTextBox ID="MonthFrequencyRadNumericTextBox" runat="server" Value="1" CssClass="repeat-count"
                                            IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="1"
                                            Width="35px"
                                            MinValue="1">
                                            <NumberFormat DecimalDigits="0" />
                                            <ClientEvents OnValueChanged="setMonthlyFrequency" />
                                        </telerik:RadNumericTextBox><label id="monthlyfrequencylabel"></label>

                                    </td>
                                </tr>
                                <tr>
                                    <td></td>
                                    <td colspan="2">
                                        <div class="list-repeat-controls">
                                            &nbsp;<label>for</label>&nbsp;<telerik:RadNumericTextBox ID="RepeatCountTextBox" runat="server" Value="1" CssClass="repeat-count"
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="1"
                                                Width="35px"
                                                MinValue="1" MaxValue="52">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>&nbsp;<label class="repeat-frequency">weeks</label>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                            <div style="margin-top: 35px;">
                                <%--<uc1:listtemplateslots runat="server" id="ucListTemplateSlots" />--%>

                                <div style="float: left; margin-bottom: 15px;">
                                    <telerik:RadButton ID="GenerateSlotButton" runat="server" Text="Add slot" Skin="Metro" CausesValidation="true"
                                        OnClientClicked="showAddNewWindow" Icon-PrimaryIconCssClass="telerikGenerate" AutoPostBack="false" Enabled="true" />
                                </div>
                                <div style="float: right; margin-right: 5px; font-weight: bold; line-height: 20px; font-size: 12px;">
                                    <label>Total points:</label>&nbsp;<telerik:RadLabel ID="TotalPointsLabel" runat="server" Text="0" Skin="Metro" />
                                </div>
                                <div style="padding-bottom: 5px" class="gi-div">
                                    <div style="float: left; padding-right: 5px; height: 240px;">

                                        <telerik:RadGrid ID="SlotsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="true" Width="650" Height="240" Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px;"
                                            OnItemCommand="SlotsRadGrid_ItemCommand" OnItemDataBound="SlotsRadGrid_ItemDataBound">
                                            <HeaderStyle Font-Bold="true" />
                                            <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="LstSlotId" DataKeyNames="LstSlotId" TableLayout="Fixed" CssClass="list-slot-table">
                                                <Columns>
                                                    <telerik:GridBoundColumn DataField="LstSlotId" HeaderText="" HeaderStyle-Width="0px" ItemStyle-Width="0px" />
                                                    <telerik:GridTemplateColumn HeaderText="Slots" UniqueName="Slots">
                                                        <ItemTemplate>
                                                            <telerik:RadComboBox ID="SlotComboBox" CssClass="slot-combo-box" Width="90%" runat="server" DataSourceID="SlotStatusObjectDataSource" DataTextField="Description" DataValueField="StatusId" OnItemDataBound="SlotComboBox_ItemDataBound" SelectedValue='<%#Bind("SlotId")%>' />
                                                        </ItemTemplate>
                                                    </telerik:GridTemplateColumn>

                                                    <telerik:GridTemplateColumn HeaderText="Procedure (reserved for)" UniqueName="Guidelines" HeaderStyle-Width="190px">
                                                        <ItemTemplate>
                                                            <telerik:RadComboBox ID="GuidelineComboBox" CssClass="procedure-type-combo-box" DataSourceID="GuidelineObjectDataSource" OnSelectedIndexChanged="GuidelineComboBox_SelectedIndexChanged" AutoPostBack="false" OnClientSelectedIndexChanged="proceduretype_changed" runat="server" DataTextField="SchedulerProcName" DataValueField="ProcedureTypeId" SelectedValue='<%#Eval("ProcedureTypeId")%>' />

                                                        </ItemTemplate>
                                                    </telerik:GridTemplateColumn>
                                                    <telerik:GridTemplateColumn HeaderText="Points">
                                                        <ItemTemplate>
                                                            <telerik:RadNumericTextBox ID="PointsRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="0.5" Width="35px"
                                                                MinValue="0.5" MaxLength="3" MaxValue="1440" AutoPostBack="true" Value='<%#Convert.ToDecimal(Eval("Points")) %>' CssClass="slot-points" OnTextChanged="PointsRadNumericTextBox_TextChanged">
                                                                <NumberFormat DecimalDigits="1" />
                                                            </telerik:RadNumericTextBox>
                                                        </ItemTemplate>
                                                    </telerik:GridTemplateColumn>
                                                    <telerik:GridTemplateColumn HeaderText="Slot length">
                                                        <ItemTemplate>
                                                            <telerik:RadNumericTextBox ID="SlotLengthRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1" Width="35px"
                                                                MinValue="1" MaxLength="3" MaxValue="1440" Value='<%#CInt(Eval("Minutes")) %>' CssClass="slot-length" AutoPostBack="true" OnTextChanged="SlotLengthRadNumericTextBox_TextChanged">
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>
                                                        </ItemTemplate>
                                                    </telerik:GridTemplateColumn>
                                                    <telerik:GridTemplateColumn HeaderText="Blocked" UniqueName="Suppresse" HeaderStyle-Width="55px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" Visible="false">
                                                        <ItemTemplate>
                                                            <asp:CheckBox ID="SuppressedCheckBox" runat="server" Checked='<%#Bind("Suppressed")%>' />
                                                        </ItemTemplate>
                                                    </telerik:GridTemplateColumn>
                                                    <telerik:GridTemplateColumn HeaderText="Remove" UniqueName="Remove" HeaderStyle-Width="65px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                                        <ItemTemplate>
                                                            <asp:LinkButton ID="lnlRemoveSlot" runat="server" Text="Remove" CommandName="remove" />
                                                        </ItemTemplate>
                                                    </telerik:GridTemplateColumn>
                                                </Columns>
                                            </MasterTableView>
                                            <PagerStyle Mode="NextPrev" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; Patients {2} to {3} of {5}" />
                                            <ClientSettings>
                                                <Selecting AllowRowSelect="True" />
                                                <Scrolling AllowScroll="True" UseStaticHeaders="true" />
                                            </ClientSettings>
                                        </telerik:RadGrid>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </fieldset>
                <asp:Panel runat="server" ID="ButtonsPanel" CssClass="rsAdvButtonWrapper rsButtons">
                    <div class="buttons" style="margin-top: 10px; padding: 10px;">
                        <telerik:RadButton ID="SaveTemplateButton" runat="server" Text="Save" CssClass="buttonClass" OnClick="SaveTemplateButton_Click" Skin="Metro" ValidationGroup="savetemplate" />
                        &nbsp;
                <telerik:RadButton runat="server" ID="CancelButton" CssClass="rsAdvEditCancel rsButton buttonClass rwCloseButton" AutoPostBack="false"
                    CausesValidation="false" Text="Cancel" Skin="Metro" OnClientClicked="CloseWindow" />
                    </div>
                </asp:Panel>
            </div>
        </div>
        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move" ReloadOnShow="True">
            <Windows>
                <telerik:RadWindow ID="ListTemplateRadWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="340px" Height="150px" Skin="Metro" VisibleStatusbar="false" Animation="None">
                    <ContentTemplate></ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="NewSlotRadWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" AutoSize="true" Title="Add new slot" VisibleStatusbar="false" Modal="True">
                    <ContentTemplate>
                        <div style="padding: 15px;">
                            <table>
                                <tr>
                                    <td>Slot type</td>
                                    <td>Procedure</td>
                                    <td>Points</td>
                                    <td>Slot length</td>
                                    <td>Qty</td>
                                </tr>
                                <tr>
                                    <td>
                                        <telerik:RadComboBox ID="SlotComboBox" runat="server" DataSourceID="SlotStatusObjectDataSource" DataTextField="Description" DataValueField="StatusId" ZIndex="9999" />
                                    </td>
                                    <td>
                                        <telerik:RadComboBox ID="ProcedureTypesComboBox" DataSourceID="GuidelineObjectDataSource" AutoPostBack="false" runat="server" DataTextField="SchedulerProcName" DataValueField="ProcedureTypeId" ZIndex="99999" OnClientSelectedIndexChanged="proceduretype_changed" />
                                    </td>
                                    <td>
                                        <telerik:RadNumericTextBox ID="PointsRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false" CssClass="slot-points new-slot"
                                            IncrementSettings-Step="0.5" Width="35px"
                                            MinValue="0.5" MaxLength="3" MaxValue="1440">
                                            <NumberFormat DecimalDigits="1" />
                                        </telerik:RadNumericTextBox></td>
                                    <td>
                                        <telerik:RadNumericTextBox ID="SlotLengthRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false" CssClass="slot-length new-slot"
                                            IncrementSettings-Step="1" Width="35px"
                                            MinValue="1" MaxLength="3" MaxValue="1440">
                                            <NumberFormat DecimalDigits="0" />
                                        </telerik:RadNumericTextBox></td>
                                    <td>

                                        <telerik:RadNumericTextBox ID="SlotQtyRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="1" Width="35px"
                                            MinValue="1" MaxLength="3" MaxValue="1440">
                                            <NumberFormat DecimalDigits="0" />
                                        </telerik:RadNumericTextBox></td>
                                    <td>
                                        <telerik:RadButton ID="btnSaveAndApply" runat="server" Text="Add" OnClick="btnSaveAndApply_Click" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>


        <asp:ObjectDataSource ID="EndoscopistsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetEndoscopist">
            <SelectParameters>
                <asp:Parameter Name="isGIConsultant" Type="Boolean" DefaultValue="true" />
            </SelectParameters>
        </asp:ObjectDataSource>

        <asp:ObjectDataSource ID="SlotStatusObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetSlotStatus">
            <SelectParameters>
                <asp:Parameter Name="GI" DbType="Byte" DefaultValue="1" />
                <asp:Parameter Name="nonGI" DbType="Byte" DefaultValue="1" />
            </SelectParameters>
        </asp:ObjectDataSource>

        <asp:ObjectDataSource ID="GuidelineObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetGuidelines">
            <SelectParameters>
                <asp:Parameter Name="IsGI" Type="Byte" DefaultValue="1" />
                <asp:ControlParameter ControlID="OperatingHospitalIdHiddenField" Name="operatingHospital" PropertyName="Value" />
            </SelectParameters>
        </asp:ObjectDataSource>
    </form>
</body>
</html>
