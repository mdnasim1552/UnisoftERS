<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Colon_PerianalLesions" CodeBehind="PerianalLesions.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" Visible="False" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            var perianalLesionsValueChanged = false;
            function savePage() {
                $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest();
            }            

            $(window).on('load', function () {
                $('input[type="checkbox"]').each(function () {
                    ToggleTRs($(this));
                });
                SetBandingPiles();
            });

            $(document).ready(function () {
                $('input[type="checkbox"]').change(function () {
                    ToggleTRs($(this));
                    //if (($(this)[0].id) !== 'NoneCheckBox') SaveRecordByClick();
                    if (($(this)[0].id) !== 'NoneCheckBox') perianalLesionsValueChanged = true;
                });

                $("#NoneCheckBox").change(function () {
                    ToggleNoneCheckBox($(this).is(':checked'));
                    perianalLesionsValueChanged = true;
                });

                $("#HaemorrhoidsTable tr td:first-child input:radio").change(function () {
                    SetBandingPiles();
                    perianalLesionsValueChanged = true;
                });
                $("#HaemorrhoidsTable tr td:first-child input:text").focusout(function () {
                    perianalLesionsValueChanged = true;
                });
                $(window).on('beforeunload', function () {
                    if (perianalLesionsValueChanged) {
                        valueChange();
                        $('#<%=SaveButton.ClientID%>').click();
                    }
                });
                $(window).on('unload', function () {
                    localStorage.clear();
                    setRehideSummary();
                });
            });

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
                    if (chkbox[0].id == 'Haemorrhoids_Checkbox') { $("#HaemorrhoidsTable table tr:eq(2)").hide(); }
                }
            }

            function ToggleNoneCheckBox(checked) {
                if (checked) {
                    //$("#HaemorrhoidsTable tr td:first-child").each(function () {
                    //    $(this).find("input:checkbox:checked").removeAttr("checked");
                    //    $(this).find("input:checkbox").trigger("change");
                    //});
                    //$("#OtherTable tr td:first-child").each(function () {
                    //    $(this).find("input:checkbox:checked").removeAttr("checked");
                    //    $(this).find("input:checkbox").trigger("change");
                    //});

                    $("#HaemorrhoidsTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox:checked, input:radio:checked").prop('checked', false);
                        $(this).find("input:text").val("");
                        ToggleTRs($(this));
                    });

                    $("#OtherTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox:checked, input:radio:checked").prop('checked', false);
                        $(this).find("input:text").val("");
                        ToggleTRs($(this));
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

            function SetBandingPiles() {
                var qty = $find("QuantityRadNumericTextBox").get_value();
                var degree = $('input[name=vas0]:checked');
                if (qty >= 1 || degree.length) {
                    $("#HaemorrhoidsTable table tr:eq(2)").show();
                }
                else {
                    $("#HaemorrhoidsTable table tr:eq(2)").hide();
                }
            }

            function valueChange() {
                var haemorrhoidsChecked = $('#HaemorrhoidsTable input[type="checkbox"]').is(':checked');

                var otherChecked = $('#OtherTable input[type="checkbox"]').is(':checked');

                if (haemorrhoidsChecked || otherChecked) {
                    localStorage.setItem('valueChanged', 'true');
                } else {
                    localStorage.setItem('valueChanged', 'false');
                }
            }
            
        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="PerianalLesionsRadScriptManager" runat="server" EnablePageMethods="True" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
       
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Perianal Lesions</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">


            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">
                <telerik:RadAjaxPanel ID="RadAjaxPanel1" runat="server">
                    <div id="ContentDiv">
                        <div class="siteDetailsContentDiv">
                            <div class="rgview" id="Div1" runat="server">
                                <table id="HaemorrhoidsTable" runat="server" cellpadding="3" cellspacing="3" style="width: 780px;">
                                    <thead>
                                        <tr>
                                            <th class="rgHeader" style="text-align: left;">
                                                <asp:CheckBox ID="NoneCheckBox" runat="server" Text="&lt;b&gt;None&lt;/b&gt;" ForeColor="Black" Font-Bold="True" />
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>

                                        <tr>
                                            <td style="padding: 0px 0px 0px 6px;">
                                                <table style="width: 100%;">
                                                    <tr>
                                                        <td style="border: none;">
                                                            <table style="width: 100%;">
                                                                <tr headrow="1" haschildrows="1">
                                                                    <td style="border: none;">
                                                                        <asp:CheckBox ID="Haemorrhoids_Checkbox" runat="server" Text="Haemorrhoids" />
                                                                    </td>
                                                                    <td style="border: none;">Degree : &nbsp;
                                                                        <asp:RadioButton ID="First_RadioButton" runat="server" Text="1st" GroupName="vas0" CssClass="rblDegree" /><span style="margin-left: 20px;"></span>
                                                                        <asp:RadioButton ID="Second_RadioButton" runat="server" Text="2nd" GroupName="vas0" CssClass="rblDegree" /><span style="margin-left: 10px;"></span>
                                                                        <asp:RadioButton ID="Third_RadioButton" runat="server" Text="3rd" GroupName="vas0" CssClass="rblDegree" /><span style="margin-left: 10px;"></span>
                                                                        <span style="margin-left: 30px;"></span>
                                                                        Quantity : 
                                                                    <telerik:RadNumericTextBox ID="QuantityRadNumericTextBox" runat="server"
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="20px" Value="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                        <ClientEvents OnValueChanged="SetBandingPiles" />
                                                                    </telerik:RadNumericTextBox>
                                                                    </td>
                                                                </tr>

                                                                <tr id="BandingPilesTR">
                                                                    <td style="border: none;"></td>
                                                                    <td style="padding: 0px 0px 0px 0px; border-style: none; border-top: 1px dashed #c2d2e2;">
                                                                        <table>
                                                                            <tr headrow="1">
                                                                                <td style="border: none; vertical-align: top;">
                                                                                    <b>Treatment given</b>:&nbsp;&nbsp;<asp:CheckBox ID="BandingPilesCheckBox" runat="server" Text="Banding of piles" />
                                                                                </td>
                                                                                <td style="border: none;">&nbsp;&nbsp;&nbsp;No of bands
                                                                                <telerik:RadNumericTextBox ID="BandingNumRadNumericTextBox" runat="server"
                                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                                    IncrementSettings-Step="1"
                                                                                    Width="35px"
                                                                                    MinValue="0">
                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                </telerik:RadNumericTextBox>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                </tr>

                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>

                                <table id="OtherTable" runat="server" cellpadding="3" cellspacing="3" style="width: 780px;">
                                    <thead>
                                        <tr>
                                            <th class="rgHeader" style="text-align: left;" colspan="2">
                                                <asp:Label>Other lesions</asp:Label>
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td style="padding: 0px 0px 0px 6px;" colspan="2">
                                                <table style="width: 100%;">
                                                    <tr>
                                                        <td style="border: none;">
                                                            <asp:CheckBox ID="Skin_CheckBox" runat="server" Text="Skin tag" Skin="Web20" />
                                                        </td>
                                                        <td style="border: none;">Quantity : 
                                                                    <telerik:RadNumericTextBox ID="SkinTagQuantity" runat="server"
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px" MaxValue="100"
                                                                        MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="20px">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox></td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding: 0px 0px 0px 6px;">
                                                <table style="width: 100%;">
                                                    <tr>
                                                        <td style="border: none;">
                                                            <asp:CheckBox ID="Wart_Checkbox" runat="server" Text="Perianal warts" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td style="padding: 0px 0px 0px 6px;">
                                                <table style="width: 100%;">
                                                    <tr>
                                                        <td style="border: none;">
                                                            <asp:CheckBox ID="Herpes_CheckBox" runat="server" Text="Herpes simplex" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>

                                        <tr>
                                            <td style="padding: 0px 0px 0px 6px;" colspan="2">
                                                <table style="">
                                                    <tr>
                                                        <td style="border: none;">
                                                            <asp:CheckBox ID="Anal_Checkbox" runat="server" Text="Anal fissure" />
                                                        </td>
                                                        <td style="border: none;">
                                                            <asp:CheckBox ID="Acute_Checkbox" runat="server" Text="acute" />&nbsp;<asp:CheckBox ID="Chronic_Checkbox" runat="server" Text="chronic" /></td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>

                                        <tr>
                                            <td style="padding: 0px 0px 0px 6px;">
                                                <table style="width: 100%;">
                                                    <tr>
                                                        <td style="border: none;">
                                                            <asp:CheckBox ID="Fistula_Checkbox" runat="server" Text="Perianal fistula" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td style="padding: 0px 0px 0px 6px;">
                                                <table style="width: 100%;">
                                                    <tr>
                                                        <td style="border: none;">
                                                            <asp:CheckBox ID="Cancer_Checkbox" runat="server" Text="Perianal cancer" />
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
                </telerik:RadAjaxPanel>
            </telerik:RadPane>


            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="OtherDataDiv" style="height: 10px; margin-left: 10px; padding-top: 6px; display:none">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" AutoPostBack="true" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
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
