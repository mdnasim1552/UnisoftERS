<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Common_Tumour" CodeBehind="Tumour.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .RadSplitterNoBorders {
            border-style: none !important;
        }

        .SiteDetailsButtonsPane {
            /*border-top-style: solid;
            border-top-width: 1px;
            border-top-color: ActiveBorder;*/
        }

        .noborder td {
            border: none !important;
        }
        #RAD_SPLITTER_PANE_CONTENT_ControlsRadPane{
            width: 790px !important;
        }
    </style>
    <script type="text/javascript">
        var ValueTumourChanged = false;
        $(window).on('load', function () {
            $("#TumorCheckBoxesTD").hide();
            var rbTumour = $('input[name="TumourRadioButtonList"]:checked').val();
            if (typeof (rbTumour) !== 'undefined') {
                if ((rbTumour.indexOf("RadioButton") > -1)) {
                    $("#TumorCheckBoxesTD").show();
                }
            }

            $('[data-parent]').each(function (idx, itm) {
                var dataGroupName = $(this).attr('data-parent');
                if ($(itm).is(':checked')) {
                    $('[data-child="' + dataGroupName + '"]').show();
                }
                else {
                    $('[data-child="' + dataGroupName + '"]').hide();
                }
            });
        });

        function CloseWindow() {
            window.parent.CloseWindow();
        }

        $(document).ready(function () {
            $("#NoneCheckBox").change(function () {
                ToggleNoneCheckBox($(this).is(':checked'));
                ValueTumourChanged = true;
            });

            $("#TumourTable input:checkbox").change(function () {

                ValueTumourChanged = true;

            });


            $("#TumourTable input:radio").change(function () {
                ValueTumourChanged = true;
                var elemId = $(this).attr("id");
                if ($(this).is(':checked')) {
                    if (elemId == "NoneCheckBox") { return; }
                    if (elemId.indexOf("NoneCheckBox") > -1) {
                        ClearControls("ContentDiv");
                    }
                    else {
                        $("#NoneCheckBox").prop('checked', false);
                            var dataGroupName = $(this).closest('span').attr('data-parent');
                            if (dataGroupName != undefined) {
                                $('[data-child="' + dataGroupName + '"]').show();
                            }
                            else if (elemId.indexOf("TumourTypesRBL") == -1) {
                                $('[data-child]').each(function (idx, itm) {
                                    $(itm).hide();
                                    $('#TumourTypesRBL input').prop('checked', false);
                                });
                            }
                    }
                }

                if ((elemId.indexOf("RadioButton") > -1) && ($(this).is(':checked'))) {
                    $("#TumorCheckBoxesTD").show();
                } else {
                    $("#TumorCheckBoxesTD").hide();
                    UnCheckBoxes();
                }

            });

            $(window).on('beforeunload', function () {
                if (ValueTumourChanged) {
                    localStorage.setItem('valueChanged', $("#ContentDiv input:checkbox:checked").length > 0 || $("#ContentDiv input:radio:checked").length > 0 ? 'true' : 'false');
                    $("#SaveButton").click();
                }
            });
            $(window).on('unload', function () {
                localStorage.clear();
            });
        });
        //changed by mostafiz issue 3647
        function ClearControls(parentCtrlId) {
            $("#" + parentCtrlId + " input:radio:checked").prop('checked', false);
            $("#" + parentCtrlId + " input:checkbox:checked").prop('checked', false);
            $("#" + parentCtrlId + " input:text").val('');
            $("#" + parentCtrlId + " textarea").val('');

            $('[data-child]').each(function (idx, itm) {
                $(itm).hide();
            });
        }
        //changed by mostafiz issue 3647
        function ToggleNoneCheckBox(checked) {
            if (checked) {
                $("#TumourTable tr td:first-child").each(function () {
                    $(this).find("input:radio:checked").prop('checked', false);
                });
                UnCheckBoxes();
                $("#TumorCheckBoxesTD").hide();
            }
        }
        //changed by mostafiz issue 3647
        function UnCheckBoxes() {
            $("#TumourTable tr td:first-child + td").each(function () {
                $(this).find("input:checkbox:checked").prop('checked', false);
            });
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
        <telerik:RadScriptManager ID="DeformityRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="DeformityRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Tumour</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="700px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">



                <div id="ContentDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">
                            <table id="TumourTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width: 780px;">
                                <colgroup>
                                    <col>
                                    <col>
                                    <col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th class="rgHeader" style="text-align: left;" colspan="2">
                                            <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" Style="margin-right: 10px;" />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td colspan="2">
                                            <asp:RadioButton ID="BenignPolypRadio" runat="server" Text="Benign polyp" GroupName="TumourRadioButtonList" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <asp:RadioButton ID="BenignTumourRadio" runat="server" Text="Benign tumour" GroupName="TumourRadioButtonList" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:RadioButton ID="LymphomaRadioButton" runat="server" Text="Lymphoma" GroupName="TumourRadioButtonList" />
                                        </td>
                                        <td id="TumorCheckBoxesTD" rowspan="3" runat="server" style="width: 60%; vertical-align: top;">
                                            <asp:CheckBox ID="PrimaryCheckBox" runat="server" Text="Primary" Style="margin-right: 10px;" /><br />
                                            <asp:CheckBox ID="ExternalInvasionCheckBox" runat="server" Text="External invasion" Style="margin-right: 10px;" /><br />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:RadioButton ID="ProbableCarcinomaRadioButton" runat="server" Text="Probable carcinoma" GroupName="TumourRadioButtonList" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:RadioButton ID="ConfirmedCarcinomaRadioButton" runat="server" Text="Confirmed carcinoma" GroupName="TumourRadioButtonList" />
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
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
