<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="DrillDown.aspx.vb" Inherits="UnisoftERS.DrillDown" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
     
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/global.js"></script>

</head>
<body>
    <form id="form1" runat="server">
        <div>
    <telerik:RadSkinManager ID="RadSkinManager1" runat="server" Skin="Office2010Blue" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Metro" />
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Metro" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>" ForeColor="Red" Position="Center" />

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true">
    </telerik:RadAjaxLoadingPanel>
            <asp:ScriptManager ID="ScriptManager1" runat="server" />  
            <telerik:RadGrid RenderMode="Lightweight" ID="RadGrid1" runat="server" Skin="Office2010Blue" 
                Font-Size="Small" Width="100%" Height="100%">
                <MasterTableView CommandItemDisplay="Top" CommandItemStyle-BackColor="lightblue"  CommandItemStyle-Font-Bold="true">
                    <CommandItemSettings ShowExportToExcelButton="true" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
                </MasterTableView>
                <ClientSettings>           
                    <Resizing AllowColumnResize="true" ResizeGridOnColumnResize="true" AllowResizeToFit="true" />            
                </ClientSettings>
            </telerik:RadGrid>
        </div>
    </form>
    <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
        <script>
            function pageLoad() {
                var grid = $find("<%= RadGrid1.ClientID %>");
                var columns = grid.get_masterTableView().get_columns();
                for (var i = 0; i < columns.length; i++) {
                    columns[i].resizeToFit();
                }
            }
        </script>
    </telerik:RadCodeBlock>
</body>
</html>
