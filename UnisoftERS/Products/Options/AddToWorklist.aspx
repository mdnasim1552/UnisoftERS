<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="AddToWorklist.aspx.vb" Inherits="UnisoftERS.AddToWorklist" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Add patient to worklist</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style>
        body {
            font-family: "Helvetica Neue", "Lucida Grande", "Segoe UI", Arial, Helvetica, Verdana, sans-serif, Tahoma;
            font-size: 11px;
            color: black;
        }

        .RadWindow .rwIcon:before {
            display: none;
        }
    </style>

    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            $(document).ready(function () {
                $('#<%=btnStartDateTimeNow.ClientID%>').on('click', function () {
                    startdatetimenow();
                });
                $('#<%=ProcedureStartRadTimePicker.ClientID%>').on('focusout', function () {
                    updateProcedureTimings();
                });
            });
            function updateProcedureTimings() {
                var startDate = $find('<%=ProcedureDateRadDatePicker.ClientID%>').get_selectedDate();
                var startTime = $find('<%=ProcedureStartRadTimePicker.ClientID%>').get_timeView().getTime();

                //var endDate = $find('ProcedureEndDateRadTimeInput.ClientID%>').get_selectedDate();
                //var endTime = $find('ProcedureEndRadTimePicker.ClientID%>').get_timeView().getTime();

                if (startTime != null) {
                    //join controls to make datetime 
                    startDate.setHours(startTime.getHours());
                    startDate.setMinutes(startTime.getMinutes());
                }
                else {
                    startDate = null;
                }

                //if (endTime != null) {
                //    //join controls to make datetime
                //    endDate.setHours(endTime.getHours());
                //    endDate.setMinutes(endTime.getMinutes());
                //}
                //else {
                //    endDate = null;
                //}

               <%-- var obj = {};
                obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
                obj.procedureTypeId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_TYPE)%>);
                obj.startDateTime = startDate;
                obj.endDateTime = endDate;--%>


                <%--$.ajax({
                    type: "POST",
                    url: "../Procedure.aspx/saveProcedureTimings",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {
                        setRehideSummary();

                        if ($('.withdrawal-time').length > 0) {
                            var withdrawalTime = $find($('.withdrawal-time')[0].id);
                            if (data.d > 0 && withdrawalTime.get_value() == '')
                                withdrawalTime.set_value(data.d);
                        }
                    },
                    error: function (x, y, z) {
                        autoSaveSuccess = false;
                        //show a message
                        var objError = x.responseJSON;
                        var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                        $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                        $find('<%=RadNotification1.ClientID%>').show();
                    }
                });--%>

            }
            function startdatetimenow() {
                var currentdate = new Date();

                $find('<%=ProcedureDateRadDatePicker.ClientID%>').set_selectedDate(currentdate);
                var hours = currentdate.getHours();

                var timeView = $find('<%=ProcedureStartRadTimePicker.ClientID%>').get_timeView()
                if (timeView != null) {
                    timeView.setTime(hours,
                        currentdate.getMinutes(),
                        currentdate.getSeconds(),
                        currentdate);
                }


                //updateProcedureTimings();
            }

        </script>
    </telerik:RadScriptBlock>

</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadNotification ID="RadNotification1" runat="server" Animation="None"
            EnableRoundedCorners="true" EnableShadow="true" Title="Please correct the following"
            LoadContentOn="PageLoad" TitleIcon="delete" Position="Center"
            Skin="Metro">
            <ContentTemplate>
                <div id="valDiv" runat="server" class="aspxValidationSummary">
                </div>
                <div>
                    <telerik:RadButton ID="YesContinueButton" runat="server" Text="Yes" />
                    <telerik:RadButton ID="NoCloseButton" runat="server" Text="No" OnClick="NoCloseButton_Click" />
                </div>
            </ContentTemplate>
        </telerik:RadNotification>
        <telerik:RadFormDecorator runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadScriptManager ID="RadScriptManager" runat="server" />
        <div id="FormDiv">
            <fieldset>
                <legend>Patient Details</legend>
                <table style="width: 100%;">
                    <tr>
                        <td style="width: 10%;">
                            <asp:Label ID="NameLabel" runat="server" Text="Name:" />&nbsp;
                        </td>
                        <td style="width: 50%;">
                            <asp:Label ID="PatientNameLabel" runat="server" ForeColor="#0072c6" />
                        </td>
                        <td style="width: 20%;">
                            <asp:Label ID="DOBLabel" runat="server" Text="Date of birth:" />&nbsp;
                        </td>
                        <td style="width: 20%;">
                            <asp:Label ID="PatientDOBLabel" runat="server" ForeColor="#0072c6" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="AddressLabel" runat="server" Text="Address:" />&nbsp;
                        </td>
                        <td>
                            <asp:Label ID="PatientAddressLabel" runat="server" ForeColor="#0072c6" />
                        </td>
                        <td>
                            <asp:Label ID="CNNLabel" runat="server" Text="Hospital number:" />&nbsp;
                        </td>
                        <td>
                            <asp:Label ID="PatientCaseNoteNoLabel" runat="server" ForeColor="#0072c6" />
                        </td>
                    </tr>
                </table>
            </fieldset>
            <fieldset>
                <legend>Details</legend>
                <table>
                    <tr>
                        <td>Room:</td>
                        <td colspan="2">
                            <telerik:RadComboBox ID="RadComboRoomBox" AppendDataBoundItems="true" runat="server" AutoPostBack="false">
                                <%--<Items>
                                    <telerik:RadComboBoxItem Text="Any" Value="0" Selected="true" />
                                </Items>--%>
                            </telerik:RadComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td>Date:</td>
                        <td>
                            <telerik:RadDatePicker ID="ProcedureDateRadDatePicker" runat="server" Width="100" DisplayDateFormat="dd/MM/yyyy" OnClientDateChanged="updateProcedureTimings" MinDate='<%# DateTime.Now.Date() %>' />
                            <telerik:RadTimePicker ID="ProcedureStartRadTimePicker" runat="server" Enabled="true" DateInput-OnClientDateChanged="updateProcedureTimings" Width="75px" />
                            <telerik:RadButton ID="btnStartDateTimeNow" runat="server" Text="Now" AutoPostBack="false" Visible="false" />
                        </td>
                    </tr>
                    <tr>
                    </tr>
                    <tr>
                        <td>Endoscopist:</td>
                        <td colspan="2">
                            <telerik:RadComboBox ID="EndoscopistComboBox" AppendDataBoundItems="true" runat="server" DataTextField="EndoName" DataValueField="UserID" AutoPostBack="false">
                                <Items>
                                    <telerik:RadComboBoxItem Text="Any" Value="0" Selected="true" />
                                </Items>
                            </telerik:RadComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td valign="top">Procedure:</td>
                        <td colspan="2">
                            <asp:CheckBoxList ID="ProcedureTypesCheckBoxList" runat="server" RepeatLayout="Table" RepeatColumns="4" RepeatDirection="Horizontal">
                            </asp:CheckBoxList>
                        </td>
                    </tr>
                </table>
            </fieldset>

            <div style="height: 10px; margin-top: 10px; margin-left: 10px; padding-top: 6px;">
                <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Metro" Icon-PrimaryIconCssClass="telerikSaveButton" OnClick="SaveButton_Click" />
                <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Metro"
                    AutoPostBack="false" Icon-PrimaryIconCssClass="telerikCancelButton" OnClientClicked="CloseWindow" />
            </div>
        </div>
        <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
            <script type="text/javascript">
                function CloseWindow() {
                    GetRadWindow().close();
                }

                function CloseAndUpdate(args) {
                    GetRadWindow().BrowserWindow.updateWorklist(args);
                    GetRadWindow().close();

                }
                function CloseAndRebind(args) {
                    GetRadWindow().BrowserWindow.refreshWorklist(args);
                    GetRadWindow().close();
                }

                function GetRadWindow() {
                    var oWindow = null;
                    if (window.radWindow) oWindow = window.radWindow; //Will work in Moz in all cases, including clasic dialog
                    else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow; //IE (and Moz as well)

                    return oWindow;
                }
            </script>
        </telerik:RadCodeBlock>
    </form>
</body>
</html>
