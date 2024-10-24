<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Colon_Miscellaneous" CodeBehind="Miscellaneous.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />

    <style type="text/css">
        .rbl label {
            margin-right: 15px;
        }
        #RAD_SPLITTER_PANE_CONTENT_ControlsRadPane{
            height: calc(90vh - 20px) !important;
        }
    </style>

    <script type="text/javascript">
        var miscellaneousValueChanged = false;
        $(window).on('load', function () {
            $('input[type="checkbox"]').each(function () {
                ToggleTRs($(this));
            });

        });

        $(document).ready(function () {

            $('input[type="checkbox"]').change(function () {
                ToggleTRs($(this));

                valueChanged();
            });

            $("#NormalCheckBox").change(function () {
                ToggleNoneCheckBox($(this).is(':checked'));
            });
            $(window).on('beforeunload', function () {
                if (miscellaneousValueChanged) $('#SaveButton').click();
            });
            $(window).on('unload', function () {
                localStorage.clear();
                setRehideSummary();
            });
        });

        function valueChanged() {
            miscellaneousValueChanged = true;
            var valueToSave = false;
            $("#MiscellaneousTable tr td:first-child").each(function () {
                if ($(this).find("input:checkbox").is(':checked')) valueToSave = true;
            });
            if (!$('#NormalCheckBox').is(':checked') && !valueToSave)
                localStorage.setItem('valueChanged', 'false');
            else
                localStorage.setItem('valueChanged', 'true');

        }

        

        //changed by mostafiz issue 3647
        function ToggleTRs(chkbox) {
            if (chkbox[0].id != "NormalCheckBox") {
                var checked = chkbox.is(':checked');
                if (checked) {
                    $("#NormalCheckBox").prop('checked', false);  
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
        function ToggleNoneCheckBox(checked) {
            if (checked) {
                $("#MiscellaneousTable tr td:first-child").each(function () {
                    $('input[type="checkbox"]').not('#NormalCheckBox').prop('checked', false);
                    //$('input[type="checkbox"]').not('#NormalCheckBox').trigger('change');
                });
            }
        }

        function ClearControls(tableCell) {
            tableCell.find("input:radio:checked").removeAttr("checked");
            tableCell.find("input:checkbox:checked").removeAttr("checked");
            tableCell.find("input:text").val("");
        }

        function CloseWindow() {
            window.parent.CloseWindow();
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
        <telerik:RadScriptManager ID="MiscellaneousRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <div class="abnorHeader">Miscellaneous</div>
                <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
                    <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">
                        <div id="ContentDiv">
                            <div class="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">
                                    <table id="MiscellaneousTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width: 770px;">
                                        <thead>
                                            <tr>
                                                <th class="rgHeader" style="text-align: left;" colspan="2">
                                                    <asp:CheckBox ID="NormalCheckBox" runat="server" Text="None" ForeColor="Black" />
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>

                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="AmpullaryAdenomaCheckBox" runat="server" Text="Ampullary adenoma" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr style="visibility: collapse">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="CrohnCheckBox" runat="server" Text="Crohn's - terminal ileum" Visible="false" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="FistulaCheckBox" runat="server" Text="Fistula" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="ForeignBodyCheckBox" runat="server" Text="Foreign body" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="LipomaCheckBox" runat="server" Text="Lipoma" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="MelanosisCheckBox" runat="server" Text="Melanosis" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="ParasitesCheckBox" runat="server" Text="Parasites" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="PneumatosisColiCheckBox" runat="server" Text="Pneumatosis coli" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="PolyposisSyndromeCheckBox" runat="server" Text="Polyposis syndrome" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="PostoperativeAppearanceCheckBox" runat="server" Text="Postoperative appearance" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="PseudoobstructionCheckBox" runat="server" Text="Pseudo-obstruction" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="PouchitisCheckBox" runat="server" Text="Pouchitis" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="PEGInSituCheckBox" runat="server" Text="PEG in situ" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="StentInSituCheckBox" runat="server" Text="Stent in situ" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="StentOcclusionCheckBox" runat="server" Text="Stent occlusion" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="VolvulusCheckBox" runat="server" Text="Volvulus" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="MiscOtherTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="MiscOtherCheckBox" runat="server" Text="Other" />
                                                            </td>
                                                            <td style="border: none;">
                                                                <telerik:RadTextBox ID="MiscOtherTextBox" runat="server" Width="500px" Text='<%# Bind("Other")%>' />
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
                    <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="39px" CssClass="SiteDetailsButtonsPane">
                        <div id="cmdOtherData" style="height: 10px; margin-left: 10px; margin-top: 10px; padding-top: 6px; display:none">
                            <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" />
                            <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                        </div>
                    </telerik:RadPane>
                </telerik:RadSplitter>
                <div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
