<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Tumour.aspx.vb" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Colon_Tumour" %>

<!DOCTYPE html>

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

        .noborder td {
            border: none !important;
        }

        .tableWithNoBorders {
            border: none;
            margin-top: 5px;
            display: none;
        }

            .tableWithNoBorders td {
                border: none;
                height: 15px;
                /*text-align:center;*/
            }
    </style>
    <telerik:RadScriptBlock runat="server">
        
    
    <script type="text/javascript">
        var tumourValueChanged = false;
        var validationMessage = "";
        $(window).on('load', function () {            
            checkAllRadControls($find("NoneCheckBox").get_checked());
            $("input[id*='_CheckBox_ClientState']").each(function () {
                ToggleRow($(this)[0].id.replace("_ClientState", ""));
            });           

            displayTumourDetails();
        });

        function CloseWindow() {            
            window.parent.CloseWindow();
        }

        $(document).ready(function () {            
            $("#ColonTumourTable input:radio").change(function () {                                
                var elemId = $(this).attr("id");
                if ($(this).is(':checked')) {                    
                    if (elemId == "NoneCheckBox") { return; }
                    if (elemId.indexOf("NoneCheckBox") > -1) {                    
                        ClearControls("ContentDiv");
                    }
                    else {
                        $("#NoneCheckBox").prop('checked', false);
                        var dataGroupName = $(this).closest('span').attr('data-parent');                        
                        if (dataGroupName != undefined) {
                            $('[data-child="' + dataGroupName + '"]').show();
                        }
                        else if (elemId.indexOf("TumourTypesRBL") == -1) {
                            $('[data-child]').each(function (idx, itm) {                          
                                $(itm).hide();
                                $('#TumourTypesRBL input').removeAttr('checked');
                            });
                        }
                    }
                }
                tumourChangedLocalStorage();
            });

            $('#PolypTattooedRadioButtonList input').change(function () {
                if ($(this).val() == '2') {
                    setRequiredField('<%=TattooedQtyNumericTextBox.ClientID%>', 'marking total');
                }
                else {
                    removeRequiredField('<%=TattooedQtyNumericTextBox.ClientID%>','marking total');
                }
            });            

            $('#TumourRadioButtonList input').change(function () {            
                displayTumourDetails();
            });
            $("#Tumour_Type_ComboBox, #TumourQtyNumericTextBox, #TumourLargestNumericTextBox, #GranulomaQtyNumericTextBox, #GranulomaLargestNumericTextBox, #DysplasticQtyNumericTextBox, #DysplasticLargestNumericTextBox, #TattooedQtyNumericTextBox").change(function () {
                tumourChangedLocalStorage();
            });

            $('#<%= TumourProbablyCheckBox.ClientID %>').click(function () {
                tumourChangedLocalStorage();
            });

            $('#<%= PolypTattooedRadioButtonList.ClientID %> input[type="radio"]').change(function () {
                tumourChangedLocalStorage();
            });

            $('#<%= TattooedQtyNumericTextBox.ClientID %>').change(function () {
                tumourChangedLocalStorage();
            });

            $(window).on('beforeunload', function () {
                if (tumourValueChanged) {
                    $('#<%=SaveButton.ClientID%>').click();
                }
            });
            $(window).on('unload', function () {
                localStorage.clear();
                setRehideSummary();
            });
        });

        function tumourChangedLocalStorage() {
            tumourValueChanged = true;
            valueChanged();
            const isValid = validateTumour();
            localStorage.setItem('validationRequired', isValid ? 'false' : 'true');
            localStorage.setItem('validationRequiredMessage', isValid ? '' : validationMessage);
        }

        function validateTumour() {
            const noneChecked = $find('<%= NoneCheckBox.ClientID %>').get_checked();
            const tumourChecked = $("input[name='<%= TumourRadioButtonList.ClientID %>']:checked").val() !== undefined;
            const tumourTypeChecked = $find('<%= Tumour_CheckBox.ClientID %>').get_checked();
            const polypTattooedChecked = $("input[name='<%= PolypTattooedRadioButtonList.ClientID %>']:checked").val();
            const granulomaSize = $('#GranulomaLargestNumericTextBox').val();
            const dysplasticSize = $('#DysplasticLargestNumericTextBox').val();
            const tumourSize = $('#TumourLargestNumericTextBox').val();
            const granulomaChecked = $find('<%= Granuloma_CheckBox.ClientID %>').get_checked();
            const dysplasticChecked = $find('<%= Dysplastic_CheckBox.ClientID %>').get_checked();
            if (noneChecked) return true;
            if (granulomaSize >= 20 || dysplasticSize >= 20 || (tumourSize && !noneChecked && !polypTattooedChecked)) {
                validationMessage = "Please specify tumour tattoo details.";
                return false;
            }
            if (!tumourChecked && tumourTypeChecked) {
                validationMessage = "Please select tumour type.";
                return false;
            }
            if ((tumourTypeChecked) && !polypTattooedChecked) {
                validationMessage = "Please mark whether the polyp/cancer was tattooed";
                return false;
            }
            if (polypTattooedChecked !== undefined && parseInt(polypTattooedChecked) === 2) {
                const tattooMarkingComboBoxValue = getComboBoxValue('<%= Tattoo_Marking_ComboBox.ClientID %>');
                const tattooQtyNumericTextBox = $find('<%= TattooedQtyNumericTextBox.ClientID %>').get_value();

                if (tattooMarkingComboBoxValue === 0 || tattooQtyNumericTextBox === '') {
                    validationMessage = "'Using' and 'Number of spots marked' must be completed";
                    return false;
                }
            }
            return true;
        }

        function getComboBoxValue(clientId) {
            const comboBox = $find(clientId).get_selectedItem();
            return comboBox ? parseInt(comboBox.get_value() || 0) : 0;
        }

        function valueChanged() {
            setTimeout(function () {
                const noneChecked = $find('<%= NoneCheckBox.ClientID %>').get_checked();
                const tumourChecked = $("input[name='<%= TumourRadioButtonList.ClientID %>']:checked").val() !== undefined;
                const tumourTypeChecked = $find('<%= Tumour_CheckBox.ClientID %>').get_checked();
                const granulomaChecked = $find('<%= Granuloma_CheckBox.ClientID %>').get_checked();
                const dysplasticChecked = $find('<%= Dysplastic_CheckBox.ClientID %>').get_checked();
                if (noneChecked) {
                    localStorage.setItem('valueChanged', 'true');
                    return;
                }
                else if (!noneChecked && !tumourTypeChecked && !granulomaChecked && !dysplasticChecked) {
                    localStorage.setItem('valueChanged', 'false');
                    return;
                }
                if (!granulomaChecked && !dysplasticChecked) {
                    if (tumourChecked && tumourTypeChecked) {
                        const polypTattooedChecked = $("input[name='<%= PolypTattooedRadioButtonList.ClientID %>']:checked").val();
                        const ned = polypTattooedChecked !== undefined && parseInt(polypTattooedChecked) === 2;

                        if (ned) {
                            const tattooMarkingComboBoxValue = getComboBoxValue('<%= Tattoo_Marking_ComboBox.ClientID %>');
                            const tattooQtyNumericTextBox = $find('<%= TattooedQtyNumericTextBox.ClientID %>').get_value();

                            if (tattooMarkingComboBoxValue === 0 || tattooQtyNumericTextBox === '') {
                                localStorage.setItem('valueChanged', 'false');
                                return;
                            }
                        } else if (polypTattooedChecked === undefined) {
                            localStorage.setItem('valueChanged', 'false');
                            return;
                        }
                    }else if(!tumourChecked && tumourTypeChecked){
                        localStorage.setItem('valueChanged', 'false');
                        return;
                    }
                }
                localStorage.setItem('valueChanged', 'true');
            }, 10);
        }

        function displayTumourDetails() {
            var rblSelectedValue = $('#TumourRadioButtonList input:checked').val();
            var tumourChk = $find("Tumour_CheckBox").get_checked();
            
            if (rblSelectedValue > 0 && tumourChk) {            
                $("#trTumourDetails").show();
            } else if (tumourChk) {               
                $("#trTumourDetails").hide();
            }   
        }

        function ToggleTRs(sender, args) {
            ToggleRow(sender.get_element().id, args.get_checked());
            tumourChangedLocalStorage();
        }

        function ToggleRow(chkBoxId, ticked) {
            
            if (chkBoxId != "NoneCheckBox") {                
                
                if (ticked == undefined) {
                    
                    ticked = $find(chkBoxId).get_checked();
                }
                var tableId = chkBoxId.replace("_CheckBox", "Table");
                var table = $telerik.$("[id$='" + tableId + "']");
                
                $("#" + chkBoxId).parents("td").eq(1)
                    .next('td').children('table').each(function () {
                        if (ticked) {                
                            $(this).show();
                        }
                        else {                            
                            $(this).hide();
                        }
                    });

                if (chkBoxId = "Tumour_CheckBox") { displayTumourDetails(); }
                
                if (ticked) {
                    $find("NoneCheckBox").set_checked(false);
                    $('#LesionsSpotsTattooedFieldset').show();
                    //set required fields
                    setRequiredField('<%=PolypTattooedRadioButtonList.ClientID%>', 'tattoo/marking');
                }
                else {
                    //Check if any other checkboxes are ticked. If not, hide NED Fieldset
                    var anyChecked = false;
                    var allRadControls = $telerik.radControls;
                    for (var i = 0; i < allRadControls.length; i++) {
                        var element = allRadControls[i];
                        var elemId = element.get_element().id;
                        if ((elemId != "NoneCheckBox") && (elemId.indexOf("_CheckBox") > 0) || elemId.indexOf("CheckBox") > 0) {
                            if (element.get_checked()) {
                                anyChecked = true;
                                return;
                            }
                        }
                    }

                    if (!anyChecked) {
                        $('#LesionsSpotsTattooedFieldset').hide();
                        //remove required fields
                        removeRequiredField('<%=PolypTattooedRadioButtonList.ClientID%>', 'tattoo/marking');

                    }
                }
            }
        }

        function ToggleNoneCheckBox(sender, args) {
            //check if none is checked, if so hide lesions fieldset
            checkAllRadControls(args.get_checked());
            if ($find('<%= Tumour_CheckBox.ClientID %>').get_checked() === false) {
                
            }
            tumourChangedLocalStorage();
        }

        function checkAllRadControls(noneChecked) {
            if (!noneChecked) { return; }

            var allRadControls = $telerik.radControls;
            for (var i = 0; i < allRadControls.length; i++) {
                var element = allRadControls[i];
                if (Telerik.Web.UI.RadButton && Telerik.Web.UI.RadButton.isInstanceOfType(element)) {
                    var elemId = element.get_element().id;
                    if ((elemId != "NoneCheckBox") && (elemId.indexOf("_CheckBox") > 0 || elemId.indexOf("CheckBox") > 0)) {
                        element.set_checked(false);
                        $('#LesionsSpotsTattooedFieldset').hide();
                    }
                } else if (Telerik.Web.UI.RadNumericTextBox && Telerik.Web.UI.RadNumericTextBox.isInstanceOfType(element)) {
                    var elemId = element.get_element().id;
                    if ((elemId.indexOf("NumericTextBox") > 0)) {
                        element.clear();
                    }
                }
            }
            $('input[name$="TumourRadioButtonList"]').prop('checked', false);
            $('input[name$="PolypTattooedRadioButtonList"]').prop('checked', false);
            var comboBox = $find('<%=PolypTattooedRadioButtonList.ClientID %>');
            if(comboBox !== null) comboBox.clearSelection();
            comboBox = $find('<%= Tattoo_Marking_ComboBox.ClientID%>');
            if (comboBox !== null) comboBox.clearSelection();
        }

        function OnRadNotificationHidden() {
            var tumourChk = $find("Tumour_CheckBox").get_checked();
            var granulomaChk = $find("Granuloma_CheckBox").get_checked();
            var dysplasticChk = $find("Dysplastic_CheckBox").get_checked();

            if (tumourChk) {
                $find("Tumour_CheckBox").set_checked(false);
                $find("Tumour_CheckBox").set_checked(true);
            }

            if (granulomaChk) {
                $find("Granuloma_CheckBox").set_checked(false);
                $find("Granuloma_CheckBox").set_checked(true);
            }

            if (dysplasticChk) {
                $find("Dysplastic_CheckBox").set_checked(false);
                $find("Dysplastic_CheckBox").set_checked(true);
            }
        }

        function TumourProbablyCheckedChange(sender, args) {
            tumourChangedLocalStorage();
        }
        function Tumour_Type_ComboBox_SelectedIndexChanged(sender, args) {
            tumourChangedLocalStorage();
        }
        function Tattoo_Marking_ComboBoxSelectedIndexChanged(sender, args) {
            tumourChangedLocalStorage();
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
                                <telerik:RadScriptManager ID="DeformityRadScriptManager" runat="server" />
                                <telerik:RadFormDecorator ID="DeformityRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
                                <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" OnClientHidden="OnRadNotificationHidden" />
                                <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" >
                                    <AjaxSettings>
                                        <telerik:AjaxSetting AjaxControlID="SaveButton">
                                            <UpdatedControls>
                                                <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                                            </UpdatedControls>
                                        </telerik:AjaxSetting>
                                    </AjaxSettings>
                                </telerik:RadAjaxManager>
                                
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
            <div class="abnorHeader">Tumour</div>
                <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="786px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
                    <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">
                        <div id="ContentDiv">
                            <div class="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">
                                    <table id="ColonTumourTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width: 776px; table-layout: fixed;">
                                        <thead>
                                            <tr>
                                                <th width="130px" height="30px" class="rgHeader" style="text-align: left;">
                                                    <telerik:RadButton ID="NoneCheckBox" runat="server" Text="None" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" Skin="Web20" OnClientCheckedChanged="ToggleNoneCheckBox" Font-Bold="true"></telerik:RadButton>
                                                </th>
                                                <th width="70px" class="rgHeader">Quantity</th>
                                                <th width="70px" class="rgHeader">Size of
                                                    <br />
                                                    largest (mm)</th>
                                                <th width="70px" class="rgHeader"></th>
                                                <th width="70px" class="rgHeader"></th>
                                                <th width="70px" class="rgHeader"></th>
                                                <th width="70px" class="rgHeader"></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                                <tr>
                                                    <td style="padding: 0px; height: 40px; vertical-align: top;">
                                                        <table style="width: 100%;" id="ColonTumours">
                                                            <tr>
                                                                <td style="border: none;">
                                                                    <telerik:RadButton ID="Tumour_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Gray" Text="Tumour" Skin="Web20" OnClientCheckedChanged="ToggleTRs" AutoPostBack="false"></telerik:RadButton>
                                                                    <img src="../../../../Images/NEDJAG/JAGNED.png" />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                    <td colspan="6" style="padding: 0px;">
                                                        <table width="100%" class="tableWithNoBorders" id="SubTumourTable" cellpadding="0" cellspacing="0">
                                                            <tr>
                                                                <td width="85px" colspan="4" style="vertical-align: top;">
                                                                    <asp:RadioButtonList ID="TumourRadioButtonList" runat="server"
                                                                        CellSpacing="25" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl">
                                                                        <asp:ListItem Value="1" Text="Submucosal"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="Villous"></asp:ListItem>
                                                                        <asp:ListItem Value="3" Text="Ulcerative"></asp:ListItem>
                                                                        <asp:ListItem Value="4" Text="Stricturing"></asp:ListItem>
                                                                        <asp:ListItem Value="5" Text="Polypoidal"></asp:ListItem>
                                                                    </asp:RadioButtonList>

                                            </td>
                                        </tr>
                                        <tr id="trTumourDetails">
                                            <td class="rgCell" width="85px">
                                                <telerik:RadNumericTextBox ID="TumourQtyNumericTextBox" runat="server"
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MinValue="0">
                                                    <NumberFormat DecimalDigits="0" />
                                                </telerik:RadNumericTextBox>
                                            </td>
                                            <td class="rgCell" width="85px">
                                                <telerik:RadNumericTextBox ID="TumourLargestNumericTextBox" runat="server"
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MinValue="0">
                                                    <NumberFormat DecimalDigits="0" />
                                                </telerik:RadNumericTextBox>
                                            </td>
                                            <td align="right">
                                                <telerik:RadButton ID="TumourProbablyCheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Probably" Skin="Web20"></telerik:RadButton>
                                            </td>
                                            <td align="left">
                                                <telerik:RadComboBox ID="Tumour_Type_ComboBox" runat="server" Skin="Windows7" DataTextField="Description" DataValueField="UniqueId" AppendDataBoundItems="true">
                                                    <Items>
                                                        <telerik:RadComboBoxItem Text="" Value="" />
                                                    </Items>
                                                </telerik:RadComboBox>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                        </tr>
                        <tr>
                            <td style="padding: 0px; height: 40px;">
                                <table style="width: 100%;">
                                    <tr>
                                        <td style="border: none;">
                                            <telerik:RadButton ID="Granuloma_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Suture granuloma" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td colspan="6" style="padding: 0px;">
                                <table width="100%" class="tableWithNoBorders" id="GranulomaTable">
                                    <tr>
                                        <td class="rgCell" width="70px">
                                            <telerik:RadNumericTextBox ID="GranulomaQtyNumericTextBox" runat="server"
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="1"
                                                Width="35px"
                                                MinValue="0">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell" width="70px">
                                            <telerik:RadNumericTextBox ID="GranulomaLargestNumericTextBox" runat="server"
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="1"
                                                Width="35px"
                                                MinValue="0">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td align="right"></td>
                                        <td align="left"></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding: 0px; height: 40px;">
                                <table style="width: 100%;">
                                    <tr>
                                        <td style="border: none;">
                                            <telerik:RadButton ID="Dysplastic_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Dysplastic lesion" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td colspan="6" style="padding: 0px;">
                                <table width="100%" class="tableWithNoBorders" id="DysplasticTable">
                                    <tr>
                                        <td class="rgCell" width="70px">
                                            <telerik:RadNumericTextBox ID="DysplasticQtyNumericTextBox" runat="server"
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="1"
                                                Width="35px"
                                                MinValue="0">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell" width="70px">
                                            <telerik:RadNumericTextBox ID="DysplasticLargestNumericTextBox" runat="server"
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="1"
                                                Width="35px"
                                                MinValue="0">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td></td>
                                        <td></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                                   
                        <tr>
                            <td colspan="7">
                                <fieldset id="LesionsSpotsTattooedFieldset" runat="server">
                                    <legend>National Data Set Requirement
                                    <img src="../../../../Images/NEDJAG/NED.png" /></legend>
                                    <table width="100%" style="padding: 0px;">
                                        <tr>
                                            <td style="border: none; width: 35%;">Was the polyp/cancer tattooed?</td>
                                            <td style="border: none;">
                                                <asp:RadioButtonList ID="PolypTattooedRadioButtonList" runat="server"
                                                    CellSpacing="25" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl" DataTextField="Description" DataValueField="UniqueId" />
                                            </td>

                                        </tr>
                                        <tr id="trTattooMarkingDetails">
                                            <td style="border: none; width: 35%;">Using&nbsp;
                                <telerik:RadComboBox ID="Tattoo_Marking_ComboBox" runat="server" Skin="Windows7" DataTextField="Description" DataValueField="UniqueId" AppendDataBoundItems="true" OnClientDropDownClosed="Tattoo_Marking_ComboBoxSelectedIndexChanged">
                                    <Items>
                                        <telerik:RadComboBoxItem Text="" Value="" />
                                    </Items>
                                </telerik:RadComboBox>
                                            </td>
                                            <td style="border: none;">Number of spots marked&nbsp;
                                <telerik:RadNumericTextBox ID="TattooedQtyNumericTextBox" runat="server"
                                    IncrementSettings-InterceptMouseWheel="false"
                                    IncrementSettings-Step="1"
                                    Width="35px"
                                    MinValue="0">
                                    <NumberFormat DecimalDigits="0" />
                                </telerik:RadNumericTextBox>
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>
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
                <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" OnClientClicking="validatePage" />
                <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
                </telerik:RadPane>
                </telerik:RadSplitter>
            </ContentTemplate>
        </asp:UpdatePanel>

    </form>
</body>
</html>
