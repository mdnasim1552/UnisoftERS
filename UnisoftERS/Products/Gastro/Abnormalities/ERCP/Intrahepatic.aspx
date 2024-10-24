<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Intrahepatic.aspx.vb" Inherits="UnisoftERS.Intrahepatic" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .SiteDetailsForm {
            font-size: 12px;
            font-family: "Segoe UI",Arial,Helvetica,sans-serif;
            color: black;
        }

            .SiteDetailsForm td {
                padding-bottom: 10px;
            }

        .rblType td {
            border: none;
            padding-left: 0px;
        }

        .rblType label {
            margin-right: 20px;
        }

        div.RadToolBar_Horizontal .rtbSeparator {
            width: 20px;
            background: none;
            border: none;
        }

        .divChildControl {
            float: left;
            margin-left: 30px;
        }
    </style>
    <telerik:RadScriptBlock runat="server">

        <script type="text/javascript">
            var IntrahepaticERCPValueChanged = false;
            var AddNewItemRadTextBoxClientId = "<%= AddNewItemRadTextBox.ClientID %>";
            var AddNewItemRadWindowClientId = "<%= AddNewItemRadWindow.ClientID %>";

            $(window).on('load', function () {
                $('input[type="checkbox"]').each(function () {
                    ToggleTRs($(this));
                });

                //ToggleBiliaryDivs();

            });

            $(document).ready(function () {
                $("#IntrahepaticTable tr td:first-child input:checkbox").change(function () {
                    ToggleTRs($(this));
                    IntrahepaticERCPValueChanged = true;
                });

                $("#D198P2_CheckBox").change(function () {
                    ToggleNormalCheckBox($(this).is(':checked'));
                    IntrahepaticERCPValueChanged = true;
                });
                //Added by rony tfs-4166;
                $(window).on('beforeunload', function () {
                    if (IntrahepaticERCPValueChanged) {
                        $('#<%=SaveButton.ClientID%>').click(); 
                        valueChanged();
                    }
                });
                $(window).on('unload', function () {
                    localStorage.clear();
                    setRehideSummary();
                });
            });

            function valueChanged() {
                var valueToSave = false;
                $("#IntrahepaticTable tr td:first-child").each(function () {
                    if ($(this).find("input:checkbox").is(':checked')) valueToSave = true;
                });
                if (!$('#D198P2_CheckBox').is(':checked') && !valueToSave)
                    localStorage.setItem('valueChanged', 'false');
                else
                    localStorage.setItem('valueChanged', 'true');
            }

            function CloseWindow() {
                window.parent.CloseWindow();
            }
             //changed by mostafiz issue 3647
            function ToggleTRs(chkbox) {
                if (chkbox[0].id != "D198P2_CheckBox") {
                    var checked = chkbox.is(':checked');
                    if (checked) {
                        $("#D198P2_CheckBox").prop('checked', false);
                    }
                    chkbox.closest('td')
                        .nextUntil('tr').each(function () {
                            if (checked) {
                                $(this).show();
                            }
                            else {
                                $(this).hide();
                                ClearControls($(this));
                            }
                        });
                    var subRows = chkbox.closest('td').closest('tr').attr('hasChildRows');
                    if (typeof subRows !== typeof undefined && subRows == "1") {
                        chkbox.closest('tr').nextUntil('tr [headRow="1"]').each(function () {
                            if (checked) {
                                $(this).show();
                            }
                            else {
                                $(this).hide();
                                ClearControls($(this));
                            }
                        });
                    }
                }
            }
             //changed by mostafiz issue 3647
            function ToggleNormalCheckBox(checked) {
                if (checked) {
                    $("#IntrahepaticTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox:checked").prop('checked', false);
                        $(this).find("input:checkbox").trigger("change");
                    });
                }
            }
             //changed by mostafiz issue 3647
            function ClearControls(tableCell) {
                tableCell.find("input:radio:checked").prop('checked', false);
                tableCell.find("input:checkbox:checked").prop('checked', false);
                tableCell.find("input:text").val("");
            }
        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            function savePage() {
                $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest();
            }            

        </script>
    </telerik:RadScriptBlock>  
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="DuctRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="DuctRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">
            <asp:Label ID="HeadingLabel" runat="server" Text="Intrahepatic"></asp:Label>
        </div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="560px" Width="95%">
                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">
                            <table id="IntrahepaticTable" class="rgview" cellpadding="0" cellspacing="0" style="width: 780px;">
                                <colgroup>
                                    <col>
                                    <col>
                                    <col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th width="260px" class="rgHeader" style="text-align: left; padding-left: 6px;">
                                            <asp:CheckBox ID="D198P2_CheckBox" runat="server" Text="Normal ducts" />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>
                                            <asp:CheckBox ID="D210P2_CheckBox" runat="server" Text="Suppurative cholangitis" />
                                            <%-- SuppurativeCheckBox--%>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:CheckBox ID="D220P2_CheckBox" runat="server" Text="Biliary leak" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 0px 0px 0px 0px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none; width: 70px;">
                                                        <asp:CheckBox ID="TumourCheckBox" runat="server" Text="Tumour" />
                                                    </td>
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="D242P2_CheckBox" runat="server" Text="probable" />
                                                        <%-- IntrahepaticTumourProbableCheckBox--%>
                                                                                        &nbsp;&nbsp;&nbsp;
                                                                                        <asp:CheckBox ID="D243P2_CheckBox" runat="server" Text="possible" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                     <tr id="IntrahepaticStonesRow" runat="server" >
                                        <td style="padding: 0px 0px 0px 0px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="IntrahepaticStonesCheckBox" runat="server" Text="Intrahepatic stones" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr runat="server" visible="false">
                                        <td style="padding: 0px 0px 0px 0px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="OtherCheckBox" runat="server" Text="Other" />
                                                    </td>
                                                    <td style="border: none;">
                                                        <telerik:RadTextBox ID="OtherTextBox" runat="server" Width="500px" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;display:none;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="WebBlue" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="WebBlue" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        <telerik:RadWindowManager ID="RadMan" runat="server" Modal="true" Animation="Fade" KeepInScreenBounds="true" Behaviors="Close" Skin="Metro" VisibleStatusbar="false" VisibleOnPageLoad="false">
            <Windows>
                <telerik:RadWindow ID="AddNewItemRadWindow" runat="server" ReloadOnShow="true" VisibleStatusbar="false" Title="Add new Item"
                    KeepInScreenBounds="true" Width="400px" Height="150px" OnClientClose="AddNewItemWindowClientClose">
                    <ContentTemplate>
                        <table cellspacing="3" cellpadding="3" style="width: 100%">
                            <tr>
                                <td>
                                    <br />
                                    <div class="left">
                                        <telerik:RadTextBox ID="AddNewItemRadTextBox" runat="Server" Width="250px" />
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div id="buttonsdiv" style="height: 10px; padding-top: 16px;">
                                        <telerik:RadButton ID="AddNewItemSaveRadButton" runat="server" Text="Add" Skin="WebBlue" AutoPostBack="false" OnClientClicked="AddNewItem" ButtonType="SkinnedButton" />
                                        &nbsp;&nbsp;
                                        <telerik:RadButton ID="AddNewItemCancelRadButton" runat="server" Text="Cancel" Skin="WebBlue" AutoPostBack="false" OnClientClicked="CancelAddNewItem" ButtonType="SkinnedButton" />
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
