<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="EditByHistory.aspx.vb" Inherits="UnisoftERS.EditByHistory" %>

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
</head>
<body>
    <form id="form1" runat="server">
        <div>

                <div>
        <telerik:RadScriptManager runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="formDiv" Skin="Metro" />
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

        <telerik:RadAjaxManager runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="EditHistoryListRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="EditHistoryListRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                        <telerik:AjaxUpdatedControl ControlID="bookingDetailsDiv" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadNotification ID="RadNotification1" runat="server" Skin="Metro" VisibleOnPageLoad="false" ShowCloseButton="true" AutoCloseDelay="0" />

        <telerik:RadGrid ID="EditHistoryListRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
            Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px; width: 100%;" >
            <MasterTableView HeaderStyle-Font-Bold="true" TableLayout="Fixed" CssClass="MasterClass">
                <Columns>
                    <telerik:GridBoundColumn HeaderText="Locked By" DataField="LockedBy" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="150" />
                    <telerik:GridBoundColumn HeaderText="Locked At" DataField="LockedAt" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="90" />
                    <telerik:GridBoundColumn HeaderText="Locked Out" DataField="LockedEnd" HeaderStyle-Height="0" AllowSorting="false"  HeaderStyle-Width="90" />
                   
                </Columns>
                <HeaderStyle Font-Bold="true" />
            </MasterTableView>
        </telerik:RadGrid>
    </div>

        </div>
    </form>
</body>
</html>
