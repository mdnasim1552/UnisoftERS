<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Common_Scarring" Codebehind="Scarring.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

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
    </style>
    <script type="text/javascript">
        var scarringValueChanged = false;
        $(window).on('load', function () {
            $('input[type="checkbox"]').each(function () {
                ToggleTRs($(this));             
            });
        });

        $(document).ready(function () {
            $("#ScarringTable tr td:first-child input:checkbox").change(function () {
                ToggleTRs($(this));
                scarringValueChanged = true;
            });

            //for this page issue 4166  by Mostafiz
            $(window).on('beforeunload', function () {
                if (scarringValueChanged) {
                    localStorage.setItem('valueChanged', $("#ScarringTable tr td:first-child input:checkbox:checked").length > 0 ? 'true' : 'false');
                    $("#SaveButton").click();
                }
            });
            $(window).on('unload', function () {
                localStorage.clear();
            });
        });

        function CloseWindow() {
            window.parent.CloseWindow();
        }

        function ToggleTRs(chkbox) {
            if (chkbox[0].id != "NoneCheckBox") {
                var checked = chkbox.is(':checked');
                if (checked) {
                    $("#NoneCheckBox").attr('checked', false);
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

        function ClearControls(tableCell) {
            tableCell.find("input:radio:checked").removeAttr("checked");
            tableCell.find("input:checkbox:checked").removeAttr("checked");
            tableCell.find("input:text").val("");
        }
    </script>
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
        <telerik:RadScriptManager ID="ScarringRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="ScarringRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
       
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Scarring/Stenosis</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">



                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">

                            <table id="ScarringTable" class="rgview" cellpadding="0" cellspacing="0" width="780px">
                                <colgroup>
                                    <col><col><col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th runat="server" id="thHeader"  width="260px" class="rgHeader" style="text-align: left;">
                                            Duodenum
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%; ">
                                                <tr headRow="1">
                                                    <td colspan="2" style="border:none;" >
                                                        <asp:CheckBox ID="UlcerScarCheckBox" runat="server" Text="ulcer scar" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%; ">
                                                <tr headRow="1">
                                                    <td style="border:none;" >
                                                        <asp:CheckBox ID="StenosisCheckBox" runat="server" Text="stenosis" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%; ">
                                                <tr headRow="1">
                                                    <td style="border:none;" >
                                                        <asp:CheckBox ID="DeformityCheckBox" runat="server" Text="deformity" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%; ">
                                                <tr>
                                                    <td style="border:none;" >
                                                        <asp:CheckBox ID="PseudodiverticulumCheckBox" runat="server" Text="pseudodiverticulum"/>
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
                <div id="cmdOtherData" style="height: 10px; display:none; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
    </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>
