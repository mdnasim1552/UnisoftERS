<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_ExportSettings" Codebehind="ExportSettings.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        
    </style>

    <script type="text/javascript">
        $(window).on('load', function () {

        });

        $(document).ready(function () {

        });
    </script>
</head>

<body>
    <script type="text/javascript">
    </script>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <div class="optionsHeading">Export Settings</div>

        <div style="margin-top:20px;margin-left:20px;" class="optionsHeading2">Under Construction</div>

        <div class="rptText" style="margin: 10px 12px;">
                            <table id="tableExportOptions" runat="server" cellspacing="1" cellpadding="0" border="0">
                                <tr style="vertical-align: top;">
                                    <td>
                                        <telerik:RadTreeView ID="rtvExportOptions" runat="server" Skin="Office2010Silver" BorderWidth="1" Width="140" Height="440" BorderColor="#c0c0c0">
                                            <Nodes>
                                                <telerik:RadTreeNode Text="Export Options" Expanded="true" Selected="true" Font-Bold="true">
                                                    <Nodes>
                                                        <telerik:RadTreeNode Text="Filename" />
                                                        <telerik:RadTreeNode Text="Fields" />
                                                    </Nodes>
                                                </telerik:RadTreeNode>
                                                <telerik:RadTreeNode Text="Report Log" Font-Bold="true" />
                                            </Nodes>
                                        </telerik:RadTreeView>
                                    </td>
                                    <td style="width: 100%;">
                                        <div class="optHeaderText">Options</div>
                                        <div style="margin-left: 10px;">
                                            <table id="tableOptions" runat="server" cellspacing="3" cellpadding="0" border="0">
                                                <tr>
                                                    <td style="width: 80px;">Profile</td>
                                                    <td>
                                                        <telerik:RadComboBox ID="cboProfile" runat="server" Skin="Windows7">
                                                            <Items>
                                                                <telerik:RadComboBoxItem Text="Default" />
                                                                <telerik:RadComboBoxItem Text="Export2EDT" Selected="true" />
                                                            </Items>
                                                        </telerik:RadComboBox>
                                                    </td>
                                                    <td>
                                                        <telerik:RadButton ID="cmdCreateProfile" runat="server" Text="Create profile" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>File type</td>
                                                    <td colspan="2">
                                                        <telerik:RadComboBox ID="cboFileType" runat="server" Skin="Windows7" Width="200">
                                                            <Items>
                                                                <telerik:RadComboBoxItem Text="Comma separated values (CSV)" />
                                                                <telerik:RadComboBoxItem Text="Portable document format (PDF)" Selected="true" />
                                                            </Items>
                                                        </telerik:RadComboBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Export Path</td>
                                                    <td colspan="2">
                                                        <telerik:RadTextBox ID="txtExportPath" runat="server" Width="250" Skin="Office2007" Text="C:\Temp\" /></td>
                                                </tr>
                                            </table>
                                            <table id="tableOptionSettings" runat="server" cellspacing="3" cellpadding="0" border="0">
                                                <tr style="vertical-align: middle;">
                                                    <td style="width: 150px;">Include field names?</td>
                                                    <td>
                                                        <asp:RadioButton ID="optNo" runat="server" GroupName="optInclFieldNames" Text="No (Default)" Checked="true" />&nbsp;&nbsp;<asp:RadioButton ID="optYes" runat="server" GroupName="optInclFieldNames" Text="Yes" /></td>
                                                </tr>
                                                <tr style="vertical-align: top;">
                                                    <td>Display notification message after each export?</td>
                                                    <td>
                                                        <asp:RadioButton ID="optMsgNo" runat="server" GroupName="optDisplayMsg" Text="No (Default)" Checked="true" />&nbsp;&nbsp;<asp:RadioButton ID="optMsgYes" runat="server" GroupName="optDisplayMsg" Text="Yes" /></td>
                                                </tr>
                                                <tr style="vertical-align: middle;">
                                                    <td>If fields are empty?</td>
                                                    <td>
                                                        <telerik:RadComboBox ID="cboFieldsBlank" runat="server" Skin="Windows7">
                                                            <Items>
                                                                <telerik:RadComboBoxItem Text="Leave blank" Selected="true" />
                                                            </Items>
                                                        </telerik:RadComboBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
</form>
</body>
</html>