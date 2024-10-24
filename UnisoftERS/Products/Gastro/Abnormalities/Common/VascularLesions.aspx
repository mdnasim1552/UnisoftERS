<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Common_VascularLesions" Codebehind="VascularLesions.aspx.vb" %>

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
        var isDuodenum;
        var vascularLesionsValueChanged = false;
        //for this page issue 4166  by Mostafiz
        $(window).on('load', function () {
            QtyChanged();
            MultipleChecked();
            ToggleTypeRadioList();
            if ($("#NoneCheckBox").is(':checked')) {
               // ValidatorEnable(document.getElementById("TypeRequiredFieldValidator"), false);
                
            }
        });
        //changed by mostafiz issue 3647 
        $(document).ready(function () {
            $("#FormDiv input:checkbox, input:radio, input[type=text]").change(function () {
                vascularLesionsValueChanged = true;
                if ($(this).is(':checked')) {
                    var elemId = $(this).attr("id");
                    if (elemId.indexOf("NoneCheckBox") > -1) {
                        ClearControls("FormDiv");
                    }
                    else {
                        $("#NoneCheckBox").prop('checked', false);
                    }
                }
            });

            $(window).on('beforeunload', function(){
                if (vascularLesionsValueChanged) {
                    valueChange();
                    $("#SaveButton").click();
                }
            });

            $(window).on('unload', function () {
                localStorage.clear();
            });
        });

        function valueChange() {
            var vascularLesionsselected = $("#FormDiv input:radio:checked").length;
            var noneChecked = $("#FormDiv input:checkbox:checked").length;
            if (vascularLesionsselected>0 || noneChecked) {
                localStorage.setItem('valueChanged', 'true');
            } else {
                localStorage.setItem('valueChanged', 'false');
            }
        }


        function CloseWindow() {
            window.parent.CloseWindow();
        }
        //changed by mostafiz issue 3647 
        function ClearControls(parentCtrlId) {
            $("#" + parentCtrlId + " input:checkbox:checked").not("[id*='NoneCheckBox']").prop('checked', false);
            $("#" + parentCtrlId + " input:radio:checked").prop('checked', false);
            $("#" + parentCtrlId + " input:text").val('');
            $("#" + parentCtrlId + " textarea").val('');
            ToggleTypeRadioList();
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
            if ($("#NoneCheckBox").is(':checked')) {
               // ValidatorEnable(document.getElementById("TypeRequiredFieldValidator"), false);
            } else {
               // ValidatorEnable(document.getElementById("TypeRequiredFieldValidator"), true);
            }

            var valid = Page_ClientValidate("Save");
            if (!valid) {
                $find("SaveRadNotification").show();
            }
        }

        function ToggleTypeRadioList() {
            var selectedVal = $("#TypeRadioButtonList input:checked").val();
            if ((selectedVal >= 1 && selectedVal <= 5) || (selectedVal >= 1 && isDuodenum)) {
                $('.classHideTypeTR').show();
            }
            else {
                $('.classHideTypeTR').hide();
                $find("QuantityNumericTextBox").set_value("");
                $("#MultipleCheckBox").removeAttr("checked");
            }
            if (selectedVal >= 1) {
                $('.classHideBleedingTR').show();
            } else {
                $('.classHideBleedingTR').hide();
                $("table[id$=BleedingRadioButtonList] input:radio:checked").removeAttr("checked");
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
        <telerik:RadScriptManager ID="VascularLesionsRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="VascularLesionsRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Vascular Lesions</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="700px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">
                
                <div id="FormDiv" runat="server">
                    
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgVascularLesions" runat="server" >
                            <table id="VascularLesionsTable" class="rgview" cellpadding="0" cellspacing="0" width="780px">
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

                    <div  style="margin:20px 10px;">
                        <fieldset id="GradingFieldset" runat="server" class="siteDetailsFieldset" style="display:block;width:750px;">
                            <legend>Type</legend>
                            <table>
                                <tr>
                                    <td>
                                        <asp:RadioButtonList ID="TypeRadioButtonList" name="TypeRadioButtonList" runat="server"
                                            RepeatDirection="Vertical" RepeatLayout="Table" onchange="ToggleTypeRadioList();">
                                        <%--    <asp:ListItem Value="1" Text="Telangiectasia"></asp:ListItem>
                                            <asp:ListItem Value="2" Text="Angiodysplasia (<5mm)"></asp:ListItem>
                                            <asp:ListItem Value="3" Text="Angiodysplasia (>5mm)"></asp:ListItem>
                                            <asp:ListItem Value="4" Text="Angiodysplasia (large and small lesions)"></asp:ListItem>
                                            <asp:ListItem Value="5" Text="Portal hypertensive gastropathy"></asp:ListItem>
                                            <asp:ListItem Value="6" Text="Watermelon stomach"></asp:ListItem>--%>
                                        </asp:RadioButtonList>

                                    </td>
                                    <td>
                                        <%--<asp:RequiredFieldValidator ID="TypeRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="TypeRadioButtonList" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Please specify the type." ToolTip="This is a required field"
                                        ValidationGroup="Save" Text=" *" EnableTheming="True">
                                    </asp:RequiredFieldValidator>--%>
                                    </td>
                                </tr>
                                <tr style="height:10px;"><td></td></tr>
                                <tr class="classHideTypeTR">
                                    <td colspan="2" class="rfdAspLabel" style="height: 23px;">
                                        <asp:CheckBox ID="MultipleCheckBox" runat="server" Text="Multiple" onchange="MultipleChecked();" />
                                        
                                        &nbsp;&nbsp;&nbsp;
                                        <i>OR</i>
                                        &nbsp;&nbsp;&nbsp;
                                        <asp:label id="QuantityLabel" runat="server" text="Quantity:" />
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
                        <div style="height:15px;"></div>
                        <fieldset id="BleedingFieldset" runat="server" class="siteDetailsFieldset classHideBleedingTR" style="display:block;width:750px;">
                            <legend>Bleeding</legend>
                            <table>
                                <tr class="classHideBleedingTR">
                                    <td>
                                        <asp:RadioButtonList ID="BleedingRadioButtonList" runat="server" CssClass="rbl"
                                            RepeatDirection="Vertical" RepeatLayout="Table" RepeatColumns = "2">
<%--                                            <asp:ListItem Value="1" Text="None" style="padding-right: 50px;"></asp:ListItem>
                                            <asp:ListItem Value="2" Text="Fresh Clot"></asp:ListItem>
                                            <asp:ListItem Value="3" Text="Altered blood"></asp:ListItem>
                                            <asp:ListItem Value="4" Text="Active Bleeding"></asp:ListItem>--%>
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                </div>
                <div>
                            <telerik:RadNotification ID="SaveRadNotification" runat="server" Animation="None"
                                EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                                LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
                                AutoCloseDelay="5000">
                                <ContentTemplate>
                                    <asp:ValidationSummary ID="SaveValidationSummary" runat="server" ValidationGroup="Save" EnableClientScript="true" DisplayMode="BulletList" 
                                        BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                                </ContentTemplate>
                            </telerik:RadNotification>
                        </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; display:none; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton"/> <%--OnClientClicked="checkForValidPage"--%>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
