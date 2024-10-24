<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Common_Diverticulum" Codebehind="Diverticulum.aspx.vb" %>

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
        var diverticulumValueChanged = false;
        var noneChecked = false;

        $(window).on('load', function () {
            $('input[type="checkbox"]').each(function () {
                ToggleTRs($(this));
            });
            ToggleJejunum();
        });

        $(document).ready(function () {
            $("#PostSurgeryTable tr td:first-child input:checkbox,input[type=text]").change(function () {
                ToggleTRs($(this));
                diverticulumValueChanged = true;

            });
             

            $("#NoneCheckBox").change(function () {
                ToggleNoneCheckBox($(this).is(':checked'));
                diverticulumValueChanged = true;
            });
            //for this page issue 4166  by Mostafiz
            $(window).on('beforeunload', function () {
                if (diverticulumValueChanged) {
                    valueChange();
                    $("#SaveButton").click();
                }
            });

            $(window).on('unload', function () {
                localStorage.clear();
            });
        });

        function valueChange() {
            var diverticulumChecked = $("#PostSurgeryTable tr td:first-child input:checkbox,input[type=text]").is(':checked');
            if (diverticulumChecked || noneChecked) {
                localStorage.setItem('valueChanged', 'true');
            } else {
                localStorage.setItem('valueChanged', 'false');
            }
        }

        function CloseWindow() {
            window.parent.CloseWindow();
        }

        function ToggleTRs(chkbox) {
            if (chkbox[0].id != "NoneCheckBox") {
                var checked = chkbox.is(':checked');
                if (checked) {
                    $("#NoneCheckBox").prop('checked', false);
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
                if (chkbox[0].id == "JejunumCheckBox") {
                    ToggleJejunum();
                }
            }
        }

        function ToggleNoneCheckBox(checked) {
            noneChecked = checked;
            if (checked) {
                $("#PostSurgeryTable tr td:first-child").each(function () {
                    $(this).find("input:checkbox:checked").prop('checked', false);
                    $(this).find("input:checkbox").trigger("change");
                });
            }
        }

        function ToggleJejunum() {
            var selectedVal = $('#JejunumStateRadioButtonList input:checked').val();
            if (selectedVal == 2) {
                $("#AbnormalTextBox").show();
            }
            else {
                $("#AbnormalTextBox").hide();
                $("#AbnormalTextBox").val("");
            }
        }

        function ClearControls(tableCell) {
            tableCell.find("input:radio:checked").prop('checked', false);
            tableCell.find("input:checkbox:checked").prop('checked', false);
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
        <telerik:RadScriptManager ID="PostSurgeryRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="PostSurgeryRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Diverticulum</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">



                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">

                            <table id="PostSurgeryTable" class="rgview" cellpadding="0" cellspacing="0" width="780px">
                                <colgroup>
                                    <col><col><col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th width="260px" class="rgHeader" style="text-align: left;">
                                            <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%; ">
                                                <tr headRow="1">
                                                    <td colspan="2" style="border:none;" >
                                                        <asp:CheckBox ID="PseudodiverticulumCheckBox" runat="server" Text="Pseudodiverticulum" />
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
                                                        <asp:CheckBox ID="FirstPartCheckBox" runat="server" Text="1st part" />
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
                                                        <asp:CheckBox ID="SecondPartCheckBox" runat="server" Text="2nd part" />
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
                                                        <asp:CheckBox ID="OtherCheckBox" runat="server" Text="Other"/>
                                                    </td>
                                                    <td style="border:none;" >
                                                        <telerik:RadTextBox ID="OtherTextBox" runat="server" Width="200px" />
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
