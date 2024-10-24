<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="TherapeuticTypes.aspx.vb" Inherits="UnisoftERS.TherapeuticTypes" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript">
        function CloseWindow() {
            GetRadWindow().close();
        }

        function GetRadWindow() {
            var oWindow = null; if (window.radWindow)
                oWindow = window.radWindow; else if (window.frameElement.radWindow)
                oWindow = window.frameElement.radWindow; return oWindow;
        }
    </script>
</head>
<body>

    <form id="form1" runat="server">
        <telerik:RadScriptManager runat="server" />

        <telerik:RadFormDecorator runat="server" Skin="Metro" DecorationZoneID="FormDiv" DecoratedControls="All" />
        <div id="FormDiv">
            <div>
                <asp:CheckBoxList ID="TherapeuticTypesCheckBoxList" runat="server" RepeatColumns="2" RepeatDirection="Horizontal"
                    RepeatLayout="Table" CellPadding="5"
                    CellSpacing="5" OnDataBound="TherapeuticTypesCheckBoxList_DataBound" />
            </div>

        </div>
        <div id="ButtonsRadPane" runat="server" height="78px">
            <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Metro" Icon-PrimaryIconCssClass="telerikSaveButton" OnClick="SaveButton_Click" />
            <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Metro" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" AutoPostBack="False" OnClientClicking="CloseWindow" />
        </div>
    </form>
</body>
</html>
