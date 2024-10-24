<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="TherapeuticTypes.aspx.vb" Inherits="UnisoftERS.TherapeuticTypes" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../Styles/Site.css" rel="stylesheet" />
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
        <telerik:RadAjaxManager ID="TherapeuticTypesAjaxManager" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="ItemSelector">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="TherapeuticTypesCheckBoxList" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Position="TopCenter" />

        <telerik:RadFormDecorator runat="server" Skin="Metro" DecorationZoneID="FormDiv" DecoratedControls="All" />
        <div id="FormDiv" style="padding: 10px;">
            <telerik:RadSplitter ID="RadSplitter1" runat="server" Width="100%" Height="100%" Orientation="Horizontal" Skin="Windows7" PanesBorderSize="0" BorderSize="0" ResizeWithBrowserWindow="true"
                OnClientLoaded="SplitterLoaded">
                <telerik:RadPane ID="RadPane1" runat="server" Scrolling="Y"  Width="423px" Height="420" CssClass="toppane">

                    <div id="ItemSelectorRadPane" runat="server" height="78px">
                        <telerik:RadButton ID="ItemSelector" runat="server" Text="Toggle All On/Off " Skin="Metro" Icon-PrimaryIconCssClass="telerikSaveButton" OnClick="ItemSelector_Click" />
                    </div>

                    <div>
                        <asp:CheckBoxList ID="TherapeuticTypesCheckBoxList" runat="server" RepeatColumns="2" RepeatDirection="Vertical"
                            RepeatLayout="Table" CellPadding="3"
                            CellSpacing="3" OnDataBound="TherapeuticTypesCheckBoxList_DataBound" OnPreRender="TherapeuticTypesCheckBoxList_PreRender" />
                    </div>
                </telerik:RadPane>

                <telerik:RadPane ID="RadPane2" runat="server" Height="33" Scrolling="None">
                    <div id="cmdOtherData" runat="server" style="margin-left: 10px; height: 27px; padding-top:10px;">
                        <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Metro" Icon-PrimaryIconCssClass="telerikSaveButton" OnClick="SaveButton_Click" />
                        <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Metro" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" AutoPostBack="False" OnClientClicking="CloseWindow" />
                    </div>
                </telerik:RadPane>
            </telerik:RadSplitter>
        </div>
    </form>
</body>
</html>
