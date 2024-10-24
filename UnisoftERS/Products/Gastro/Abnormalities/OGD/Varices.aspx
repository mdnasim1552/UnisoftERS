<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_OGD_Varices" Codebehind="Varices.aspx.vb" %>

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
        .rbl label
        {
            margin-right: 15px;
        }
        #RAD_SPLITTER_PANE_CONTENT_ControlsRadPane{
            width: 790px !important;
        }
    </style>
    <script type="text/javascript">
        var varicesValueChanged = false;
        $(window).on('load', function () {
            QtyChanged();
            MultipleChecked();
            ToggleGradingRadioList();
            ToggleBleedingRadioList()
            if ($("#NoneCheckBox").is(':checked')) {
                ValidatorEnable(document.getElementById("GradingRequiredFieldValidator"), false);
            }
        });

        $(document).ready(function () {
            $("#FormDiv input:checkbox, input:radio").change(function () {
                if ($(this).is(':checked')) {
                    var elemId = $(this).attr("id");
                    if (elemId.indexOf("NoneCheckBox") > -1) {
                        ClearControls("FormDiv");
                        ValidatorEnable(document.getElementById("GradingRequiredFieldValidator"), false);
                    }
                    else {
                        $("#NoneCheckBox").prop('checked', false);
                        ValidatorEnable(document.getElementById("GradingRequiredFieldValidator"), true);
                    }
                }
                valueChanged();
            });
            $("#QuantityNumericTextBox").focusout(function () {
                QtyChanged();
                valueChanged();
            });
            $(window).on('beforeunload', function () {
                if (varicesValueChanged) $('#SaveButton').click();
            });
            $(window).on('unload', function () {
                localStorage.clear();
                setRehideSummary();
            });
        });

        function valueChanged() {
            varicesValueChanged = true;
            var valueToSave = false;
            $("#FormDiv input:checkbox, input:radio").each(function () {
                if ($(this).is(':checked')) valueToSave = true;
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
        function ClearControls(parentCtrlId) {
            $("#" + parentCtrlId + " input:checkbox:checked").not("[id*='NoneCheckBox']").prop('checked',false);
            $("#" + parentCtrlId + " input:radio:checked").prop('checked',false);
            $("#" + parentCtrlId + " input:text").val('');
            $("#" + parentCtrlId + " textarea").val('');
            ToggleGradingRadioList();
            ToggleBleedingRadioList()
        }

        function QtyChanged() {
            if ($find("QuantityNumericTextBox").get_value() != "") {
                $("#MultipleCheckBox").removeAttr("checked");
                $("#NoneCheckBox").removeAttr("checked");
            }
        }

        function MultipleChecked() {
            if ($("#MultipleCheckBox").is(':checked')) {
                $find("QuantityNumericTextBox").set_value("");
            }
        }

        function checkForValidPage() {
            var valid = Page_ClientValidate("Save");
            if (!valid) {
                $find("SaveRadNotification").show();
            }
        }

        function ToggleGradingRadioList() {
            var selectedVal = $("#GradingRadioButtonList input:checked").val();
            if (selectedVal >= 1) {
                $('.classHideGradingTR').show();
                $('#RedSignFieldset').show();
                $('#BleedingFieldset').show();
            }
            else {
                $('.classHideGradingTR').hide();
                $('#RedSignFieldset').hide();
                $('#BleedingFieldset').hide();
                $find("QuantityNumericTextBox").set_value("");
                $("#MultipleCheckBox").removeAttr("checked");
                $("table[id$=RedSignRadioButtonList] input:radio:checked").removeAttr("checked");
                $("table[id$=BleedingRadioButtonList] input:radio:checked").removeAttr("checked");
            }
        }

        function ToggleBleedingRadioList() {
            var selectedVal = $("#BleedingRadioButtonList input:checked").val();
            if (selectedVal == 5) {
                $("#WhiteFibrinClotDiv").show();
            }
            else {
                $("#WhiteFibrinClotDiv").hide();
                $("#WhiteFibrinClotCheckBox").removeAttr("checked");
            }
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
        <telerik:RadScriptManager ID="VaricesRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="VaricesRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
       
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Varices</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="700px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="790" Height="410">
                
                <div id="FormDiv" runat="server">
                    
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgVarices" runat="server" >
                            <table id="VaricesTable" class="rgview" cellpadding="0" cellspacing="0" style="width: 780px;">
                                <thead>
                                    <tr>
                                        <th class="rgHeader" width="540px" style="text-align: left;">
                                            <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" Style="margin-right: 10px;" />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div style="margin:15px 10px;">
                        <fieldset id="GradingFieldset" runat="server" style="display:block;width:750px;">
                            <legend class="siteDetailsLegend">Grading</legend>
                            <table>
                                <tr>
                                    <td>
                                        <asp:RadioButtonList ID="GradingRadioButtonList" runat="server"  CssClass="rbl"
                                            RepeatDirection="Horizontal" RepeatLayout="Table" style="margin-left:-3px;" onchange="ToggleGradingRadioList();">
                                            <%--<asp:ListItem Value="1" Text="Small"></asp:ListItem>
                                            <asp:ListItem Value="2" Text="Medium"></asp:ListItem>
                                            <asp:ListItem Value="3" Text="Large"></asp:ListItem>--%>
                                        </asp:RadioButtonList>
                                        
                                    </td>
                                    <td>
                                        <asp:RequiredFieldValidator ID="GradingRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="GradingRadioButtonList" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Please specify the grading." Text="*" ToolTip="This is a required field"
                                        ValidationGroup="Save">
                                    </asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                                <tr style="height:7px;"><td></td></tr>
                                <tr class="classHideGradingTR">
                                    <td colspan="2" class="rfdAspLabel" style="height: 23px;">
                                        <asp:CheckBox ID="MultipleCheckBox" runat="server" Text="Multiple" onchange="MultipleChecked();" />
                                        
                                        &nbsp;&nbsp;&nbsp;
                                        <i>OR</i>
                                        &nbsp;&nbsp;&nbsp;
                                        Quantity:
                                        <telerik:RadNumericTextBox ID="QuantityNumericTextBox" runat="server"
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
                        </fieldset>

                        <table style="padding-top:5px;">
                            <tr>
                                <td valign="top">
                                    <fieldset id="RedSignFieldset" runat="server" style="display:block;width:250px;">
                                        <legend>Red Sign</legend>
                                        <table>
                                            <tr class="classHideGradingTR">
                                                <td>
                                                    <asp:RadioButtonList ID="RedSignRadioButtonList" runat="server"  CssClass="rbl"
                                                        RepeatDirection="Vertical" RepeatLayout="Table">
                                                        <asp:ListItem Value="1" Text="absent"></asp:ListItem>
                                                        <asp:ListItem Value="2" Text="present"></asp:ListItem>
                                                    </asp:RadioButtonList>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                                <td>
                                    <fieldset id="BleedingFieldset" runat="server" style="display:block;width:460px;">
                                        <legend>Bleeding</legend>
                                        <table>
                                            <tr class="classHideGradingTR">
                                                <td>
                                                    <asp:RadioButtonList ID="BleedingRadioButtonList" runat="server" onchange="ToggleBleedingRadioList();"
                                                        RepeatDirection="Vertical" RepeatLayout="Table">
                                                     <%--   <asp:ListItem Value="1" Text="None"></asp:ListItem>
                                                        <asp:ListItem Value="2" Text="Fibrin Plug"></asp:ListItem>
                                                        <asp:ListItem Value="3" Text="Fresh Clot"></asp:ListItem>
                                                        <asp:ListItem Value="4" Text="Red Sign"></asp:ListItem>
                                                        <asp:ListItem Value="5" Text="Active Bleeding"></asp:ListItem>--%>
                                                    </asp:RadioButtonList>
                                                    <div id="WhiteFibrinClotDiv" runat="server">
                                                    <asp:CheckBox ID="WhiteFibrinClotCheckBox" runat="server" Text="White fibrin clot" Style="margin-left: 20px;" />
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div>
                    <telerik:RadNotification ID="SaveRadNotification" runat="server" Animation="None"
                        EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                        LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
                        AutoCloseDelay="70000">
                        <ContentTemplate>
                            <asp:ValidationSummary ID="SaveValidationSummary" runat="server" ValidationGroup="Save" EnableClientScript="true" DisplayMode="BulletList" 
                                BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                        </ContentTemplate>
                    </telerik:RadNotification>
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px; display:none">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" OnClientClicked="checkForValidPage" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
       </ContentTemplate>
       </asp:UpdatePanel>

    </form>
</body>
</html>
