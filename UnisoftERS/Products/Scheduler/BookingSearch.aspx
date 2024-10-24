<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="BookingSearch.aspx.vb" Inherits="UnisoftERS.BookingSearch" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script src="../../Scripts/global.js"></script>

    <link href="../../Styles/Site.css" rel="stylesheet" />
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            function CloseWindow() {
                GetRadWindow().close();
            }

            function GetRadWindow() {
                var oWindow = null; if (window.radWindow)
                    oWindow = window.radWindow; else if (window.frameElement.radWindow)
                    oWindow = window.frameElement.radWindow; return oWindow;
            }

            function CloseAndRebind() {
                GetRadWindow().BrowserWindow.bookingFound();
                GetRadWindow().close();
            }

            function SizeToFit() {
                var oWnd = GetRadWindow();
                oWnd.SetWidth(document.body.scrollWidth + 15);
                oWnd.SetHeight(document.body.scrollHeight + 70);
            }

        </script>
    </telerik:RadScriptBlock>
</head>
<body onload="SizeToFit()" style="font-size: 12px !important; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif"> 
    <form id="form1" runat="server">
        <telerik:RadScriptManager runat="server" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Position="TopCenter" />
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="formDiv" Skin="Metro" />

        <div id="formDiv" style="min-width: 550px;">

            <div id="FindExistingBookingDiv" runat="server" style="overflow: hidden; width: 550px; height: 175px;">

                <div class="booking-search-filter" style="padding-top: 5px;">
                    <table cellpadding="2" cellspacing="2">
                        <tr>
                            <td><asp:label runat="server">Hospital number:</asp:label></td>
                            <td>
                                <telerik:RadTextBox ID="BookingSearchCNNTextBox" runat="server" /></td>
                        </tr>
                        <tr>
                            <td id="HealthServiceNameIdTd" runat="server"><span>NHS Number:</span></td>
                            <td>
                                <telerik:RadTextBox ID="BookingSearchNHSNoTextBox" runat="server" /></td>
                        </tr>
                        <tr>
                            <td><span>Surname:</span></td>
                            <td>
                                <telerik:RadTextBox ID="BookingSearchSurnameTextBox" runat="server" /></td>
                        </tr>
                        <tr>
                            <td><span>Forename:</span></td>
                            <td>
                                <telerik:RadTextBox ID="BookingSearchForenameTextBox" runat="server" /></td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <telerik:RadButton ID="SearchExistingBookingButton" runat="server" Text="Find" OnClick="SearchExistingBookingButton_Click" Skin="Metro" />
                                &nbsp;
                                    <telerik:RadButton ID="CancelSearchExistingBookingButtonButton" runat="server" Text="Cancel" Skin="Metro" OnClientClicked="CloseWindow" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div id="FoundBookingResultsDiv" runat="server" visible="false" style="padding-top: 10px; width: 750px;">
                <div style="margin-bottom: 10px;">Please choose from the list below</div>
                <telerik:RadGrid ID="FoundBookingsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                    Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px; width: 95%;" OnItemCommand="FoundBookingsRadGrid_ItemCommand">
                    <MasterTableView HeaderStyle-Font-Bold="true" TableLayout="Fixed" CssClass="MasterClass" DataKeyNames="RoomId,StartDateTime,HospitalId,AppointmentId">
                        <Columns>
                            <telerik:GridBoundColumn HeaderText="Patient Name" DataField="PatientName" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="175" />
                            <telerik:GridBoundColumn HeaderText="Booking Date" DataField="StartDateTime" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="150" />
                            <telerik:GridBoundColumn HeaderText="Procedure" DataField="ProcedureType" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="120" />
                            <telerik:GridBoundColumn HeaderText="Room" DataField="RoomId" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="60" Display="false"  />
                            <telerik:GridBoundColumn HeaderText="Room" DataField="RoomName" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="60" />
                            <telerik:GridBoundColumn HeaderText="Status" DataField="Status" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="70" />
                            <telerik:GridTemplateColumn>
                                <ItemTemplate>
                                    <asp:LinkButton ID="SelectPatientLinkButton" runat="server" Text="Select" CommandName="selectBooking" />
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                        </Columns>
                        <HeaderStyle Font-Bold="true" />
                    </MasterTableView>
                </telerik:RadGrid>
            </div>
        </div>
    </form>
</body>
</html>
