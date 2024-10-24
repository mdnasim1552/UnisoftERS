<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Common_Duodenitis" Codebehind="Duodenitis.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />


    <script type="text/javascript">
        var duodenitisValueChanged = false;
        $(window).on('load', function () {
            //checkAllRadControls($find("NoneCheckBox").get_checked());

            if ($find("Duodenitis_CheckBox").get_checked()) {
                
                $('#trAssociatedWith').show();
            } else {
                $('#trAssociatedWith').hide();
            }
        });

        $(document).ready(function () {

            $("#Duodenitis_Severity_ComboBox, #Duodenitis_Bleeding_ComboBox").change(function () {
                duodenitisValueChanged = true;
            })

            //for this page issue 4166  by Mostafiz
            $(window).on('beforeunload', function () {         
                if (duodenitisValueChanged) {   
                    valueChange();
                    $("#SaveButton").click();
                } 
            });
            $(window).on('unload', function () {
                localStorage.clear();
            });
        });
        function valueChange() {
            var duodenitisChecked = $find("Duodenitis_CheckBox").get_checked();
            var noneChecked = $find("NoneCheckBox").get_checked();

            if (duodenitisChecked || noneChecked) {
                localStorage.setItem('valueChanged', 'true');
            } else {
                localStorage.setItem('valueChanged', 'false');
            }
        }

        function saveOnClick() {
            duodenitisValueChanged = true;
            
        }

        function CloseWindow() {
            window.parent.CloseWindow();
        }

       
        function ToggleTRs(sender, args) {
            duodenitisValueChanged = true;
            var enableCombo = args.get_checked();
            var elemId = sender.get_element().id;
            var newElemId = elemId.replace("_CheckBox", "_Severity_ComboBox");
            clearCombo(newElemId, enableCombo);
            newElemId = elemId.replace("_CheckBox", "_Bleeding_ComboBox");
            clearCombo(newElemId, enableCombo);
        }

        function clearCheckBoxes() {
            var allRadControls = $telerik.radControls;
            for (var i = 0; i < allRadControls.length; i++) {
                var element = allRadControls[i];
                //if (RadButton && RadButton.isInstanceOfType(element)) {
                    var elemId = element.get_element().id;
                    if (elemId.indexOf("_ChkBox") > 0) {
                        element.set_checked(false);
                    }
                //}
            }

        }

        function clearCombo(elemId, enableCombo) {
            var dropdownlist = $find(elemId);
            if (dropdownlist != null) {
                var item = dropdownlist.findItemByValue("0");
                item.select();
                if (enableCombo) {
                    dropdownlist.enable();
                    $find("NoneCheckBox").set_checked(false);
                    $('#trAssociatedWith').show();
                    //$find("trAssociatedWith").
                    //$find("trAssociatedWith").toggle('show');
                } else {
                    dropdownlist.disable();
                    clearCheckBoxes();
                    $('#trAssociatedWith').hide();
                    //$find("trAssociatedWith").toggle('hide');
                    //$find("trAssociatedWith").hide();
                }
            }
        }

        function ToggleNoneCheckBox(sender, args) {
            duodenitisValueChanged = true;
            checkAllRadControls(args.get_checked());
        }

        function checkAllRadControls(noneChecked) {
            if (!noneChecked) { return; }
            var allRadTreeViews = [];
            var allRadControls = $telerik.radControls;
            for (var i = 0; i < allRadControls.length; i++) {
                var element = allRadControls[i];
               // if (RadButton && RadButton.isInstanceOfType(element)) {
                    var elemId = element.get_element().id;
                    if ((elemId != "NoneCheckBox") && elemId.indexOf("_CheckBox") > 0) {
                        element.set_checked(false);
                    }
              //  }
                //if (RadComboBox && RadComboBox.isInstanceOfType(element)) {
                    var elemId = element.get_element().id;
                    if ((elemId.indexOf("_Severity_ComboBox") > 0) || (elemId.indexOf("_Bleeding_ComboBox") > 0)) {
                        clearCombo(elemId, false);
                    }
              //  }
            }
        }


        function toggleClass(sender, args) {
            var elemId = sender.get_element();
            var dropdownlist = $find(sender.get_element().id);
            var val = dropdownlist.get_selectedItem().get_value();
            if (elemId.id.indexOf("_Bleeding_") > 0) { val++; }
            var elemId = sender.get_element();
            var className = elemId.className;
            var pos = className.indexOf(" abnor_cb");
            var newClassName;
            if (pos > 0) {
                newClassName = className.substring(0, pos) + " abnor_cb" + val;
            }
            else {
                newClassName = className + " abnor_cb" + val;
            }
            elemId.className = newClassName;
        }

    </script>
    <style type="text/css">


        .abnor_cb1.RadComboBox .rcbInputCell .rcbArrowCell .rcbFocused .rcbScroll .rcbList .rcbItem .rcbHovered .rcbDisabled .rcbNoWrap .rcbLoading .rcbMoreResults .rcbImage .rcbEmptyMessage .rcbSeparator .rcbLabel,
        .abnor_cb1 .rcbInputCell INPUT.rcbInput,
        .abnor_cb1{color: black !important;}  /*green to black*/

        .abnor_cb2.RadComboBox .rcbInputCell .rcbArrowCell .rcbFocused .rcbScroll .rcbList .rcbItem .rcbHovered .rcbDisabled .rcbNoWrap .rcbLoading .rcbMoreResults .rcbImage .rcbEmptyMessage .rcbSeparator .rcbLabel,
        .abnor_cb2 .rcbInputCell INPUT.rcbInput,
        .abnor_cb2{color: black !important;}  /*orange to black*/

        /*cb3.RadComboBox .rcbDisabled,
        cb3.RadComboBox .rcbInputCell .rcbArrowCell .rcbFocused .rcbScroll .rcbList .rcbItem .rcbHovered .rcbDisabled .rcbNoWrap .rcbLoading .rcbMoreResults .rcbImage .rcbEmptyMessage .rcbSeparator .rcbLabel,*/
        /*.cb3 .rcbInputCell .rcbArrowCell .rcbFocused .rcbScroll .rcbList .rcbItem .rcbHovered .rcbDisabled .rcbNoWrap .rcbLoading .rcbMoreResults .rcbImage .rcbEmptyMessage .rcbSeparator .rcbLabel*/

        .abnor_cb3.RadComboBox .rcbInputCell .rcbArrowCell .rcbFocused .rcbScroll .rcbList .rcbItem .rcbHovered .rcbDisabled .rcbNoWrap .rcbLoading .rcbMoreResults .rcbImage .rcbEmptyMessage .rcbSeparator .rcbLabel,
        .abnor_cb3 .rcbInputCell INPUT.rcbInput,
        .abnor_cb3{color: black !important; }  /*red to black*/
         

        .ContentTable {
            /*width: 100%;*/
            /*border-collapse: collapse;*/
        }

            .ContentTable th {
                /*border: #4e95f4 1px solid;*/
                /*padding-top: 5px;
                padding-bottom: 4px;
                background-color: #A7C942;
                color: #fff;*/
                height: 25px;
                width: 200px;
            }

            .ContentTable td {
                /*border: #4e95f4 1px solid;*/
                height: 28px;
            }

            .ContentTable tr {
                /*background: #b8d1f3;*/
            }

                .ContentTable tr:nth-child(odd) {
                    /*background: #b8d1f3;*/
                }

                .ContentTable tr:nth-child(even) {
                    background: #dae5f4;
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
        <telerik:RadScriptManager ID="DuodenitisRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="DuodenitisRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div id="HeaderDiv" runat="server" class="abnorHeader">Duodenitis</div>

        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">
                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">
                            <table id="DuodenitisTable" class="rgview" cellpadding="0" cellspacing="0" width="780px">
                                <colgroup>
                                    <col>
                                    <col>
                                    <col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th width="260px" class="rgHeader" style="text-align: left;">
                                            <telerik:RadButton ID="NoneCheckBox" runat="server" Text="None" Skin="Web20" OnClientCheckedChanged="ToggleNoneCheckBox"></telerik:RadButton>
                                        </th>
                                        <th width="140px" class="rgHeader">Severity</th>
                                        <th width="140px" class="rgHeader">Bleeding</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr class="rgRow">
                                        <td>
                                            <telerik:RadButton ID="Duodenitis_CheckBox" runat="server" Text="Duodenitis" Skin="Metro" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Duodenitis_Severity_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Duodenitis_Bleeding_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow" id="trAssociatedWith">
                                        <td colspan="3">
                                            <fieldset id="AssociatedWithFieldset" runat="server" style="margin-left: 0px;border:#83AABA solid 1px;">
                                                <legend>Associated with</legend>
                                                <table>
                                                    <tr>
                                                        <td style="border:none;">
                                                            <telerik:RadButton ID="Patchy_Erythema_ChkBox" runat="server" Text="patchy erythema" Skin="Web20" OnClientClicked="saveOnClick"></telerik:RadButton>
                                                        </td>
                                                        <td style="border:none;">
                                                            <telerik:RadButton ID="Diffuse_Erythema_ChkBox" runat="server" Text="diffuse erythema" Skin="Web20" OnClientClicked="saveOnClick"></telerik:RadButton>
                                                        </td>
                                                        <td style="border:none;">
                                                            <telerik:RadButton ID="Erosions_ChkBox" runat="server" Text="erosions" Skin="Web20" OnClientClicked="saveOnClick"></telerik:RadButton>
                                                        </td>
                                                        <td style="border:none;">
                                                            <telerik:RadButton ID="Nodularity_ChkBox" runat="server" Text="nodularity" Skin="Web20" OnClientClicked="saveOnClick"></telerik:RadButton>
                                                        </td>
                                                        <td style="border:none;">
                                                            <telerik:RadButton ID="Oedematous_ChkBox" runat="server" Text="oedematous" Skin="Web20" OnClientClicked="saveOnClick"></telerik:RadButton>
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
                <div id="cmdOtherData" style="height: 10px; display:none; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
    </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>
