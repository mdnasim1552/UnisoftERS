<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_License" Codebehind="License.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .RadUpload .ruFakeInput
         {
            width:360px!important;
         }
    </style>

    <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
        <script type="text/javascript">

            $(document).ready(function () {
                loader();
                $("#<%=LicenseCheckBoxList.ClientID%>").change(function(){
                    var r = $("#<%= LicenseCheckBoxList.ClientID%> input:radio:checked").val();
                    if (r == 1) {
                        $("#textDiv").show();
                        $("#fileDiv").hide();
                    } else if (r == 2) {
                        $("#textDiv").hide();
                        $("#fileDiv").show();
                    }
                });
            });
            function loader() {
                var r = $("#<%= LicenseCheckBoxList.ClientID%> input:radio:checked").val();
                if (r == 1) {
                    $("#textDiv").show();
                    $("#fileDiv").hide();
                } else if (r == 2) {
                    $("#textDiv").hide();
                    $("#fileDiv").show();
                }
            }
        </script>
    </telerik:RadCodeBlock>
</head>

<body>
    <script type="text/javascript">
    </script>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ControlsTable" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <div class="optionsHeading">Licence</div>

        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="860px" Orientation="Horizontal" Skin="Windows7" BorderSize="0" PanesBorderSize="0">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="580px">
                <table id="ControlsTable" runat="server" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px;" width="95%" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <fieldset>
                                <legend><b>Licence</b></legend>
                                <table cellpadding="6">
                                    <tr>
                                        <td style="width: 75px;">Start date:</td>
                                        <td>
                                            <asp:Label runat="server" ID="startLabel" /></td>
                                    </tr>

                                    <tr>
                                        <td>Expiry date:</td>
                                        <td>
                                            <asp:Label runat="server" ID="ExpireLabel" /></td>
                                    </tr>
                                    <tr>
                                        <td style="vertical-align: top;">Products:</td>
                                        <td>
                                            <asp:Label runat="server" ID="ProductLabel" /></td>
                                    </tr>
                                    <tr>
                                        <td>Version:</td>
                                        <td>
                                            <asp:Label runat="server" ID="VersionLabel" /></td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">Number of registered hospitals:
                                            <asp:Label runat="server" ID="HospitalsLabel" /></td>
                                    </tr>
                                </table>
                            </fieldset><br />
                            <fieldset>
                                <legend>Renew licence</legend>
                                <div>                                                          
                                    <asp:RadioButtonList ID="LicenseCheckBoxList" runat="server" RepeatDirection="Horizontal" CellPadding="10">
                                     <asp:ListItem Selected="True" Text="Copy licence key" Value="1" />
                                        <asp:ListItem   Text="Upload a licence file" Value="2" Enabled="false"/>                                      
                                   </asp:RadioButtonList>    
                                </div>
                                <div id="textDiv" style="padding-left:10px;">
                                    <telerik:RadTextBox runat ="server" ID="licenseRadTextBox" TextMode="MultiLine" Width="600px" Height="50px" Skin="Windows7"/><br /><br />
                                    <telerik:RadButton ID="applybutton1" runat="server" Text="Apply licence" OnClick="applybutton1_Click" Skin="Windows7" Width="100px" />
                                </div>
                                <div id="fileDiv" style="padding-left:10px;">
                                    <%--<telerik:RadAsyncUpload ID="RadAsyncUpload1" runat="server" AllowedFileExtensions=".ers" MaxFileInputsCount="1" PostbackTriggers="applybutton"  OnFileUploaded="RadAsyncUpload1_FileUploaded" Width="250px" Skin="Windows7"/><br />--%>
                                    <telerik:RadButton ID="applybutton" runat="server" Text="Apply licence"  Width="100px" Skin="Windows7"/>
                                </div>
                                <br />
                            </fieldset>
                        </td>
                    </tr>
                </table>
            </telerik:RadPane>
        </telerik:RadSplitter>
    </form>
</body>
</html>
