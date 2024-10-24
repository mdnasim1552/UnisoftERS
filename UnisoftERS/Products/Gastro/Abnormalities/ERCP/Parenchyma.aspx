<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_ERCP_Parenchyma" CodeBehind="Parenchyma.aspx.vb" %>

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
        var parenchymaValueChanged = false;

        $(window).on('load', function () {
            $('input[type="checkbox"]').each(function () {
                ToggleTRs($(this));
            });
            ToggleMassType();
        });

        $(document).ready(function () {
            $("#ParenchymaTable tr td:first-child input:checkbox").change(function () {
                ToggleTRs($(this));
                parenchymaValueChanged = true;
            });

            $("#NoneCheckBox").change(function () {
                ToggleNoneCheckBox($(this).is(':checked'));
                parenchymaValueChanged = true;
            });
            //Added by rony tfs-4166;
            $(window).on('beforeunload', function () {
                if (parenchymaValueChanged) {
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
            $("#ParenchymaTable tr td:first-child").each(function () {
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
        function ToggleProbably() {
            var checked = $('#ProbablyCheckBox').is(':checked');
            if (checked) {
                $("label[for='CholangiocarcinomaCheckBox']").text("probable cholangiocarcinoma");
                //$("#CholangiocarcinomaCheckBox").val("probably cholangiocarcinoma");
            }
            else {
                $("label[for='CholangiocarcinomaCheckBox']").text("cholangiocarcinoma");
                //$("#CholangiocarcinomaCheckBox").val("cholangiocarcinoma");
            }
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
                 if (chkbox[0].id == "CystsCheckBox") {
                    ToggleCystType();
                }

                if (chkbox[0].id == "MassDistortingAnatomyCheckBox") {
                    ToggleMassType();
                }
            }
        }
         //changed by mostafiz issue 3647
        function ToggleNoneCheckBox(checked) {
            if (checked) {
                $("#ParenchymaTable tr td:first-child").each(function () {
                    $(this).find("input:checkbox:checked").prop('checked', false);
                    $(this).find("input:checkbox").trigger("change");
                });
            }
        }

        function ToggleCystType() {
            if ($("#CystsTypeCell input:checkbox:checked").length > 0) {
                $("#CystsCommunicatingRow").show();
                $("#CystsSuspectedRow").show();
            }
            else {
                $("#CystsCommunicatingRow").hide();
                $("#CystsSuspectedRow").hide();
                ClearControls($("#CystsCommunicatingCell"));
                ClearControls($("#CystsSuspectedCell"));
            }
        }

        function ToggleMassType() {
            var selectedVal = $('#MassTypeRadioButtonList input:checked').val();

            if (selectedVal == undefined) {
                $("#ProbablyDiv").hide();
                $("#ProbablyCheckBox").prop("checked", false);
            }

            if (selectedVal > 0) {
                $("#ProbablyDiv").show();
            }
        }

        function ClearQtyTextBox() {
            if ($('#StonesMultipleCheckBox').is(':checked')) {
                $find("StonesQtyNumericTextBox").set_value("");
            }
            else if ($('#CystsMultipleCheckBox').is(':checked')) {
                $find("CystsQtyNumericTextBox").set_value("");
            }
        }
         //changed by mostafiz issue 3647
        function ClearControls(tableCell) {
            tableCell.find("input:radio:checked").prop('checked', false);
            tableCell.find("input:checkbox:checked").prop('checked', false);
            tableCell.find("input:text").val("");
        }
        function ClearMultipleCheckBox(sender, args) {
            if (args.get_newValue() != "") {
                var chkBoxId = "";
                if (sender._clientID == "StonesQtyNumericTextBox") {
                    chkBoxId = "StonesMultipleCheckBox";
                }
                else if (sender._clientID == "CystsQtyNumericTextBox") {
                    chkBoxId = "CystsMultipleCheckBox";
                }
                //$("#" + chkBoxId + " input:checkbox:checked").removeAttr("checked");
                $("#" + chkBoxId).prop("checked", false);
            }
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
        <telerik:RadScriptManager ID="ParenchymaRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="ParenchymaFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
       
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Parenchyma</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">
                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">
                            <table id="ParenchymaTable" class="rgview" cellpadding="0" cellspacing="0"  width="780px">
                                <colgroup>
                                    <col><col><col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th width="260px" class="rgHeader" style="text-align: left;">
                                            <asp:CheckBox ID="NoneCheckBox" runat="server" Text="No abnormalities detected" />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="IrregularDuctulesCheckBox" runat="server" Text="Irregular ductules" />
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
                                                        <asp:CheckBox ID="DilatedDuctulesCheckBox" runat="server" Text="Dilated ductules" />
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
                                                        <asp:CheckBox ID="SmallLakesCheckBox" runat="server" Text="Small lakes" />
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
                                                        <asp:CheckBox ID="StricturesCheckBox" runat="server" Text="Strictures" />
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
                                                        <%--Mahfuz changed Mass distorting anatomy to Mass on 14 May 2021--%>
                                                        <asp:CheckBox ID="MassDistortingAnatomyCheckBox" runat="server" Text="Mass" />
                                                    </td>
                                                </tr>
                                                <tr childrow="1" id="MassDistortingAnatomyChildRow" runat="server">
                                                    <td style="border: none;">
                                                        <div class="divChildControl" style="margin-top:-5px;">
                                                            <asp:RadioButtonList ID="MassTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" CssClass="rblType"
                                                                onchange="ToggleMassType();">
                                                                <asp:ListItem Value="1" Text="hepatoma"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="metastases"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </div>
                                                        <div id="ProbablyDiv" class="divChildControl">
                                                            <asp:CheckBox ID="ProbablyCheckBox" runat="server" Text="probably" />
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <%--Mahfuz added Cysts or Cystic Lesion on 14 May 2021--%>
                                    <tr id="trCysts" runat="server">
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table border ="0" style="width: 100%;">
                                                <tr headrow="1" haschildrows="1">
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="CystsCheckBox" runat="server" Text="Cystic Lesion" />
                                                    </td>
                                                </tr>
                                                <tr childrow="1">
                                                    <td style="border: none;">
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="CystsMultipleCheckBox" runat="server" Text="multiple" onchange="ClearQtyTextBox();" />
                                                        </div>
                                                        <div class="divChildControl" style="margin-left: 15px; margin-top: 3px;">
                                                            <label><i>OR</i></label>
                                                        </div>
                                                        <div class="divChildControl">
                                                            <label>qty</label>
                                                            <telerik:RadNumericTextBox ID="CystsQtyNumericTextBox" runat="server"
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="35px"
                                                                MinValue="0"
                                                                NumberFormat-DecimalDigits="0">
                                                                <ClientEvents OnValueChanged="ClearMultipleCheckBox" />
                                                            </telerik:RadNumericTextBox>
                                                        </div>
                                                        <div class="divChildControl">
                                                            <label>diameter of largest</label>
                                                            <telerik:RadNumericTextBox ID="CystsDiameterNumericTextBox" runat="server"
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="0.5"
                                                                Width="35px"
                                                                MinValue="0">
                                                                <NumberFormat DecimalDigits="1" />
                                                            </telerik:RadNumericTextBox>
                                                            <label>mm</label>
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr childrow="1">
                                                    <td style="border: none;" id="CystsTypeCell">
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="CystsSimpleCheckBox" runat="server" Text="Simple" onchange="ToggleCystType()" />
                                                        </div>
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="CystsRegularCheckBox" runat="server" Text="Regular" onchange="ToggleCystType()" />
                                                        </div>
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="CystsIrregularCheckBox" runat="server" Text="Irregular" onchange="ToggleCystType()" />
                                                        </div>
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="CystsLoculatedCheckBox" runat="server" Text="Loculated" onchange="ToggleCystType()" />
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr childrow="1" id="CystsCommunicatingRow">
                                                    <td id="CystsCommunicatingCell" style="border: none;">
                                                        <div class="divChildControl" id="CystsCholedochalDiv" runat="server">
                                                            <asp:CheckBox ID="CystsCholedochalCheckBox" runat="server" Text="Choledochal cyst" />
                                                        </div>
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="CystsCommunicatingCheckBox" runat="server" Text="Communicating with biliary duct" />
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr childrow="1" id="CystsSuspectedRow" runat="server">
                                                    <td id="CystsSuspectedCell" style="border: none;">
                                                        <div class="divChildControl" style="margin-top: -5px;">
                                                            <asp:RadioButtonList ID="CystsSuspectedTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" CssClass="rblType">
                                                                <asp:ListItem Value="1" Text="Suspected polycystic disease"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="Suspected hydatid cyst"></asp:ListItem>
                                                                <asp:ListItem Value="3" Text="Suspected liver abscess"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <%--Cystic Lesion finished--%>
                                   

                                    <tr  id="SpideryStretchedDuctulesRow" runat="server"  class="HideForPancreaticParenchyma">
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr headrow="1" haschildrows="1">
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="SpideryStretchedDuctulesCheckBox" runat="server" Text="Spidery stretched ductules" />
                                                    </td>
                                                </tr>
                                                <tr childrow="1">
                                                    <td style="border: none;">
                                                        <div class="divChildControl" style="margin-top:-5px;">
                                                            <asp:RadioButtonList ID="SpideryDuctulesRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" CssClass="rblType">
                                                                <asp:ListItem Value="1" Text="suspected cirrhosis"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="suspected polycystic liver disease"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr  id="MultipleStricturesRow" runat="server" class="HideForPancreaticParenchyma">
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr headrow="1" haschildrows="1">
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="MultipleStricturesCheckBox" runat="server" Text="Multiple strictures/dilatation" />
                                                    </td>
                                                </tr>
                                                <tr childrow="1">
                                                    <td style="border: none;">
                                                        <div class="divChildControl" style="margin-top: -5px;">
                                                            <asp:RadioButtonList ID="MultipleStricturesRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" CssClass="rblType">
                                                                <asp:ListItem Value="1" Text="suspected sclerosing cholangitis"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="suspected Caroli's disease"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-left:13px;">
                                            <asp:CheckBox ID="AnnulareCheckBox" runat="server" Text="Annulare" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-left:13px;">
                                            <asp:CheckBox ID="OcclusionCheckBox" runat="server" Text="Occlusion" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-left:13px;">
                                            <asp:CheckBox ID="BiliaryLeakCheckBox" runat="server" Text="Biliary leak" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-left:13px;">
                                            <asp:CheckBox ID="PreviousSurgeryCheckBox" runat="server" Text="Previous Surgery" />
                                        </td>
                                    </tr>
                                    <tr id="PancreatitisRow" runat="server" visible="false">
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr headrow="1" haschildrows="1">
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="PancreatitisCheckBox" runat="server" Text="Pancreatitis" />
                                                    </td>
                                                </tr>
                                                <tr childrow="1">
                                                    <td style="border: none;">
                                                        <div class="divChildControl" style="margin-top: -5px;">
                                                            <asp:RadioButtonList ID="PancreatitisTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" CssClass="rblType">
                                                                <asp:ListItem Value="1" Text="Acute"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="Chronic"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </div>
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
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;display:none">
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