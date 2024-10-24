<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Colon_Calibre" Codebehind="Calibre.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />

    <style type="text/css">
        .rbl label
        {
          margin-right: 15px;
        }
    </style>

    <script type="text/javascript">

        var calibreValueChanged = false;

        $(window).on('load', function () {
            $('input[type="checkbox"]').each(function () {
                ToggleTRs($(this));
            });

        });

        $(document).ready(function () {
            //$("#DilatedCheckBox").change(function () {
            //    ToggleTRs($(this));
            //});

            //$("#StrictureCheckBox").change(function () {
            //    ToggleTRs($(this));
            //});

            $('input[type="checkbox"]').change(function () {
                ToggleTRs($(this));
                valueChanged();
            });

            $("#NormalCheckBox").change(function () {
                ToggleNoneCheckBox($(this).is(':checked'));
                valueChanged();
            });
            $("#StrictureLengthNumericTextBox").focusout(function () {
                valueChanged();
            });
            $('input[type="radio"]').change(function () {
                valueChanged();
            });
            $(window).on('beforeunload', function () {
                if (calibreValueChanged) $('#SaveButton').click();
            });
            $(window).on('unload', function () {
                localStorage.clear();
                setRehideSummary();
            });
        });

        function valueChanged() {
            calibreValueChanged = true;
            var valueToSave = false;
            $("#CalibreTable tr td:first-child").each(function () {
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
                $("#CalibreTable tr td:first-child").each(function () {
                    //$(this).find("input:checkbox:checked").removeAttr("checked");
                    //$(this).find("input:checkbox").trigger("change");
                     // Uncheck other checkboxes
                    $('input[type="checkbox"]').not('#NormalCheckBox').prop('checked', false);
                    // Trigger change event for other checkboxes
                    $('input[type="checkbox"]').not('#NormalCheckBox').trigger('change');
                });          
            }
        }

        function ClearControls(tableCell) {
            tableCell.find("input:radio:checked").prop('checked', false);
            tableCell.find("input:checkbox:checked").prop('checked', false);
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
        <telerik:RadScriptManager ID="CalibreRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Calibre</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y">
                <div id="ContentDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">
                            <table id="CalibreTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width: 780px;">
                                <thead>
                                    <tr>
                                        <th class="rgHeader" style="text-align: left;" colspan="2">
                                            <asp:CheckBox ID="NormalCheckBox" runat="server" Text="Normal" ForeColor="Black" />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="ContractionCheckBox" runat="server" Text="Contraction" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr headrow="1">
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="DilatedCheckBox" runat="server" Text="Dilated" />
                                                    </td>
                                                    <td style="border: none;">
                                                        <asp:RadioButtonList ID="DilatedTypeRadioButtonList" runat="server"
                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl">
                                                            <asp:ListItem Value="1" Text="Sigmoid volvulus"></asp:ListItem>
                                                            <asp:ListItem Value="2" Text="Pseudo-obstruction"></asp:ListItem>
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
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="ObstructionCheckBox" runat="server" Text="Obstruction" />
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
                                                        <asp:CheckBox ID="SpasmCheckBox" runat="server" Text="Spasm" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr headrow="1" haschildrows="1">
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="StrictureCheckBox" runat="server" Text="Stricture" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding: 0px 0px 0px 6px;border: none;">
                                                        <table style="width: 100%;" >
                                                            <tr>
                                                                <td style="border: none;">
                                                                    <asp:RadioButtonList ID="StrictureTypeRadioButtonList" runat="server"
                                                                        CellSpacing="25" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl">
                                                                        <asp:ListItem Value="1" Text="Smooth"></asp:ListItem>
                                                                        <asp:ListItem Value="5" Text="Inflammatory"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="Ulcerated"></asp:ListItem>
                                                                        <asp:ListItem Value="3" Text="Post operative"></asp:ListItem>
                                                                        <asp:ListItem Value="4" Text="Tumorous"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td style="border: none;">Length:
                                                                <telerik:RadNumericTextBox ID="StrictureLengthNumericTextBox" runat="server" 
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="0.5"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="1" />
                                                                </telerik:RadNumericTextBox>
                                                                    cm
                                                                </td>
                                                            </tr>
                                                            <tr>

                                                                <td style="border: none;">
                                                                    <asp:RadioButtonList ID="StrictureImpededRadioButtonList" runat="server"
                                                                        CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl">
                                                                        <asp:ListItem Value="1" Text="Impeded endoscopy"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="Endoscope passed through"></asp:ListItem>
                                                                    </asp:RadioButtonList>
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
                        </div>
                    </div>
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px; display:none">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
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
