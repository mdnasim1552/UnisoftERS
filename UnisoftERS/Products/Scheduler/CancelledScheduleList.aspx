<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="CancelledScheduleList.aspx.vb" Inherits="UnisoftERS.CancelledScheduleList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .cancelled-ScheduleList-details td span:first-child {
            font-weight: bold;
        }

        .cancelled-ScheduleList-details, .cancelled-ScheduleList-details table {
            width: 100%;
        }
    </style>

    <telerik:RadScriptBlock runat="server">

        <script type="text/javascript">
            function ScheduleListDetails() {
                var oWnd = $find("<%= ScheduleListDetailsWindow.ClientID %>");
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
        <div>
            <telerik:RadScriptManager runat="server" />
            <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="formDiv" Skin="Metro" />
            <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

            <telerik:RadAjaxManager runat="server">
                <AjaxSettings>
                    <telerik:AjaxSetting AjaxControlID="CancelledScheduleListRadGrid">
                        <UpdatedControls>
                            <telerik:AjaxUpdatedControl ControlID="CancelledScheduleListRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                            <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                            <telerik:AjaxUpdatedControl ControlID="bookingDetailsDiv" />
                        </UpdatedControls>
                    </telerik:AjaxSetting>
                </AjaxSettings>
            </telerik:RadAjaxManager>

            <telerik:RadNotification ID="RadNotification1" runat="server" Skin="Metro" VisibleOnPageLoad="false" ShowCloseButton="true" AutoCloseDelay="0" />
            <%--  <asp:Label class="divWelcomeMessage" ID="lblWelcomeMessage" runat="server" Text="Cancelled Schedule List" Style="margin-left: 15px;" />--%>
            <telerik:RadGrid ID="CancelledScheduleListRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px; width: 100%;" OnItemCommand="CancelledScheduleListRadGrid_ItemCommand">
                <MasterTableView HeaderStyle-Font-Bold="true" TableLayout="Fixed" CssClass="MasterClass">
                    <Columns>
                        <telerik:GridBoundColumn HeaderText="Start Time" DataField="DiaryStart" HeaderStyle-Height="0" AllowSorting="false" DataFormatString="{0:HH:mm}" HeaderStyle-Width="90" />
                        <telerik:GridBoundColumn HeaderText="End Time" DataField="DiaryEnd" HeaderStyle-Height="0" AllowSorting="false" DataFormatString="{0:HH:mm}" HeaderStyle-Width="90" />
                        <telerik:GridBoundColumn HeaderText="Endoscopist" DataField="EndoscopistName" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="150" />
                        <telerik:GridBoundColumn HeaderText="Consultant" DataField="ListConsultant" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="150" />
                        <telerik:GridBoundColumn HeaderText="Room Name" DataField="RoomName" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="100" />
                        <telerik:GridBoundColumn HeaderText="Reason" DataField="Reason" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="190" />
                        <telerik:GridTemplateColumn HeaderStyle-Width="50">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" Text="details" CommandArgument='<%#Eval("DiaryId") %>' />
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                    </Columns>
                    <HeaderStyle Font-Bold="true" />
                </MasterTableView>
            </telerik:RadGrid>
        </div>
        <telerik:RadWindowManager ID="ScheduleListRadWindowManager" runat="server" ShowContentDuringLoad="false"
            Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="ScheduleListDetailsWindow" runat="server" Height="420" Width="550" VisibleStatusbar="false" CssClass="rad-window-popup">
                    <ContentTemplate>
                        <div id="bookingDetailsDiv" runat="server">
                            <fieldset>
                                <legend>List Slot</legend>
                                <telerik:RadGrid ID="ListSlot" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                                    Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px; width: 100%;">
                                    <MasterTableView HeaderStyle-Font-Bold="true" TableLayout="Fixed" CssClass="MasterClass">
                                        <Columns>
                                            <telerik:GridBoundColumn HeaderText="Subject" DataField="Subject" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="150" />
                                            <telerik:GridBoundColumn HeaderText="Slot length" DataField="Minutes" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="50" />
                                            <telerik:GridBoundColumn HeaderText="Points" DataField="Points" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="50" />
                                        </Columns>
                                        <HeaderStyle Font-Bold="true" />
                                    </MasterTableView>
                                </telerik:RadGrid>
                                <div style="font-weight: bold; text-align: center">
                                    <asp:Label ID="SlotAddedDate" runat="server" Text="Booked by .... on ....." /></td>
                                </div>

                            </fieldset>
                            <fieldset>
                                <legend>Scheduled for</legend>
                                <table class="cancelled-ScheduleList-details">
                                    <tr>
                                        <td colspan="2" style="text-align: center; padding-bottom: 5px;">
                                            <asp:Label ID="ScheduleListDate" runat="server" /></td>
                                    </tr>
                          
                                    <tr>
                                        <td><span>List Name:</span>&nbsp;<asp:Label ID="lblListName" runat="server" /></td> <td style="text-align:end"><span>Start time:</span>&nbsp;<asp:Label ID="lblStartTime" runat="server"   /></td>
                                    </tr>
                                    <tr>
                                        <td><span>Endoscopist:</span>&nbsp;<asp:Label ID="lblEndoscopistName" runat="server" /></td>  <td style="text-align:end"><span>End time:</span>&nbsp;<asp:Label ID="lblEndTime" runat="server"  /></td>
                                    </tr>
                                    <tr>
                                        <td><span>Consultant:</span>&nbsp;
                                            <asp:Label ID="lblListConsultant" runat="server" Text="None" /></td>
                                    </tr>
                                    <tr>
                                        <td><span>Room:</span>&nbsp;<asp:Label ID="lblRoomName" runat="server" /></td>
                                    </tr>

                                </table>
                            </fieldset>
                            <fieldset>
                                <legend>Cancellation details</legend>
                                <table class="cancelled-ScheduleList-details">
                                    <tr>
                                        <td colspan="2" style="text-align: center; padding-top: 5px;">

                                            <asp:Label ID="lblScheduleListCancellationDetails" runat="server" /></td>
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
