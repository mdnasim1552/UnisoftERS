<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_OGDBarrettEpithelium" CodeBehind="BarrettEpithelium.aspx.vb" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            var barrettEpitheliumValueChange = false;
            var barretValidationMessage = "";
            var noneChecked = false;
            $(window).on('load', function () {
                $("input[id*='_CheckBox_ClientState']").each(function () {
                    ToggleTDs($(this)[0].id.replace("_ClientState", ""));                   
                });
            });
            //changed by mostafiz issue 3647
            $(document).ready(function () {
                $("#NoneCheckBox").click(function () {
                    ToggleNoneCheckBox(); 
                    });
                $("#D1RadNumericTextBox").change(function () {
                    //alert($(this).attr("id"));
                    valueChanged($(this).attr("id")); 
                    });
                $("#D2RadNumericTextBox").change(function () {
                    //alert($(this).attr("id"));
                    valueChanged($(this).attr("id")); 
                    });
                $("#D3RadNumericTextBox").change(function () {
                    //alert($(this).attr("id"));
                    valueChanged($(this).attr("id"));              
                });

                $("#BarrettIslands_CheckBox").click(function () {     
                    barrettEpitheliumValueChangeLocalStorage();
                });

                if ($(window).height() > 600) {
                    $('#RAD_SPLITTER_PANE_CONTENT_ControlsRadPane').css('overflow', 'unset');
                }
              
                $(window).on('beforeunload', function () {
                    if (barrettEpitheliumValueChange && barretValidationMessage == "") {  
                        ValueChanged();
                        $("#SaveButton").click();
                    }
                 });
                $(window).on('unload', function () {
                    localStorage.clear();
                });
            });

            function ValueChanged() {
                var noneCheckbox = $find("NoneCheckBox").get_checked();
                var textBox = $("#BarrettEpitheliumTable tr td:first-child").find("input[type=text]").val();
               if (noneCheckbox || textBox !== '') {
                    localStorage.setItem('valueChanged', 'true');
                } else {
                    localStorage.setItem('valueChanged', 'false');
                
                }
            }


            function barrettEpitheliumValueChangeLocalStorage() {
                barrettEpitheliumValueChange = true;
                if (!noneChecked) {
                    if (!validatePage()) {
                        localStorage.setItem('validationRequired', 'true');
                        if (barretValidationMessage !== "") {
                            localStorage.setItem('validationRequiredMessage', barretValidationMessage);
                        }
                    } else {
                        localStorage.setItem('validationRequired', 'false');
                        if (barretValidationMessage !== "") {
                            barretValidationMessage = "";
                            localStorage.setItem('validationRequiredMessage', '');
                        } 
                    }
                }
                else {
                    localStorage.setItem('validationRequired', 'false');
                    if (barretValidationMessage !== "") {
                        barretValidationMessage = "";
                        localStorage.setItem('validationRequiredMessage', '');
                    }
                }
            } 
             
            
                      
            //changed by mostafiz issue 3647
            function focalChanged(sender, args) {
                ToggleTDs(sender, args);

                if ($(sender).is(':checked')) {
                    //set required fields
                    setRequiredField('<%=FocalQtyNumericTextBox.ClientID%>', 'focal quantity');
                    setRequiredField('<%=FocalLargestNumericTextBox.ClientID%>', 'focal largest size');
                }
                else {
                    //remove required fields
                    removeRequiredField('<%=FocalQtyNumericTextBox.ClientID%>', 'focal quantity');
                    removeRequiredField('<%=FocalLargestNumericTextBox.ClientID%>', 'focal largest size');
                }

            }

            function CloseWindow() {
                window.parent.CloseWindow();
            }
            //changed by mostafiz issue 3647
            function ToggleTDs(sender, args) {
                
                var chkBoxId = (args == undefined) ? sender : sender.get_element().id;
                var ticked = (args == undefined) ? $find(sender).get_checked() : args.get_checked();
                
                if (chkBoxId != "NoneCheckBox") {
                   
                    if (ticked == undefined) {
                        ticked = $find(chkBoxId).get_checked();
                    }

                    if (ticked) {
                        $("#" + chkBoxId).closest('td').next().show();
                        $find("NoneCheckBox").set_checked(false); 
                      
                    }
                    else {   
                        if ($("#" + chkBoxId).attr("id") == "BarrettIslands_CheckBox") {
                            $find("ProximalNumericTextBox").set_value('');
                            $find("DistalNumericTextBox").set_value('');
                        }
                        $("#" + chkBoxId).closest('td').next().hide();
                       
                    }
                } 
            } function valueChange(sender, args) {
                $find("NoneCheckBox").set_checked(false); barrettEpitheliumValueChangeLocalStorage();
            }

            function UnCheckNoneCheckBox(sender, args) {  
                var contrlID = sender.get_id();    
                if ($("#NoneCheckBox").is(':checked')) { $("#NoneCheckBox").prop('checked', false); }
                if (contrlID == "ProximalNumericTextBox" || contrlID == 'DistalNumericTextBox') {
                    $("#BarrettIslands_CheckBox").prop('checked', true);
                    var contrlVal = sender.get_value();
                    //if (contrlVal == '') { //commented by mostafiz
                    //    sender.set_value('34');
                    //}
                    if (contrlVal == '0') {
                        sender.set_value('');
                    }
                } barrettEpitheliumValueChange = true;  
            }
            //changed by mostafiz issue 3647
            function ToggleNoneCheckBox() {
                var ticked = $find("NoneCheckBox").get_checked();
                noneChecked = ticked;

                $find("Focal_CheckBox").set_checked(false); 
                $find("BarrettIslands_CheckBox").set_checked(false);
               
                if (ticked) {
                   $("#BarrettEpitheliumTable tr td:first-child").each(function () {
                        ClearControls($(this));                     
                   });                   
                    barrettEpitheliumValueChangeLocalStorage();
                   
                }
                if (!ticked) {
                    barrettEpitheliumValueChange = true;                    
                }
            }

            function ClearControls(tableCell) {
                tableCell.find("input:radio:checked").prop('checked', false);
                tableCell.find("input:checkbox:checked").prop('checked', false);
                tableCell.find("input:text").val('');
            }

            function RadNumericButtonClick(sender) {
                
                var contrlID = sender.get_id();
                var ctrRad = $find(contrlID);
                if ((contrlID == 'D3RadNumericTextBox') && (ctrRad.get_value() == '')) ctrRad.set_value(41);
                ctrRad.set_value(ctrRad.get_value() - 1);
                if ((contrlID == 'D2RadNumericTextBox') && (ctrRad.get_value() == '')) ctrRad.set_value($find('D3RadNumericTextBox').get_value());
                if ((contrlID == 'D1RadNumericTextBox') && (ctrRad.get_value() == '')) ctrRad.set_value($find('D3RadNumericTextBox').get_value());
                valueChanged(contrlID);               
            }

            function valueChanged(sender) {
                barrettEpitheliumValueChangeLocalStorage();
                $find("NoneCheckBox").set_checked(false);
                //$("#NoneCheckBox").prop('checked', false);
                
                //alert(sender);
                //var contrlID = sender;
                //alert(contrlID.value);
                //var contrlVal = sender;
                var ctrD1 = $find('D1RadNumericTextBox');
                var ctrD2 = $find('D2RadNumericTextBox');
                var ctrD3 = $find('D3RadNumericTextBox');
                var ctrC1 = $find('C1RadNumericTextBox');
                var ctrC2 = $find('C2RadNumericTextBox');
                //alert(ctrD1.get_value());
                //if (contrlID == 'D1RadNumericTextBox') {
                //    if (contrlVal == 0) {
                //        ctrD1.set_value(ctrD2.get_value());
                //    } else {
                //        if (contrlVal > 1) { ctrD1.set_value(contrlVal - 1); } else { ctrD1.set_value(''); }
                //    }
                //    ctrC1.set_value(ctrD3.get_value() - ctrD1.get_value());
                //} else if (contrlID == 'D2RadNumericTextBox') {
                //    if (contrlVal == 0) {
                //        ctrD2.set_value(ctrD3.get_value());
                //    } else {
                //        if (contrlVal > 1) { ctrD2.set_value(contrlVal - 1); } else { ctrD2.set_value(''); }
                //    }
                //    ctrC2.set_value(ctrD3.get_value() - ctrD2.get_value());
                //} else if (contrlID == 'D3RadNumericTextBox') {
                //    if (contrlVal > 1) {
                //        ctrD3.set_value(contrlVal - 1);
                //    } else {
                //        ctrD3.set_value('40');
                //    }

                //} 
                //else if (contrlID == 'C1RadNumericTextBox') {
                //    if (contrlVal > 1) {
                //        ctrC1.set_value(contrlVal - 1);
                //    } else {
                //        ctrC1.set_value("");
                //    }
                //} else if (contrlID == 'C2RadNumericTextBox') {
                //    if (contrlVal > 1) {
                //        ctrC2.set_value(contrlVal - 1);
                //    } else {
                //        ctrC2.set_value("");
                //    }
                //}
                //if (ctrD1.get_value() == '') { ctrC1.set_value(ctrD3.get_value()); }
                //if (ctrD2.get_value() == '') { ctrC2.set_value(ctrD3.get_value()); }
                ctrC1.set_value(ctrD3.get_value() - ctrD1.get_value());
                ctrC2.set_value(ctrD3.get_value() - ctrD2.get_value());

            }

            function CloseWindow() {
                var oManager = GetRadWindowManager();
                //Call GetActiveWindow to get the active window 
                var oActive = oManager.getActiveWindow();
                if (oActive == null) { window.parent.CloseWindow(); } else { oActive.close(null); return false; }
                // return false;
            }

            function showParisPopup() {
                var oWnd = $find("<%=ParisClassificationPopup.ClientID%>");
                oWnd.show();
            }

            function showPitPatternsPopup() {
                var oWnd = $find("<%=PitPatternsPopup.ClientID%>");
                oWnd.show();
            }

        </script>
    </telerik:RadScriptBlock>


    <style type="text/css">       
        .Upbutton {
            background: none !important;
        }

        .focal-lesions td {
            border: none;
            
        }
    </style>
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
        <telerik:RadScriptManager ID="OGDBarrettEpitheliumRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
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
        <div class="abnorHeader">Barrett's Epithelium - Prague Criteria</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Metro">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">


                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgBarrettEpithelium" runat="server">


                            <table id="BarrettEpitheliumTable" class="rgview" cellpadding="0" cellspacing="0" width="780px">
                                <colgroup>
                                    <col>
                                    <col>
                                    <col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th width="600px" class="rgHeader" style="text-align: left;">  <%-- changed by mostafiz issue 3647--%>
                                            <telerik:RadButton ID="NoneCheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Gray" Text="None" Skin="Metro" AutoPostBack="false"></telerik:RadButton>
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td class="">Inspection time:
                                            <telerik:RadNumericTextBox ID="InspectionTimeMinsRadNumericTextBox" runat="server" CssClass="extent-control"
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="1"
                                                Width="45px"
                                                MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="20px">
                                                <%----%>
                                                <NumberFormat DecimalDigits="0" />
                                                <ClientEvents OnValueChanged="valueChange" />
                                            </telerik:RadNumericTextBox> mins
                                        </td>
                                    </tr>
                            <%--  added by mostafiz 2360--%>
                                      <tr>
                                             <td>Smoker:
                                                 <asp:RadioButtonList ID="SmokerRadioButtonList" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow"
                                                      onclick="valueChange()" CssClass="rblType">
                                                      <asp:ListItem style="margin-right: 10px;" Value="1" Text="Yes"></asp:ListItem>
                                                      <asp:ListItem Value="2" Text="No"></asp:ListItem>

                                                 </asp:RadioButtonList>
                                             </td>                                                                                          
                                      </tr>
                            <%--  added by mostafiz --%>

                                    <tr>
                                        <td style="padding: 0px 0px 0px 6px; display:none;">
                                            <table style="width: 100%;" class="focal-lesions">
                                                <tr headrow="1">
                                                    <td style="border: none; width: 25%; vertical-align: top;">
                                                        <telerik:RadButton ID="Focal_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Focal lesions" Skin="Metro" OnClientCheckedChanged="focalChanged"></telerik:RadButton>
                                                    </td>
                                                    <td style="border: none;">
                                                        <table>
                                                            <tr>
                                                                <td class="rgCell"  style="border: none;">
                                                                   <%-- Quantity:&nbsp;--%>
                                                                    <telerik:RadNumericTextBox ID="FocalQtyNumericTextBox" runat="server" Visible="false"
                                                                        
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                </td>
                                                                <td class="rgCell" style="border: none;">
                                                                    <%--Size of largest:&nbsp;--%>
                                                                    <telerik:RadNumericTextBox ID="FocalLargestNumericTextBox" runat="server" Visible="false"
                                                                        
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="rgCell" style="border: none;">
                                                                    <asp:RadioButtonList ID="FocalTumourTypesRadioButtonList" runat="server" RepeatDirection="Horizontal" DataTextField="Description" Visible="false"  DataValueField="UniqueId" />
                                                                </td>
                                                                <td style="border: none; text-align: left;">
                                                                    <telerik:RadButton ID="FocalProbablyCheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" Visible="false" AutoPostBack="false" ForeColor="Gray" Text="Probably" Skin="Metro"></telerik:RadButton>
                                                                    &nbsp;
                                                                   <telerik:RadButton ID="ParisShowButton" runat="server" Text="Paris classification..." Skin="Metro" Visible="false" AutoPostBack="false"></telerik:RadButton>
                                                                    &nbsp;
                                                                    <telerik:RadButton ID="PitShowButton" runat="server" Text="Pit patterns..." Skin="Metro" AutoPostBack="false"  Visible="false"></telerik:RadButton>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>

                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr headrow="1">
                                                    <td class="rfdAspLabel" style="border: none; width: 220px;">
                                                        <telerik:RadButton ID="BarrettIslands_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Barrett's islands, distance (ab oral) cm  " Skin="Metro" OnClientCheckedChanged="ToggleTDs"></telerik:RadButton>
                                                    </td>
                                                    <td style="border: none; padding-top: 10px;">
                                                        <asp:Label ID="ProximalLabel" runat="server" Text="proximal" />
                                                        <telerik:RadNumericTextBox ID="ProximalNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0"> 
                                                            <NumberFormat DecimalDigits="0" />
                                                            <ClientEvents OnValueChanged="UnCheckNoneCheckBox" />
                                                        </telerik:RadNumericTextBox>
                                                        &nbsp;&nbsp;<asp:Label ID="DistalLabel" runat="server" Text="distal" />
                                                        <telerik:RadNumericTextBox ID="DistalNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                            <ClientEvents OnValueChanged="UnCheckNoneCheckBox" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>

                                    </tr>

                                    <tr>
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr headrow="1">
                                                    <td class="rfdAspLabel" style="border: none; width: 177px;">
                                                        <telerik:RadBinaryImage ID="RadBinaryImage1" ImageUrl="~/Images/Abnormalities/barrett_island.png" runat="server" />
                                                    </td>
                                                    <td style="padding: 0px 0px 0px 6px; vertical-align: top; width: 120px; color: black; font-weight: bold; border: none;">
                                                        <div style="padding-top: 90px;">
                                                            <asp:Label ID="MaximalExtentLabel" runat="server">Maximal extent <br/>of metaplasia</asp:Label>
                                                        </div>
                                                        <div style="padding-top: 60px;">
                                                            <asp:Label ID="ExtentLabel" runat="server" Text="Extent of circumferential metaplasia" />
                                                        </div>
                                                        <div style="padding-top: 20px;">
                                                            <asp:Label ID="GOJLabel" runat="server" Text="Gastro-oesophageal junction (GOJ)" />
                                                        </div>
                                                    </td>
                                                    <td style="padding: 0px 0px 0px 6px; vertical-align: top; width: 303px; border: none;">
                                                        <table style="width: 303px;">
                                                            <tr>
                                                                <td style="font-size: 12px; border: none; color: #4888a2;" colspan="3">
                                                                    <asp:Label ID="DistanceEntryNoteLabel" runat="server"><b>Note:</b> You can either enter all three valid Ab oral distances or alternatively record just M and C values.</asp:Label>
                                                                    <hr style="border-top: dashed 1px #c2d2e2;" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td style="text-align: center; vertical-align: top; border: none;">
                                                                    <asp:Label ID="DistanceAbOralLabel" runat="server"><b>Distance Ab oral (cm)</b></asp:Label>
                                                                    <fieldset id="DistanceAbFieldset" runat="server" class="otherDataFieldset" style="width: 70px; height: 210px; margin-left: 20px;">
                                                                        <div style="padding-top: 15px;">
                                                                            <telerik:RadNumericTextBox ID="D1RadNumericTextBox" runat="server"
                                                                                
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="35px"
                                                                                MinValue="0">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                                <ClientEvents OnButtonClick="RadNumericButtonClick" />
                                                                            </telerik:RadNumericTextBox>
                                                                        </div>
                                                                        <div style="padding-top: 80px;">
                                                                            <telerik:RadNumericTextBox ID="D2RadNumericTextBox" runat="server"
                                                                                
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="35px"
                                                                                MinValue="0">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                                <ClientEvents OnButtonClick="RadNumericButtonClick" />
                                                                            </telerik:RadNumericTextBox>
                                                                        </div>
                                                                        <div style="padding-top: 35px;">
                                                                            <telerik:RadNumericTextBox ID="D3RadNumericTextBox" runat="server"
                                                                                
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="35px"
                                                                                MinValue="1">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                                <ClientEvents OnButtonClick="RadNumericButtonClick" />
                                                                            </telerik:RadNumericTextBox>
                                                                        </div>
                                                                    </fieldset>
                                                                </td>
                                                                <td style="font-size: 16px; font-weight: bold; border: none;">OR
                                                                </td>
                                                                <td style="text-align: center; vertical-align: top; border: none;">
                                                                    <span><b>cm</b><span>
                                                                        <fieldset id="Fieldset2" runat="server" class="otherDataFieldset" style="width: 70px; height: 210px;">
                                                                            <div style="padding-top: 15px;">
                                                                                M:                                            
                                                                                <telerik:RadNumericTextBox ID="C1RadNumericTextBox" runat="server"
                                                                                    
                                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                                    IncrementSettings-Step="1"
                                                                                    Width="35px">
                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                     <ClientEvents OnValueChanged="valueChange" />
                                                                                </telerik:RadNumericTextBox>
                                                                            </div>
                                                                            <div style="padding-top: 80px;">
                                                                                C:
                                                                                <telerik:RadNumericTextBox ID="C2RadNumericTextBox" runat="server"
                                                                                    
                                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                                    IncrementSettings-Step="1"
                                                                                    Width="35px">
                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                     <ClientEvents OnValueChanged="valueChange" />
                                                                                </telerik:RadNumericTextBox>
                                                                            </div>

                                                                        </fieldset></td>

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
                <div id="cmdOtherData" style="height: 10px;display:none; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Metro" Icon-PrimaryIconCssClass="telerikSaveButton"  />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Metro" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        <telerik:RadWindowManager ID="RadMan" runat="server" Modal="true" Animation="Fade" KeepInScreenBounds="true" Behaviors="Close" Skin="Metro" VisibleStatusbar="false" VisibleOnPageLoad="false">
            <Windows>
       
                        <telerik:RadWindow ID="PitPatternsPopup" runat="server" Width="652" Height="510" ReloadOnShow="true" ShowContentDuringLoad="false" OnUnload="WinUnload">
                            <ContentTemplate>
                                <div class="labelHeaderPopup riLabel">
                                    Pit Patterns - The Surface Appearance of a Lesion
                                </div>
                                <table class="tablePopup rgview" id="SessilePitPatternsTable">
                                    <tbody>
                                        <tr style="font-weight: bold;">
                                            <td width="20px"></td>
                                            <td width="50px">Pit Type
                                            </td>
                                            <td width="150px">Characteristics
                                            </td>
                                            <td width="80px">Appearance
                            <br />
                                                using HMCC
                                            </td>
                                            <td width="80px">Pit Size</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <telerik:RadButton ID="SessileNormalRoundPitsRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                                </telerik:RadButton>
                                            </td>
                                            <td>I
                                            </td>
                                            <td>Normal round pits
                                            </td>
                                            <td>
                                                <telerik:RadBinaryImage ID="SessileRadBinaryImage5" ImageUrl="~/Images/PitPatterns/PitPattern1.png" runat="server" />
                                            </td>
                                            <td>0.07 +/- 0.02</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <telerik:RadButton ID="SessileStellarRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                                </telerik:RadButton>
                                            </td>
                                            <td>II
                                            </td>
                                            <td>Stellar or papillary typical of hyperplastic polyps
                                            </td>
                                            <td>
                                                <telerik:RadBinaryImage ID="RadBinaryImage6" ImageUrl="~/Images/PitPatterns/PitPattern2.png" runat="server" />
                                            </td>
                                            <td>0.03 +/- 0.01</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <telerik:RadButton ID="SessileTubularRoundPitsRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                                </telerik:RadButton>
                                            </td>
                                            <td>III s
                                            </td>
                                            <td>Tubular/round pits smaller than pit type I typical of adenomas
                                            </td>
                                            <td>
                                                <telerik:RadBinaryImage ID="RadBinaryImage7" ImageUrl="~/Images/PitPatterns/PitPattern3.png" runat="server" />
                                            </td>
                                            <td>0.07 +/- 0.02</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <telerik:RadButton ID="SessileTubularRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                                </telerik:RadButton>
                                            </td>
                                            <td>III L
                                            </td>
                                            <td>Tubular/large typical of adenomas
                                            </td>
                                            <td>
                                                <telerik:RadBinaryImage ID="RadBinaryImage8" ImageUrl="~/Images/PitPatterns/PitPattern4.png" runat="server" />
                                            </td>
                                            <td>0.22 +/- 0.09</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <telerik:RadButton ID="SessileSulcusRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                                </telerik:RadButton>
                                            </td>
                                            <td>IV
                                            </td>
                                            <td>Sulcus/gyrus brain like typical of tubulovillous adenomas
                                            </td>
                                            <td>
                                                <telerik:RadBinaryImage ID="RadBinaryImage9" ImageUrl="~/Images/PitPatterns/PitPattern5.png" runat="server" />
                                            </td>
                                            <td>0.93 +/- 0.32</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <telerik:RadButton ID="SessileLossRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                                </telerik:RadButton>
                                            </td>
                                            <td>V
                                            </td>
                                            <td>Loss of architecture typical of invasion or high grade dysplasia
                                            </td>
                                            <td>
                                                <telerik:RadBinaryImage ID="RadBinaryImage10" ImageUrl="~/Images/PitPatterns/PitPattern6.png" runat="server" />
                                            </td>
                                            <td>N/A</td>
                                        </tr>
                                    </tbody>
                                </table>
                                <div style="height: 10px; margin-left: 10px; padding-top: 6px;">
                                    <telerik:RadButton ID="PitPatternsRadButton" runat="server" Text="OK" Skin="Web20" OnClick="GetValues" />
                                    <telerik:RadButton ID="RadButton6" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="CloseWindow" />
                                </div>
                            </ContentTemplate>
                        </telerik:RadWindow>
                        <telerik:RadWindow ID="ParisClassificationPopup" runat="server" Width="652" Height="450" ReloadOnShow="true" ShowContentDuringLoad="false" OnUnload="WinUnload">
                            <ContentTemplate>
                                <div class="labelHeaderPopup riLabel">
                                    Paris Classification - The Morphological Appearance of a Lesion
                                </div>
                                <table id="SessileParisClassificationTable" class="tablePopup rgview">
                                    <tr>
                                        <td>Protruded type
                                        </td>
                                        <td>
                                            <telerik:RadButton ID="SessileLSRadioButton" CssClass="sessile-paris-btn" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20" />
                                        </td>
                                        <td>
                                            <telerik:RadBinaryImage ID="testImg" ImageUrl="~/Images/ParisClassification/ParisClassification_Sessile.png" runat="server" />
                                        </td>
                                        <td>Is - sessile</td>
                                    </tr>
                                    <tr>
                                        <td rowspan="2">Superficial
                                <br />
                                            elevated type
                                        </td>
                                        <td>
                                            <telerik:RadButton ID="SessileLLARadioButton" CssClass="sessile-paris-btn" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
                                            </telerik:RadButton>
                                        </td>
                                        <td>
                                            <telerik:RadBinaryImage ID="imgLogo" runat="server" ImageUrl="~/Images/ParisClassification/ParisClassification_FlatElevated.png" />
                                        </td>
                                        <td>IIa - flat elevated</td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <telerik:RadButton ID="SessileLLALLCRadioButton" CssClass="sessile-paris-btn" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
                                            </telerik:RadButton>
                                        </td>
                                        <td>
                                            <telerik:RadBinaryImage ID="RadBinaryImage2" ImageUrl="~/Images/ParisClassification/ParisClassification_FlatElevatedDep.png" runat="server" />
                                        </td>
                                        <td>IIa + IIc - flat elevated with depression</td>
                                    </tr>
                                    <tr>
                                        <td>Flat type
                                        </td>
                                        <td>
                                            <telerik:RadButton ID="SessileLLBRadioButton" CssClass="sessile-paris-btn" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
                                            </telerik:RadButton>
                                        </td>
                                        <td>
                                            <telerik:RadBinaryImage ID="RadBinaryImage3" ImageUrl="~/Images/ParisClassification/ParisClassification_Flat.png" runat="server" />
                                        </td>
                                        <td>IIb - flat</td>
                                    </tr>
                                    <tr>
                                        <td rowspan="2">Depressed type
                                        </td>
                                        <td>
                                            <telerik:RadButton ID="SessileLLCRadioButton" CssClass="sessile-paris-btn" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
                                            </telerik:RadButton>
                                        </td>
                                        <td>
                                            <telerik:RadBinaryImage ID="RadBinaryImage4" ImageUrl="~/Images/ParisClassification/ParisClassification_SlightlyDep.png" runat="server" />
                                        </td>
                                        <td>IIc - slightly depressed</td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <telerik:RadButton ID="SessileLLCLLARadioButton" CssClass="sessile-paris-btn" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
                                            </telerik:RadButton>
                                        </td>
                                        <td>
                                            <telerik:RadBinaryImage ID="RadBinaryImage5" ImageUrl="~/Images/ParisClassification/ParisClassification_SlightlyDep2.png" runat="server" />
                                        </td>
                                        <td>IIc + IIa slightly depressed</td>
                                    </tr>
                                </table>
                                <div style="height: 10px; margin-left: 10px; padding-top: 6px;">
                                    <telerik:RadButton ID="ParisClassificationRadButton" runat="server" Text="OK" Skin="Web20" OnClick="GetValues" />
                                    <telerik:RadButton ID="RadButton2" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="CloseWindow" />
                                </div>
                            </ContentTemplate>
                        </telerik:RadWindow>
               
            </Windows>
        </telerik:RadWindowManager>

           </ContentTemplate>
         </asp:UpdatePanel>
    </form>
</body>
</html>
