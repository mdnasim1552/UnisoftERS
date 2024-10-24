<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="CancelledBookings.aspx.vb" Inherits="UnisoftERS.CancelledBookings" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../Styles/Site.css" rel="stylesheet" />

      <style type="text/css">
            .cancelled-booking-details td span:first-child{
                font-weight:bold;
            }

            .cancelled-booking-details, .cancelled-booking-details table{
                width:100%;
            }
        </style>
    <telerik:RadScriptBlock runat="server">
      
        <script type="text/javascript">
            function showCancelledBookingDetails() {
                var oWnd = $find("<%= BookingDetailsWindow.ClientID %>");
                if (oWnd != null) {
                    oWnd.set_title("Cancelled booking details");
                    oWnd.show();
                }
            }
        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager runat="server" />

        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="formDiv" Skin="Metro" />
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

        <telerik:RadAjaxManager runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="CancelledBookingsRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="CancelledBookingsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                        <telerik:AjaxUpdatedControl ControlID="bookingDetailsDiv" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <div id="formDiv">
            <telerik:RadNotification ID="RadNotification1" runat="server" Skin="Metro" VisibleOnPageLoad="false" ShowCloseButton="true" AutoCloseDelay="0" />

            <asp:Label class="divWelcomeMessage" ID="lblWelcomeMessage" runat="server" Text="Cancelled bookings" Style="margin-left: 15px;" />
            <div style="float: right">
                <asp:LinkButton ID="lnkShowFullDay" runat="server" Visible="false" Text="show full day"></asp:LinkButton>
            </div>
            <telerik:RadGrid ID="CancelledBookingsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px; width: 95%;" OnItemCommand="CancelledBookingsRadGrid_ItemCommand">
                <MasterTableView HeaderStyle-Font-Bold="true" TableLayout="Fixed" CssClass="MasterClass">
                    <Columns>
                        <telerik:GridBoundColumn HeaderText="Booking Time" DataField="BookingDate" HeaderStyle-Height="0" AllowSorting="false" DataFormatString="{0:HH:mm}" HeaderStyle-Width="90" />
                        <telerik:GridBoundColumn HeaderText="Procedure" DataField="ProcedureType" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="190" />
                        <telerik:GridTemplateColumn HeaderText="Patient Details" HeaderStyle-Width="190">
                            <ItemTemplate>
                                <asp:Label runat="server" Text='<%#Eval("PatientName") %>' />
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                        <telerik:GridBoundColumn HeaderText="Reason" DataField="Reason" HeaderStyle-Height="0" AllowSorting="false" />
                        <telerik:GridTemplateColumn HeaderStyle-Width="50">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" Text="details" CommandArgument='<%#Eval("AppointmentId") %>' />
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                    </Columns>
                    <HeaderStyle Font-Bold="true" />
                </MasterTableView>
            </telerik:RadGrid>
        </div>

        <telerik:RadWindowManager ID="AddNewTitleRadWindowManager" runat="server" ShowContentDuringLoad="false"
            Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="BookingDetailsWindow" runat="server" Height="500" Width="550" CssClass="rad-window-popup">
                    <%--this pops up OVER a radwindow, therefore has a different class in order to have a higher z-index--%>
                    <ContentTemplate>
                        <div id="bookingDetailsDiv" runat="server">
                            <fieldset>
                                <legend>Patient Details</legend>
                                <table class="cancelled-booking-details">
                                    <tr>
                                        <td>
                                            <span>Patient name:</span>&nbsp;
                                            <asp:Label ID="lblPatientName" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <span>Date of birth:</span>&nbsp;
                                            <asp:Label ID="lblPatientDOB" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <span>Hospital no:</span>&nbsp;<asp:Label ID="lblPatientCNN" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <span>Gender:</span>&nbsp;
                                            <asp:Label ID="lblPatientGender" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td style="padding-top: 15px;">
                                            <span>Endoscopist:</span>&nbsp;<asp:Label ID="lblEndoscopist" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" style="text-align:center; padding-top:5px;">
                                            <asp:Label ID="lblBookingAuditDetails" runat="server" Text="Booked by .... on ....." /></td>
                                    </tr>
                                </table>
                            </fieldset>
                            <fieldset>
                                <legend>Scheduled for</legend>
                                <table class="cancelled-booking-details">
                                    <tr>
                                        <td colspan="2" style="text-align:center; padding-bottom:5px;">
                                            <asp:Label ID="lblBookingScheduledDetails" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <table>
                                                <tr>
                                                    <td><span>Call-in time:</span>&nbsp;<asp:Label ID="lblCallInTime" runat="server" /></td>
                                                    <td><span>Start time:</span>&nbsp;<asp:Label ID="lblStartTime" runat="server" /></td>
                                                    <td><span>Length of slot:</span>&nbsp;<asp:Label ID="lblSlotLength" runat="server" /></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span>Procedure:</span>&nbsp;<asp:Label ID="lblProcedure" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td><span>Therapies:</span>&nbsp; <asp:Label ID="lblTherapies" runat="server" Text="None" /></td>
                                    </tr>
                                    <tr>
                                        <td><span>Patient status:</span>&nbsp;<asp:Label ID="lblPatientStatus" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td><span>Patient notes:</span>&nbsp;<asp:Label ID="lblPatientNotes" runat="server" /></td>
                                    </tr>
                                </table>
                            </fieldset>
                            <fieldset>
                                <legend>Cancellation details</legend>
                                <table class="cancelled-booking-details">
                                    <tr>
                                                                                <td colspan="2" style="text-align:center; padding-top:5px;">

                                            <asp:Label ID="lblBookingCancellationDetails" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td><span>Reason:</span>&nbsp;<asp:Label ID="lblCancellationReason" runat="server" /></td>
                                    </tr>
                                </table>
                            </fieldset>
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
    </form>
</body>
</html>
