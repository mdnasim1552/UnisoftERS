<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Common_PhotoMove" Codebehind="PhotoMove.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Move Photos</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {

        });

        $(window).on('load', function () {

        });

        function CloseWindow() {
            var oWnd = GetRadWindow();
            oWnd.close();
        }

        function GetRadWindow() {
            var oWindow = null;
            if (window.radWindow)
                oWindow = window.radWindow;
            else if (window.frameElement.radWindow)
            oWindow = window.frameElement.radWindow;
            return oWindow;
        }

        function triggerAttachMediaPage() {        
            var btn = $(window.parent.document).find('#AttachMediaBtn');
            btn.click();
        }

    </script>

    <style type="text/css">
        
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="SiteDetailsRadScriptManager" runat="server" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <div style="margin: 10px 5px;" class="text2" id="Div1" runat="server">
            <table>
                <tr>
                    <td>
                        <asp:Label ID="headerLabel" runat="server">Move photo to </asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <telerik:RadComboBox ID="SiteComboBox" runat="server" Skin="Windows7" Width="300"></telerik:RadComboBox>
                    </td>
                </tr>
                <tr>
                    <td style="height:10px;">
                        <asp:RadioButton ID="ProcedureRadioButton" runat="server" GroupName="Photo" Text="Attach to the procedure" Font-Size="Smaller" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <div id="cmdOtherData" style="height: 10px; padding-top: 6px;">
                            <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" />
                            <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicked="CloseWindow" />
                        </div>
                    </td>
                </tr>
            </table>
        </div>

    </form>
</body>
</html>
