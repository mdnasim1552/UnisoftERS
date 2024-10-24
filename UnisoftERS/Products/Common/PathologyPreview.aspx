<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="PathologyPreview.aspx.vb" Inherits="UnisoftERS.PathologyPreview" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Pathology Preview</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/global.js"></script>

    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <link type="text/css" href="../../Styles/PrintReport.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {

        });

        function CloseWindow() {
            GetRadWindow().close();
        }

        function GetRadWindow() {
            var oWindow = null; if (window.radWindow)
                oWindow = window.radWindow; else if (window.frameElement.radWindow)
                oWindow = window.frameElement.radWindow; return oWindow;
        }

        $(window).on('load', function () {

        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="PrintRadScriptManager" runat="server" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <asp:ObjectDataSource ID="SummaryObjectDataSource" runat="server" SelectMethod="GetPathologyReportSpecimens" TypeName="UnisoftERS.DataAccess" />


        <div id="GPReportDiv" runat="server" style="width: 103%;">
            <table class="mainTable printFontBasic" cellpadding="0" cellspacing="0" style="line-height: 1;">
                <tr>
                    <td width="15%">Name:
                    </td>
                    <td width="35%">
                        <asp:Label ID="NameLabel" runat="server" Text="Not available" Font-Bold="true" /></td>
                    <td width="10%"></td>
                    <td width="20%">Address:
                    </td>
                    <td rowspan="4" valign="top" width="25%">
                        <asp:Label ID="AddressLabel" runat="server" Text="Not available" Font-Bold="true" /></td>
                </tr>
                <tr>
                    <td>Date of birth:
                    </td>
                    <td>
                        <asp:Label ID="DobLabel" runat="server" Text="Not available" Font-Bold="true" /></td>
                    <td></td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="lblNHSNo" runat="server" Text="NHS No" />:
                    </td>
                    <td>
                        <asp:Label ID="NhsNoLabel" runat="server" Text="Not available" Font-Bold="true" /></td>
                    <td></td>
                </tr>
                <tr>
                    <td valign="top">
                        <asp:Label ID="lblCaseNoteNo" runat="server" Text="Hospital no" />:
                    </td>
                    <td valign="top">
                        <asp:Label ID="CaseNoteNoLabel" runat="server" Text="Not available" Font-Bold="true" /></td>
                    <td></td>
                </tr>
                <tr>
                    <td colspan="5">
                        <hr style="height: 0.2px; border: none; color: black;" />
                    </td>
                </tr>
                <tr>
                    <td colspan="5">
                        <table class="mainTable printFontBasic">
                            <tr>
                                <td>Pathology Report Date:&nbsp;<asp:Label ID="PathologyReportDateLabel" runat="server" Text="Not available" Font-Bold="true" /></td>
                                <td align="right">Procedure Date<br />
                                    <asp:Label ID="ProcedureDateLabel" runat="server" Text="Not available" Font-Bold="true" /></td>
                            </tr>
                            <tr>
                                <td colspan="2">Labrotory Report Number:&nbsp;<asp:Label ID="LabReportNumberLabel" runat="server" Text="Not available" Font-Bold="true" /></td>

                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td style="height: 30px;"></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
                <tr>
                    <td colspan="5">
                        <table style="width: 100%;">
                            <tr>
                                <td valign="top" width="65%">
                                    <strong>Specimens Taken</strong>
                                    <asp:ListView ID="SummaryListView" runat="server" DataSourceID="SummaryObjectDataSource">
                                        <LayoutTemplate>
                                            <table>
                                                <tr id="itemPlaceholder" runat="server">
                                                </tr>
                                            </table>
                                        </LayoutTemplate>
                                        <ItemTemplate>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="SpecimenNameLabel" runat="server" Text='<%#Eval("Specimen") %>' />
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:ListView>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding-top: 20px;">
                                    <strong>Report</strong>
                                    <asp:Label ID="PathologyReportLabel" runat="server" />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
