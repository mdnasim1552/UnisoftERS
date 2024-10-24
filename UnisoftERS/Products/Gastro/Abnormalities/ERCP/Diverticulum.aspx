<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_ERCP_Diverticulum" Codebehind="Diverticulum.aspx.vb" %>

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
    </style>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var diverticulumERCPValueChanged = false;
        $(window).on('load', function () {
             $('input[type="checkbox"]').each(function () {
                ToggleTRs($(this));
            });
            QtyChanged();
            SizeChanged();
            ProximityChanged();
        });

        $(document).ready(function () {
            $("#NoneCheckBox").change(function () {
                ToggleNoneCheckBox($(this).is(':checked'));
                diverticulumERCPValueChanged = true;
            });

            $("#DiverticulumTable tr td:first-child input:checkbox ,input[type=text]").change(function () {
                ToggleTRs($(this));
                diverticulumERCPValueChanged = true;
            });

            $("input[type='radio']").on('click', function (e) {
                ProximityChanged();
                diverticulumERCPValueChanged = true;
            });
            //Added by rony tfs-4166;
            $(window).on('beforeunload', function () {
                if (diverticulumERCPValueChanged) {
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
            $("#DiverticulumTable tr td:first-child input:checkbox ,input[type=text], input[type=radio]").each(function () {
                if ($(this).is(':checkbox') && $(this).is(':checked')) {
                    valueToSave = true;
                } else if ($(this).is('input[type=text]') && $(this).val().trim() !== "") {
                    valueToSave = true;
                } else if ($(this).is('input[type=radio]') && $(this).is(':checked')) {
                    valueToSave = true;
                }
            });
            if (!$('#NoneCheckBox').is(':checked') && !valueToSave)
                localStorage.setItem('valueChanged', 'false');
            else
                localStorage.setItem('valueChanged', 'true');
        }

        //changed by mostafiz issue 3647
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
            }
        }

        function CloseWindow() {
            window.parent.CloseWindow();
        }

        function ToggleNoneCheckBox(checked) {
            if (checked) {
                $("#DiverticulumTable tr td:first-child table tr td:first-child").each(function () {
                    ClearControls($(this));
                });
            }
        }
        //changed by mostafiz issue 3647
        function QtyChanged() {
            if ($find("QuantityNumericTextBox").get_value() != "") {
                $("#NoneCheckBox").prop('checked', false);
            }
        }
        //changed by mostafiz issue 3647
        function SizeChanged() {
            if ($find("SizeOfLargestNumericTextBox").get_value() != "") {
                $("#NoneCheckBox").prop('checked', false);
            }
        }
        //changed by mostafiz issue 3647
        function ProximityChanged() {
            if ($('#ProximityRadioButtonList input:checked').val()) {
                $("#NoneCheckBox").prop('checked', false);
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
        <telerik:RadScriptManager ID="DiverticulumRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="DiverticulumFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
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
                            <table id="DiverticulumTable" class="rgview" cellpadding="0" cellspacing="0" width="780px">
                                <colgroup>
                                    <col>
                                    <col>
                                    <col>
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
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <label>Qty</label>
                                                        <telerik:RadNumericTextBox ID="QuantityNumericTextBox" runat="server" style="margin-left:5px;"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0"
                                                            onchange="QtyChanged();">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
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
                                                        <label>Size of largest</label>
                                                        <telerik:RadNumericTextBox ID="SizeOfLargestNumericTextBox" runat="server" style="margin-left:5px;"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0"
                                                            onchange="SizeChanged();">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                        <label>mm</label>
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
                                                        <label>Proximity</label>
                                                        <asp:RadioButtonList ID="ProximityRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" CssClass="rblType">
                                                            <asp:ListItem Value="1" Text="> 5mm from ampulla"></asp:ListItem>
                                                            <asp:ListItem Value="2" Text="ampulla at edge"></asp:ListItem>
                                                            <asp:ListItem Value="3" Text="ampulla within diverticulum"></asp:ListItem>
                                                        </asp:RadioButtonList>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                     <tr>
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td colspan="2" style="border: none;">
                                                        <asp:CheckBox ID="OcclusionChekBox" runat="server" Text="Occlusion" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                     <tr>
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td colspan="2" style="border: none;">
                                                        <asp:CheckBox ID="BiliaryLeakCheckBox" runat="server" Text="Biliary Leak" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                     <tr>
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td colspan="2" style="border: none;">
                                                        <asp:CheckBox ID="PreviousSurgeryCheckBox" runat="server" Text="Previous Surgery" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr runat="server" >
                                        <td style="padding: 0px 0px 0px 6px;">
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
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="WebBlue" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="WebBlue" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
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