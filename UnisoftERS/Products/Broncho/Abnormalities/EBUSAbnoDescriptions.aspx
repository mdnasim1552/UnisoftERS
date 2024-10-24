<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Broncho_Abnormalities_EBUSAbnoDescriptions" CodeBehind="EBUSAbnoDescriptions.aspx.vb" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />

    <telerik:RadScriptBlock runat="server" ID="RadCodeBlock">
        <script type="text/javascript">
            $(window).on('load', function () {
                $('input[type="checkbox"]').each(function () {
                    ToggleTRs($(this));
                });
            });

            $(document).ready(function () {
                $("#EBUSAbnosTable tr td:first-child input:checkbox, input:radio, input:text").change(function () {
                    ToggleTRs($(this));
                });

                $("#NoneCheckBox").change(function () {
                    ToggleNoneCheckBox($(this).is(':checked'));
                });
            });

            function CloseWindow() {
                window.parent.CloseWindow();
            }
            function SaveAndClose() {
                // GetRadWindow().BrowserWindow.savePage();
                setTimeout(function () {
                    GetRadWindow().close();
                }, 1000);

            }

            function ToggleTRs(chkbox) {
                $("#NoneCheckBox").attr('checked', false);
            }

            function ToggleNoneCheckBox(checked) {
                if (checked) {
                    $("#EBUSAbnosTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox:checked, input:radio:checked").removeAttr("checked");
                        $(this).find("input:checkbox").trigger("change");
                        $(this).find("input:text").val("");
                    });
                }
            }

            function ClearControls(tableCell) {
                tableCell.find("input:radio:checked").removeAttr("checked");
                tableCell.find("input:checkbox:checked").removeAttr("checked");
                tableCell.find("input:text").val("");
            }

            function refreshParentEBUS(siteid) {

                var test = parent.location.href;
                test = test.replace("SiteId=-1", "SiteId=" + siteid);

                parent.location.href = test + '&DefaultNav=yes';
                // console.log(parent.location.href);

                //parent.location.reload();
            }

            function saveEbusAbnormalities() {
                //alert("saveEbusAbnormalities");
                var obj = {};
                //alert("obj = {}");

                obj.siteId = $find("<%= SiteIdHiddenField.ClientID%>").get_textBoxValue();
                obj.normal = $("#<%= NoneCheckBox.ClientID%>").is(':checked');
                //obj.size = $("# SizeRadioButtonList.ClientID %> input[type=radio]:checked").val();
                obj.sizeNum = $find("<%= SlidingLengthTextBox.ClientID%>").get_textBoxValue();
                //obj.shape = $("#SizeRadioButtonList.ClientID %> input[type=radio]:checked").val();
                obj.margin = $("#<%=MarginRadioButtonList.ClientID %> input[type=radio]:checked").val();
                obj.echoGenecity = $("#<%= EchogenecityRadioButtonList.ClientID %> input[type=radio]:checked").val();
                obj.cHS = $("#<%= CHSRadioButtonList.ClientID %> input[type=radio]:checked").val();
                obj.cNS = $("#<%= CNSRadioButtonList.ClientID %> input[type=radio]:checked").val();
                obj.vascular = $("#<%= VascularRadioButtonList.ClientID %> input[type=radio]:checked").val();
                obj.bxType = parseInt($find("<%= RegimeDropDown.ClientID%>").get_selectedItem().get_value());
                obj.noBxTaken = $find("<%= NumberTakenRadNumericTextBox.ClientID%>").get_textBoxValue();
                obj.bxNeedleType = parseInt($find("<%= NeedleTypeRadDropDownList.ClientID%>").get_selectedItem().get_value());
                obj.bxNeedleSize = $find("<%= DiamRadNumericTextBox.ClientID%>").get_textBoxValue();
                obj.bxNeedSizeUnits = parseInt($find("<%= UnitsRadDropDownList.ClientID%>").get_selectedItem().get_value());

                $.ajax({
                    type: "POST",
                    url: "Procedure.aspx/SaveEbusAbnosData",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function () {
                        setRehideSummary();
                    },
                    error: function (x, y, z) {
                        autoSaveSuccess = false;
                        //show a message
                        var objError = x.responseJSON;
                        var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                        $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                        $find('<%=RadNotification1.ClientID%>').show();
                    }
                });
            }
        </script>
    </telerik:RadScriptBlock>

    <style type="text/css">
        .rbl label {
            display: inline-block;
            width: 100px;
        }

        .mainAbnoTD {
            border: 0px none red;
            border-style: none;
            border-width: 0;
            width: 180px;
        }

        .noborder, .noborder tr, .noborder th, .noborder td {
            border: none;
        }

            .noborder div {
                float: left;
                width: 120px;
            }
    </style>
</head>
<body>

    <form id="form2" runat="server">
        <telerik:RadScriptManager ID="EBUSAbnosRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="EBUSAbnosRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />

        <%--<div class="abnorHeader">
            <asp:Label ID="HeadingLabel" runat="server" Text="EBUS abnormality descriptions"></asp:Label>
        </div>--%>
        <asp:HiddenField ID="SiteIdHiddenField" runat="server" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
                <telerik:RadSplitter ID="RadSplitter1" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">

                    <telerik:RadPane ID="RadPane1" runat="server" Height="450px" Width="95%">
                        <div id="FormDiv">
                            <div class="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">
                                    <table id="EBUSAbnosTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width: 650px;">
                                        <colgroup>
                                            <col>
                                            <col>
                                            <col>
                                        </colgroup>
                                        <thead>
                                            <tr>
                                                <th class="rgHeader" style="text-align: left;">
                                                    <asp:CheckBox ID="NoneCheckBox" runat="server" Text="Normal" ForeColor="Black" />
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>

                                            <tr id="CompressionTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;" class="noborder">
                                                        <tr>
                                                            <td class="mainAbnoTD">
                                                                <div style="float: left; width: 165px;">
                                                                    <asp:Label runat="server" Text="Size:" />
                                                                </div>
                                                                <div style="float: left; width: 250px;">
                                                                    <telerik:RadNumericTextBox ID="SizeRadNumericTextBox" runat="server"
                                                                        ShowSpinButtons="false"
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="0.1"
                                                                        Width="35px"
                                                                        MinValue="0"
                                                                        MaxValue="1">
                                                                        <NumberFormat DecimalDigits="1" />
                                                                    </telerik:RadNumericTextBox>  mm
                                                                </div>
                                                                <div style="float: left; width: 60px;">
                                                                    <asp:Label runat="server" Text="Number:" />
                                                                </div>
                                                                <div style="float: left;">
                                                                    <telerik:RadNumericTextBox ID="SlidingLengthTextBox" runat="server"
                                                                        ShowSpinButtons="false"
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="StenosisTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;" class="noborder">
                                                        <tr>
                                                            <td class="mainAbnoTD">
                                                                <div style="float: left; width: 165px;">
                                                                    <label>Shape:</label>
                                                                </div>
                                                                <div style="float: left; width: calc(100% - 165px);">
                                                                    <asp:RadioButtonList ID="ShapeRadioButtonList" runat="server" CssClass="rbl"
                                                                        CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                                        <asp:ListItem Value="1" Text="oval"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="round"></asp:ListItem>
                                                                        <asp:ListItem Value="3" Text="triangular"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="ObstructionTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;" class="noborder">
                                                        <tr>
                                                            <td class="mainAbnoTD">
                                                                <div style="float: left; width: 165px;">
                                                                    <label>Margin:</label>
                                                                </div>
                                                                <div style="float: left; width: 300px;">
                                                                    <asp:RadioButtonList ID="MarginRadioButtonList" runat="server" CssClass="rbl"
                                                                        CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                                        <asp:ListItem Value="1" Text="indistinct"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="distinct"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="Tr1" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;" class="noborder">
                                                        <tr>
                                                            <td class="mainAbnoTD">
                                                                <div style="float: left; width: 165px;">
                                                                    <label>Echogenecity:</label>
                                                                </div>
                                                                <div style="float: left; width: 300px;">
                                                                    <asp:RadioButtonList ID="EchogenecityRadioButtonList" runat="server" CssClass="rbl"
                                                                        CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                                        <asp:ListItem Value="1" Text="homogeneous"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="heterogeneous"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="Tr2" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;" class="noborder">
                                                        <tr>
                                                            <td class="mainAbnoTD">
                                                                <div style="float: left; width: 165px;">
                                                                    <label>Central hilar structure:</label>
                                                                </div>
                                                                <div style="float: left; width: 300px;">
                                                                    <asp:RadioButtonList ID="CHSRadioButtonList" runat="server" CssClass="rbl"
                                                                        CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                                        <asp:ListItem Value="1" Text="present"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="absent"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="Tr3" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;" class="noborder">
                                                        <tr>
                                                            <td class="mainAbnoTD">
                                                                <div style="float: left; width: 165px;">
                                                                    <label>Coagulation necrosis sign:</label>
                                                                </div>
                                                                <div style="float: left; width: 300px;">
                                                                    <asp:RadioButtonList ID="CNSRadioButtonList" runat="server" CssClass="rbl"
                                                                        CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                                        <asp:ListItem Value="1" Text="present"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="absent"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="Tr4" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;" class="noborder">
                                                        <tr>
                                                            <td class="mainAbnoTD">
                                                                <div style="float: left; width: 165px;">
                                                                    <label>Vascular:</label>
                                                                </div>
                                                                <div style="float: left; width: 300px;">
                                                                    <asp:RadioButtonList ID="VascularRadioButtonList" runat="server" CssClass="rbl"
                                                                        CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                                        <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="No"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="MucosalTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;" class="noborder">
                                                        <tr>
                                                            <td class="mainAbnoTD">
                                                                <fieldset id="DiagnosisFieldset" runat="server">
                                                                    <legend>Biopsies taken</legend>
                                                                    <div style="width: 100%;">
                                                                        <div style="width: 100px;">
                                                                            <label>Number taken:</label>
                                                                        </div>
                                                                        <div style="float: left; width: 150px;">
                                                                            <telerik:RadNumericTextBox ID="NumberTakenRadNumericTextBox" runat="server"
                                                                                ShowSpinButtons="false"
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="35px"
                                                                                MinValue="0">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                            </telerik:RadNumericTextBox>
                                                                        </div>
                                                                        <div style="float: left; width: 80px;">
                                                                            <label>Biopsy type:</label>
                                                                        </div>
                                                                        <div style="float: left;">
                                                                            <telerik:RadDropDownList ID="RegimeDropDown" runat="server" Skin="Windows7" Width="80px"></telerik:RadDropDownList>
                                                                        </div>
                                                                    </div>
                                                                    <div style="width: 100%; padding-top: 10px;">
                                                                        <div style="width: 100px;">
                                                                            <label>Needle type:</label>
                                                                        </div>
                                                                        <div style="float: left; width: 150px;">
                                                                            <telerik:RadDropDownList ID="NeedleTypeRadDropDownList" runat="server" Skin="Windows7" Width="120px"></telerik:RadDropDownList>
                                                                            <telerik:RadDropDownList ID="UnitsRadDropDownList" runat="server" Skin="Windows7" style="padding-top: 10px;"></telerik:RadDropDownList>
                                                                        </div>
                                                                        <div style="float: left; width: 90px;">
                                                                            <label>Diam:</label>
                                                                        </div>
                                                                        <div style="float: left; width: 150px;">
                                                                            <telerik:RadNumericTextBox ID="DiamRadNumericTextBox" runat="server"
                                                                                ShowSpinButtons="false"
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="35px"
                                                                                MinValue="0">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                            </telerik:RadNumericTextBox>
                                                                        </div>
                                                                    </div>
                                                                </fieldset>
                                                            </td>

                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;">
                                <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="WebBlue" Icon-PrimaryIconCssClass="telerikSaveButton" />
                                <telerik:RadButton ID="CancelButton" Visible="false" runat="server" Text="Close" Skin="WebBlue" OnClientClicked="SaveAndClose" Icon-PrimaryIconCssClass="telerikCancelButton" />
                            </div>
                        </div>
                    </telerik:RadPane>
                </telerik:RadSplitter>
            </ContentTemplate>
        </asp:UpdatePanel>


    </form>
</body>

</html>
