<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Common_PapillaryAnatomy" Codebehind="PapillaryAnatomy.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Papillary Anatomy</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/global.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
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
            padding-left:0px;
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

        .papAnLabel {
            font-weight:bold;
            color:black;
        }

        .checkBoxRow {
            height:25px;
        }
    </style>
    <script type="text/javascript">
        $(window).on('load', function () {
            $('#MajorTable tr td:first-child input:checkbox').each(function () {
                ToggleTRs($(this));
            });

            $('#MinorTable tr td:first-child input:checkbox').each(function () {
                ToggleTRsMinor($(this));
            });
        });

        $(document).ready(function () {
            $("#MajorTable tr td:first-child input:checkbox").change(function () {
                ToggleTRs($(this));
            });

            $("#MinorTable tr td:first-child input:checkbox").change(function () {
                ToggleTRsMinor($(this));
            });

            $("#MajorSurgeryNoneCheckBox").change(function () {
                ToggleMajorSurgeryNoneCheckBox($(this).is(':checked'));
            });

            $("#MinorSurgeryNoneCheckBox").change(function () {
                ToggleMinorSurgeryNoneCheckBox($(this).is(':checked'));
            });
        });

        function CloseWindow() {
            GetRadWindow().close();
        }

        function ToggleTRs(chkbox) {
            if (chkbox[0].id != "MajorSurgeryNoneCheckBox") {
                var checked = chkbox.is(':checked');
                if (checked) {
                    $("#MajorSurgeryNoneCheckBox").attr('checked', false);
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
            }
        }

        function ToggleTRsMinor(chkbox) {
            if (chkbox[0].id != "MinorSurgeryNoneCheckBox") {
                var checked = chkbox.is(':checked');
                if (checked) {
                    $("#MinorSurgeryNoneCheckBox").attr('checked', false);
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
            }
        }

        function ToggleMajorSurgeryNoneCheckBox(checked) {
            if (checked) {
                $("#MajorTable tr td:first-child").each(function () {
                    if ($(this)[0].id != "MajorSurgeryNoneTD") {
                        $(this).find("input:checkbox:checked").removeAttr("checked");
                        $(this).find("input:checkbox").trigger("change");
                    }
                });
            }
        }

        function ToggleMinorSurgeryNoneCheckBox(checked) {
            if (checked) {
                $("#MinorTable tr td:first-child").each(function () {
                    if ($(this)[0].id != "MinorSurgeryNoneTD") {
                        $(this).find("input:checkbox:checked").removeAttr("checked");
                        $(this).find("input:checkbox").trigger("change");
                    }
                });
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
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="PapillaryAnatomyRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="PapillaryAnatomyRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="TabStripContainer" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
            <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="90%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
                <telerik:RadPane ID="ControlsRadPane" runat="server" Height="350px" Width="95%">
                    <div id="TabStripContainer" style="margin-left:10px; padding-top:1em;">
                            <telerik:RadTabStrip runat="server" ID="PapillaryAnatomyTabStrip" MultiPageID="PapillaryAnatomyMultiPage" SelectedIndex="1" ReorderTabsOnSelect="True" Skin="WebBlue">
                                <Tabs>
                                    <telerik:RadTab Text="Major Papilla" PageViewID="MajorPapillaTab" Selected="True" ></telerik:RadTab>
                                    <telerik:RadTab Text="Minor Papilla" PageViewID="MinorPapillaTab"></telerik:RadTab>
                                </Tabs>
                            </telerik:RadTabStrip>

                            <telerik:RadMultiPage ID="PapillaryAnatomyMultiPage" runat="server" SelectedIndex="0" >
                                <telerik:RadPageView ID="MajorPapillaPageView" runat="server">
                                    <div id="divMajorPapilla" style="border:1px solid #828282;padding:15px 15px; width:550px;" runat="server">
                                        <table id="MajorTable">
                                            <tr valign="top">
                                                <td style="width:100px; ">
                                                    <span class="papAnLabel">Site:</span>
                                                    <asp:RadioButtonList ID="MajorSiteLocationRadioButtonList" runat="server" CellSpacing="0" CellPadding="0">
                                                        <asp:ListItem Value="1" Text="1st part"></asp:ListItem>
                                                        <asp:ListItem Value="2" Selected="True" Text="2nd part"></asp:ListItem>
                                                        <asp:ListItem Value="3" Text="3rd part"></asp:ListItem>
                                                    </asp:RadioButtonList>
                                                </td>
                                                <td  style="width:100px; ">
                                                    <span class="papAnLabel">Size:</span>
                                                    <asp:RadioButtonList ID="MajorSizeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0">
                                                        <asp:ListItem Value="1" Selected="True" Text="normal"></asp:ListItem>
                                                        <asp:ListItem Value="2" Text="small"></asp:ListItem>
                                                        <asp:ListItem Value="3" Text="large"></asp:ListItem>
                                                    </asp:RadioButtonList>
                                                </td>
                                                <td  style="width:100px; ">
                                                    <span class="papAnLabel">Openings:</span>
                                                    <asp:RadioButtonList ID="MajorNoOfOpeningsRadioButtonList" runat="server" CellSpacing="0" CellPadding="0">
                                                        <asp:ListItem Value="1" Selected="True" Text="one"></asp:ListItem>
                                                        <asp:ListItem Value="2" Text="two"></asp:ListItem>
                                                    </asp:RadioButtonList>
                                                </td>
                                                <td  style="width:100px; ">
                                                    <asp:CheckBox ID="MajorFloppyCheckBox" runat="server" Text="floppy" Style="margin-right: 10px;" />
                                                    <br />
                                                    <asp:CheckBox ID="MajorStenosedCheckBox" runat="server" Text="stenosed" Style="margin-right: 10px;" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="height:10px;">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <span class="papAnLabel">Previous surgery</span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td  id="MajorSurgeryNoneTD" colspan="2">
                                                    <asp:CheckBox ID="MajorSurgeryNoneCheckBox" runat="server" Text="none" Style="margin-right: 10px;" />
                                                </td>
                                            </tr>
                                            <tr class="checkBoxRow">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="MajorEndoscopicCheckBox" runat="server" Text="endoscopic sphincterotomy" Style="margin-right: 10px;" />
                                                </td>
                                                <td>size:
                                                    <telerik:RadNumericTextBox ID="MajorEndoscopicSizeTextBox" runat="server"
                                                        
                                                        IncrementSettings-InterceptMouseWheel="false"
                                                        IncrementSettings-Step="1"
                                                        Width="35px"
                                                        MinValue="0">
                                                        <NumberFormat DecimalDigits="0" />
                                                    </telerik:RadNumericTextBox>mm
                                                </td>
                                            </tr>
                                            <tr class="checkBoxRow">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="MajorOperativeCheckBox" runat="server" Text="operative sphincterotomy" Style="margin-right: 10px;" />
                                                </td>
                                                <td>size:
                                                    <telerik:RadNumericTextBox ID="MajorOperativeSizeTextBox" runat="server"
                                                        
                                                        IncrementSettings-InterceptMouseWheel="false"
                                                        IncrementSettings-Step="1"
                                                        Width="35px"
                                                        MinValue="0">
                                                        <NumberFormat DecimalDigits="0" />
                                                    </telerik:RadNumericTextBox>mm
                                                </td>
                                            </tr>
                                            <tr class="checkBoxRow">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="MajorSphincteroplastyCheckBox" runat="server" Text="sphincteroplasty" Style="margin-right: 10px;" />
                                                </td>
                                                <td>size:
                                                    <telerik:RadNumericTextBox ID="MajorSphincteroplastySizeTextBox" runat="server"
                                                        
                                                        IncrementSettings-InterceptMouseWheel="false"
                                                        IncrementSettings-Step="1"
                                                        Width="35px"
                                                        MinValue="0">
                                                        <NumberFormat DecimalDigits="0" />
                                                    </telerik:RadNumericTextBox>mm
                                                </td>
                                            </tr>
                                            <tr class="checkBoxRow">
                                               <td colspan="2">
                                                    <asp:CheckBox ID="MajorCholedochoduodenostomyCheckBox" runat="server" Text="choledochoduodenostomy" Style="margin-right: 10px;" />
                                                </td>
                                            </tr>
                                            <tr class="checkBoxRow">
                                               <td colspan="2">
                                                    <asp:CheckBox ID="MajorBilrothRouxCheckBox" runat="server" Text="bilroth roux" Style="margin-right: 10px;" />
                                                </td>
                                            </tr>
                                        </table>                                    
                                    </div>
                                </telerik:RadPageView>
                                <telerik:RadPageView ID="MinorPapillaPageView" runat="server" Width="95%">
                                    <div id="divMinorPapilla" style="border:1px solid #828282;width:550px;padding:15px 15px;" runat="server">
                                        <table id="MinorTable">
                                            <tr valign="top">
                                                <td style="width:170px; ">
                                                    <span class="papAnLabel">Site:</span>
                                                    <asp:RadioButtonList ID="MinorSiteLocationRadioButtonList" runat="server" CellSpacing="0" CellPadding="0">
                                                        <asp:ListItem Value="1" Text="not present"></asp:ListItem>
                                                        <asp:ListItem Value="2" Text="no attempt to visualise"></asp:ListItem>
                                                        <asp:ListItem Value="3" Text="in 1st part"></asp:ListItem>
                                                        <asp:ListItem Value="4" Selected="True" Text="in 2nd part"></asp:ListItem>
                                                        <asp:ListItem Value="5" Text="in 3rd part"></asp:ListItem>
                                                    </asp:RadioButtonList>
                                                </td>
                                                <td  style="width:100px; ">
                                                    <span class="papAnLabel">Size:</span>
                                                    <asp:RadioButtonList ID="MinorSizeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0">
                                                        <asp:ListItem Value="1" Selected="True" Text="normal"></asp:ListItem>
                                                        <asp:ListItem Value="2" Text="small"></asp:ListItem>
                                                        <asp:ListItem Value="3" Text="large"></asp:ListItem>
                                                    </asp:RadioButtonList>
                                                </td>
                                                <td  style="width:100px; ">
                                                    <asp:CheckBox ID="MinorStenosedCheckBox" runat="server" Text="stenosed" Style="margin-right: 10px;" />
                                                </td>
                                                <td  style="width:100px; ">
                                                        <%--<span class="papAnLabel">Openings:</span>
                                                        <asp:RadioButtonList ID="MinorNoOfOpeningsRadioButtonList" runat="server" CellSpacing="0" CellPadding="0">
                                                            <asp:ListItem Value="1" Text="one"></asp:ListItem>
                                                            <asp:ListItem Value="2" Text="two"></asp:ListItem>
                                                        </asp:RadioButtonList>--%>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="height:10px;">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <span class="papAnLabel">Previous surgery</span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td  id="MinorSurgeryNoneTD" colspan="2">
                                                    <asp:CheckBox ID="MinorSurgeryNoneCheckBox" runat="server" Text="none" Style="margin-right: 10px;" />
                                                </td>
                                            </tr>
                                            <tr class="checkBoxRow">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="MinorEndoscopicCheckBox" runat="server" Text="endoscopic sphincterotomy" Style="margin-right: 10px;" />
                                                </td>
                                                <td>size:
                                                    <telerik:RadNumericTextBox ID="MinorEndoscopicSizeTextBox" runat="server"
                                                        
                                                        IncrementSettings-InterceptMouseWheel="false"
                                                        IncrementSettings-Step="1"
                                                        Width="35px"
                                                        MinValue="0">
                                                        <NumberFormat DecimalDigits="0" />
                                                    </telerik:RadNumericTextBox>mm
                                                </td>
                                            </tr>
                                            <tr class="checkBoxRow">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="MinorOperativeCheckBox" runat="server" Text="operative sphincterotomy" Style="margin-right: 10px;" />
                                                </td>
                                                <td>size:
                                                    <telerik:RadNumericTextBox ID="MinorOperativeSizeTextBox" runat="server"
                                                        
                                                        IncrementSettings-InterceptMouseWheel="false"
                                                        IncrementSettings-Step="1"
                                                        Width="35px"
                                                        MinValue="0">
                                                        <NumberFormat DecimalDigits="0" />
                                                    </telerik:RadNumericTextBox>mm
                                                </td>
                                            </tr>
                                           
                                        </table>     
                                    </div>
                                </telerik:RadPageView>
                            </telerik:RadMultiPage>

                        </div>
                </telerik:RadPane>            
                <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                    <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;">
                        <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="WebBlue" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                        <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="WebBlue" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
                    </div>
                </telerik:RadPane>
            </telerik:RadSplitter>
        <div>
        </div>
    </form>
</body>
</html>
