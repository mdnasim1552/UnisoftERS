<%@ Page Language="VB" AutoEventWireup="false" CodeBehind="NedExportConfig.aspx.vb" Inherits="UnisoftERS.NedExportConfig" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    
    <style type="text/css">
        #FormDiv {
            margin-left: 10px;
            width: 860px;
        }
    </style>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Windows7" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false"></telerik:RadNotification>
        <div>
            <div class="optionsHeading">National Data Set Export options</div>

            <div id="FormDiv" runat="server" style=""  class="optionsBodyText">
               <fieldset class="sysFieldset" style="margin-top: 2em; padding: 1em;">
                    <legend><b>Upload options</b></legend>
                    <table>
                        <tr>
                            <td style="width: 200px"><asp:Label Text="Organisation code" runat="server" for="OrganisationCodeTextBox" /></td>
                            <td style="width: 300px"><telerik:RadTextBox runat="server" ID="OrganisationCodeTextBox" Width="100px" Skin="Office2007"/></td>
                        </tr>
                        <tr>
                            <td><asp:Label Text="Organisation API key" for="APIKeyTextBox" runat="server" /></td>
                            <td><telerik:RadTextBox runat="server" ID="APIKeyTextBox" Width="300px" Skin="Office2007"/></td>
                        </tr>
                        <tr>
                            <td><asp:Label Text="Batch ID" for="BatchIdTextBox" runat="server" /></td>
                            <td><telerik:RadTextBox runat="server" ID="BatchIdTextBox" Width="100px" Skin="Office2007"/></td>
                        </tr>
                    </table>
                </fieldset>

                <div class="divButtons" style="margin-top: 40px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Metro" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Metro" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </div>
        </div>
    </form>
</body>
</html>
