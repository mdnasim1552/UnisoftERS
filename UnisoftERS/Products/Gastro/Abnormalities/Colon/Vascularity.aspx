<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Colon_Vascularity" Codebehind="Vascularity.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
       <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" Visible="False" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />

    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            var vascularityValueChanged = false;
            function savePage() {
                $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest();
            }            

            $(document).ready(function () {

                $("#NoneCheckBox").change(function () {
                    ToggleNoneCheckBox($(this).is(':checked'));
                    valueChanged();
                });
                $('input[type="radio"]').change(function () {
                    ToggleTRs($(this));

                    valueChanged();

                });
                $("#MultipleCheckbox").change(function () {
                    valueChanged();
                });
                $("#QuantityTextBox").focusout(function () {
                    clearMultiple();
                    valueChanged();
                });
                $("#ASizeTextBox").focusout(function () {
                    valueChanged();
                });
                $(window).on('beforeunload', function () {
                    if (vascularityValueChanged) $('#<%=SaveButton.ClientID%>').click();
                });
                $(window).on('unload', function () {
                    localStorage.clear();
                    setRehideSummary();
                });
            });

            function valueChanged() {
                vascularityValueChanged = true;
                var valueToSave = false;
                $("#ContentDiv input:radio").each(function () {
                    if ($(this).is(':checked')) valueToSave = true;
                });
                if (!$('#NoneCheckBox').is(':checked') && !valueToSave)
                    localStorage.setItem('valueChanged', 'false');
                else
                    localStorage.setItem('valueChanged', 'true');

            }
            //changed by mostafiz issue 3647
            function ToggleTRs(chkbox) {

                var checked = chkbox.is(':checked');
                if (checked) {
                    $("#NoneCheckBox").prop('checked', false);  
                }
                if ($("#<%= Telangiectasia_RadioButton.ClientID%>").is(':checked') == true) {
                    $("#cell").show(); $("#sizediv").hide();
                } else if ($("#<%= Angiodysplasia_RadioButton.ClientID%>").is(':checked') == true) {
                    $("#cell").show(); $("#sizediv").show();
                } else {
                    $("#cell").hide(); $("#sizediv").hide();
                }
                $("#<%= MultipleCheckbox.ClientID%>").prop("checked", false);
                $("#<%= QuantityTextBox.ClientID%>").val("");
                $("#<%= ASizeTextBox.ClientID%>").val("");
            }

            function CloseWindow() {
                window.parent.CloseWindow();
            }

            function clearMultiple() {
                $("#<%= MultipleCheckbox.ClientID%>").prop("checked", false);
        }
        function clearQuantity() {
            if ($("#<%= MultipleCheckbox.ClientID%>").is(':checked') == true) {
                $("#<%= QuantityTextBox.ClientID%>").val("");
            }
            }
        //changed by mostafiz issue 3647
        function ToggleNoneCheckBox(checked) {
            if (checked) {
                $("#VascularTable tr td:first-child").each(function () {
                    $(this).find("input:radio:checked").prop('checked', false);
                    $(this).find("input:radio").trigger("change");
                });
            }
        }

            <%--function showOptions() {
            if ($("#<%= Telangiectasia_RadioButton.ClientID%>").is(':checked') == true) {
                $("#cell").show();
            } else if ($("#<%= Angiodysplasia_RadioButton.ClientID%>").is(':checked') == true) {
                $("#cell").show();
            } else {
                $("#cell").hide();
            }
            
        }--%>
        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">
           <telerik:RadScriptManager ID="VascularityRadScriptManager" runat="server" EnablePageMethods="True"/>
        
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Vascularity</div>
         
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">

          <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">
                <telerik:RadAjaxPanel ID="RadAjaxPanel1" runat="server">
                    <div id="ContentDiv">
                        <div class="siteDetailsContentDiv">
                            <div class="rgview" id="rgAbnormalities" runat="server">
                                <table id="VascularTable" runat="server" cellpadding="3" cellspacing="3" style="width: 780px;">
                                    <thead>
                                        <tr>
                                            <th class="rgHeader" style="text-align: left;" colspan="3">
                                                <asp:CheckBox ID="NoneCheckBox" runat="server" Text="No vascular lesions" ForeColor="Black" />
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td colspan="2">
                                                <asp:RadioButton ID="Indistinct_RadioButton" runat="server" Text="Indistict" Skin="Web20" GroupName="vas" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <asp:RadioButton ID="Exaggerated_RadioButton" runat="server" Text="Exaggerated" Skin="Web20" GroupName="vas" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <asp:RadioButton ID="Attenuated_RadioButton" runat="server" Text="Attenuated with Neovascularization" Skin="Web20" GroupName="vas" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td >
                                                <asp:RadioButton ID="Telangiectasia_RadioButton" runat="server" Text="Telangiectasia" Skin="Web20" GroupName="vas" />
                                            </td>                                            
                                            <td id="cell" align="justify" colspan="1" rowspan="2" valign="middle" style="display:none;">
                                                <div style="text-align:right;width:55%;">
                                                    <div style="padding-bottom: 5px;">
                                                        <asp:CheckBox ID="MultipleCheckbox" runat="server" Text="Multiple &nbsp;<i>OR</i>&nbsp; Quantity" Skin="Web20" onclick="Javacript:clearQuantity();" />
                                                        <%--<asp:Label ID="lblor1" runat="server"><b>OR</b></asp:Label>
                                                        <asp:Label ID="TQlabel" runat="server">Quantity</asp:Label>--%>
                                                        <telerik:RadNumericTextBox ID="QuantityTextBox" runat="server"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="45px"
                                                            MinValue="0" ClientEvents-OnValueChanged="clearMultiple">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox> 
                                                        <asp:Label ID="Label1" runat="server" Width="20"></asp:Label>
                                                    </div>                                               
                                                    <div runat="server" id="sizediv" style="display: none;">
                                                        <asp:Label ID="ASlabel" runat="server">Size of largest</asp:Label>
                                                        <telerik:RadNumericTextBox ID="ASizeTextBox" runat="server"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="45px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                        <asp:Label ID="Amlabel" runat="server" Width="20">mm</asp:Label>
                                                    </div>
                                                </div>
                                            </td>

                                        </tr>
                                        <tr>
                                            <td >
                                                <asp:RadioButton ID="Angiodysplasia_RadioButton" runat="server" Text="Angiodysplasia" Skin="Web20" GroupName="vas" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td >
                                                <asp:RadioButton ID="RadiationProtitis_RadioButton" runat="server" Text="Radiation proctitis" Skin="Web20" GroupName="vas" />
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
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px; display:none">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
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
