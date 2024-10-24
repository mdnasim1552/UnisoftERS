<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_ERCP_Tumour" CodeBehind="Tumour.aspx.vb" %>

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
        #RAD_SPLITTER_PANE_CONTENT_ControlsRadPane{
            height: calc(90vh - 20px) !important;
        }
    </style>
    <telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var tumourERCPValueChanged = false;
        $(window).on('load', function () {
            $('input[type="checkbox"]').each(function () {
                ToggleTRs($(this));
            });
            SizeChanged();
        });

        $(document).ready(function () {
            $("#TumourTable tr td:first-child input:checkbox").change(function () {
                ToggleTRs($(this));
                tumourERCPValueChanged = true;
            });
            $("#NoneCheckBox").change(function () {
                ToggleNoneCheckBox($(this).is(':checked'));
                tumourERCPValueChanged = true;
            });
            //Added by rony tfs-4166;
            $(window).on('beforeunload', function () {
                if (tumourERCPValueChanged) {
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
            $("#TumourTable tr td:first-child").each(function () {
                if ($(this).find("input:checkbox").is(':checked')) valueToSave = true;
            });
            if (!$('#NoneCheckBox').is(':checked') && !valueToSave)
                localStorage.setItem('valueChanged', 'false');
            else
                localStorage.setItem('valueChanged', 'true');
        }

        function CloseWindow() {
            window.parent.CloseWindow();
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



        function ToggleNoneCheckBox(checked) {
            if (checked) {
                
                $("#TumourTable tr td:first-child").each(function () {
                    ClearControls($(this));
                });
                
            }
        }
        //changed by mostafiz issue 3647
        function SizeChanged() {
            if ($find("SizeNumericTextBox").get_value() != "") {
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
        <telerik:RadScriptManager ID="TumourRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="TumourFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Tumour</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">
                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">
                            <table id="TumourTable" class="rgview" cellpadding="0" cellspacing="0" width="780px">
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
                                                    <td colspan="2" style="border: none; width: 30%;">
                                                        <asp:CheckBox ID="FirmCheckBox" runat="server" Text="Firm" />
                                                    </td>
                                                    <td rowspan="6" style="border: none;">
                                                        <label>Size</label>
                                                        <telerik:RadNumericTextBox ID="SizeNumericTextBox" runat="server" Style="margin-left: 5px;"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0"
                                                            onchange="SizeChanged();">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>mm
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
                                                        <asp:CheckBox ID="FriableCheckBox" runat="server" Text="Friable" />
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
                                                        <asp:CheckBox ID="UlceratedCheckBox" runat="server" Text="Ulcerated" />
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
                                                        <asp:CheckBox ID="VillousCheckBox" runat="server" Text="Villous" />
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
                                                        <asp:CheckBox ID="PolypoidCheckBox" runat="server" Text="Polypoidal" />
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
                                                        <asp:CheckBox ID="SubMucosalCheckBox" runat="server" Text="Sub-mucosal" />
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

                                    
                                     <tr>
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td colspan="2" style="border: none;">
                                                        <asp:CheckBox ID="IPMTCheckBox" runat="server" Text="IPMT" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>


                                    <tr runat="server" visible="false">
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
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="WebBlue" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="WebBlue" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
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
