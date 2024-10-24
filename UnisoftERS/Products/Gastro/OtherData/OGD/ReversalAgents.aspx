<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="ReversalAgents.aspx.vb" Inherits="UnisoftERS.ReversalAgents" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Reversal Agents</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" Visible="False" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />

    <script type="text/javascript">
        function SizeToFit() {
            var oWnd = GetRadWindow();
            //oWnd.SetWidth(document.body.scrollWidth + 4);
            //oWnd.SetHeight(document.body.scrollHeight + 70);
            oWnd.SetWidth(600);
            oWnd.SetHeight(300);
        }
    </script>
    <style type="text/css">
        body {
            font-family: "Segoe UI",Arial,Helvetica,sans-serif;
            font-size: 12px;
        }
        #MaximumDoseLimitCrossRadWindow_C{
            width: 412px !important;
            height: 158px !important;
        }
        #RadWindowWrapper_MaximumDoseLimitCrossRadWindow{
            width: 417px !important;
        }
    </style>

</head>
<body onload="SizeToFit()">
    <form id="form1" runat="server">
        <asp:HiddenField runat="server" ID="selectedProcedureId" Value="123" ClientIDMode="Static" />
        <asp:HiddenField runat="server" ID="selectedProcedureType" Value="UPPERGI, PROCT" ClientIDMode="Static" />
        <asp:HiddenField runat="server" ID="selectedNodeText" Value="123" ClientIDMode="Static" />

        <telerik:RadScriptManager ID="ReversalAgentsRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="ReversalAgentsRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="MedsDiv" Skin="Metro" />
        <table id="MedsDiv" style="width: 450px;">
            <tr>
                <td>
                    <fieldset>
                        <legend>Reversal agents administered</legend>
                        <table id="tablePostMed" runat="server" cellspacing="10" cellpadding="0" border="0" />
                    </fieldset>
                </td>
            </tr>
            <tr>
                <td>
                    <div style="height: auto; text-align: center; padding-top: 10px;">
                        <telerik:RadButton ID="SaveReversalAgentsRadButton" runat="server" Text="Save" Skin="Metro" OnClick="SaveReversalAgentsRadButton_Click" Icon-PrimaryIconCssClass="telerikSaveButton" />
                        <telerik:RadButton ID="CancelSaveReversalAgentsRadButton" runat="server" Text="Cancel" Skin="Metro" AutoPostBack="false" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"  />
                    </div>
                </td>
            </tr>
        </table>
        <telerik:RadWindowManager ID="RadWindowManager3" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move, Resize" Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="MaximumDoseLimitCrossRadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Height="200px" VisibleStatusbar="false" VisibleOnPageLoad="false" Title="Limit Cross" BackColor="#ffffcc" Left="100px">
                    <ContentTemplate>
                        <table width="100%">
                            <tr>
                                <td style="vertical-align: top; padding-left: 20px; padding-top: 40px">
                                    <img id="Img1" runat="server" src="~/Images/info-24x24.png" alt="icon" />
                                </td>
                                <td style="text-align: center; padding-top: 20px; height: 75px; overflow-y: auto">
                                    <asp:Label ID="lblMessage" runat="server" Font-Size="medium" Text="Do you wish to continue?" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td style="padding: 10px; text-align: center;">
                                    <telerik:RadButton ID="ContinueRadButton" runat="server" Text="Continue" Skin="Windows7" ButtonType="SkinnedButton" Font-Size="Large" AutoPostBack="true" Style="margin-right: 20px;" OnClick="ContinueRadButton_Click" />
                                    <telerik:RadButton ID="CancelRadButton" runat="server" Text="Cancel" Skin="Windows7" ButtonType="SkinnedButton" AutoPostBack="false" OnClientClicked="closeMaximumDoseLimitCrossRadWindow" Font-Size="Large" />
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
    </form>
    <telerik:RadScriptBlock ID="RadScriptBlock11" runat="server">
        <script type="text/javascript">
            function dosageChanged(sender, args) {
                var elemId = sender.get_element().id;
                var chkDosage = elemId.replace('txtDosage', 'PreMedChkBox');
                var v = sender.get_value();
                if (v > 0) {
                    $(document.getElementById(chkDosage)).prop("checked", true);
                } else {
                    $(document.getElementById(chkDosage)).prop("checked", false);
                }
            }

            function setDefaultValue(sender, args) {
                var elemId = sender.id;
                var hfDefDosage = elemId.replace('PreMedChkBox', 'hfDefDosage');
                var txtDosage = elemId.replace('PreMedChkBox', 'txtDosage');

                if (document.getElementById(elemId).checked) {
                    if (document.getElementById(txtDosage) != null) {
                        document.getElementById(txtDosage).value = document.getElementById(hfDefDosage).value;
                    }
                } else {
                    if (document.getElementById(txtDosage) != null) {
                        document.getElementById(txtDosage).value = "";
                    }
                }
            }

            function closeMaximumDoseLimitCrossRadWindow() {
                var window = $find('<%=MaximumDoseLimitCrossRadWindow.ClientID%>');
                window.close();
            }
        </script>
    </telerik:RadScriptBlock>
</body>
</html>
