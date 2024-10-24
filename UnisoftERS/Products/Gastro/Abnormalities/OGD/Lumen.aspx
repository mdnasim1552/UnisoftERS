<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Lumen" Codebehind="Lumen.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <script type="text/javascript">


        //$(window).on('load', function () {
        //    $('input[type="checkbox"]').each(function () {
        //        ToggleTRs($(this));
        //    });
        //});
        var lumenValueChanged = false;
        $(document).ready(function () {
        //    $("#LumenTable tr td:first-child input:checkbox").change(function () {
        //        ToggleTRs($(this));
        //    });
        //    $("#NoBloodCheckBox").change(function () {
        //        ToggleNoneCheckBox($(this).is(':checked'));
        //    });
          $('#FreshBlood_Amount_ComboBox, #FreshBlood_Origin_ComboBox, #AlteredBlood_Amount_ComboBox, #AlteredBlood_Origin_ComboBox,#Food_Amount_ComboBox,#Bile_Amount_ComboBox').change(function () {
           lumenValueChanged = true;
        });

        //for this page issue 4166  by Mostafiz
            $(window).on('beforeunload', function () {    
                if (lumenValueChanged) {   
                    CheckValuedChanged();
                    $("#SaveButton").click();
                } 
            });
            $(window).on('unload', function () {
                localStorage.clear();
            });

        });

        function CheckValuedChanged() {

            var noneCheckbox = $find("NoneCheckBox").get_checked();
            var FreshBlood_CheckBox =$find("FreshBlood_CheckBox").get_checked();
            var Food_CheckBox =$find("Food_CheckBox").get_checked();
            var Bile_CheckBox =$find("Bile_CheckBox").get_checked();
            var AlteredBlood_CheckBox = $find("AlteredBlood_CheckBox").get_checked();

            if (noneCheckbox || FreshBlood_CheckBox || Food_CheckBox || Bile_CheckBox || AlteredBlood_CheckBox) {
                localStorage.setItem('valueChanged', 'true');
            } else {
                localStorage.setItem('valueChanged', 'false');
            }
            
            
        }

        //function ToggleTRs(chkbox) {
        //    if (chkbox[0].id != "NoBloodCheckBox") {
        //        var checked = chkbox.is(':checked');
        //        if (checked) {
        //            $("#NoBloodCheckBox").attr('checked', false);
        //        }
        //        chkbox.parent('td')
        //            .nextUntil('tr').each(function () {
        //                if (checked) {
        //                    $(this).show();
        //                }
        //                else {
        //                    //$(this).hide();
        //                    ClearControls($(this));
        //                }
        //            });
        //    }
        //}

        //function ToggleNoneCheckBox(checked) {
        //    if (checked) {
        //        $("#FreshBloodCheckBox").removeAttr("checked");
        //        $("#FreshBloodCheckBox").trigger("change");
        //        $("#AlteredBloodCheckBox").removeAttr("checked");
        //        $("#AlteredBloodCheckBox").trigger("change");
        //    }
        //}

        //function ClearControls(tableCell) {
        //    tableCell.find("input:radio:checked").removeAttr("checked");
        //    tableCell.find("input:checkbox:checked").removeAttr("checked");
        //    tableCell.find("input:text").val("");
        //}

        $(window).on('load', function () {
            checkAllRadControls($find("NoneCheckBox").get_checked());
        });

        function CloseWindow() {
            window.parent.CloseWindow();
        }

        function ToggleTRs(sender, args) {
            lumenValueChanged = true;
            var enableCombo = args.get_checked();
            var elemId = sender.get_element().id;
            var newElemId = elemId.replace("_CheckBox", "_Amount_ComboBox");
            clearCombo(newElemId, enableCombo);
            newElemId = elemId.replace("_CheckBox", "_Origin_ComboBox");
            clearCombo(newElemId, enableCombo);
        }

        function clearCombo(elemId, enableCombo) {
            var dropdownlist = $find(elemId);
            if (dropdownlist != null) {
                var item = dropdownlist.findItemByValue("0");
                item.select();
                if (enableCombo) {
                    dropdownlist.enable();
                    $find("NoneCheckBox").set_checked(false);
                } else {
                    dropdownlist.disable();
                }
            }
        }

        function ToggleNoneCheckBox(sender, args) {
            checkAllRadControls(args.get_checked());
            lumenValueChanged = true;
        }

        function checkAllRadControls(noneChecked) {
            if (!noneChecked) { return; }
            var allRadTreeViews = [];
            var allRadControls = $telerik.radControls;
            for (var i = 0; i < allRadControls.length; i++) {
                var element = allRadControls[i];
                //if (RadButton && RadButton.isInstanceOfType(element)) {
                    var elemId = element.get_element().id;
                    if ((elemId != "NoneCheckBox") && elemId.indexOf("_CheckBox") > 0) {
                        element.set_checked(false);
                    }
                //}
                //if (RadComboBox && RadComboBox.isInstanceOfType(element)) {
                //    var elemId = element.get_element().id;
                //    if ((elemId.indexOf("_Amount_ComboBox") > 0) || (elemId.indexOf("_Origin_ComboBox") > 0)) {
                //        clearCombo(elemId, false);
                //    }
                //}
            }
        }


        function toggleClass(sender, args) {
            var elemId = sender.get_element();
            var dropdownlist = $find(sender.get_element().id);
            var val = dropdownlist.get_selectedItem().get_value();
            //if (elemId.id.indexOf("_Bleeding_") > 0) { val++; }
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
                height: 30px;
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
        .abnor_cb1.RadComboBox .rcbInputCell .rcbArrowCell .rcbFocused .rcbScroll .rcbList .rcbItem .rcbHovered .rcbDisabled .rcbNoWrap .rcbLoading .rcbMoreResults .rcbImage .rcbEmptyMessage .rcbSeparator .rcbLabel,
        .abnor_cb1 .rcbInputCell INPUT.rcbInput,
        .abnor_cb1{color: black !important;}  /*green to black*/

        .abnor_cb2.RadComboBox .rcbInputCell .rcbArrowCell .rcbFocused .rcbScroll .rcbList .rcbItem .rcbHovered .rcbDisabled .rcbNoWrap .rcbLoading .rcbMoreResults .rcbImage .rcbEmptyMessage .rcbSeparator .rcbLabel,
        .abnor_cb2 .rcbInputCell INPUT.rcbInput,
        .abnor_cb2{color: black !important;}  /*orange to black*/

        .abnor_cb3.RadComboBox .rcbInputCell .rcbArrowCell .rcbFocused .rcbScroll .rcbList .rcbItem .rcbHovered .rcbDisabled .rcbNoWrap .rcbLoading .rcbMoreResults .rcbImage .rcbEmptyMessage .rcbSeparator .rcbLabel,
        .abnor_cb3 .rcbInputCell INPUT.rcbInput,
        .abnor_cb3{color: black !important; }  /*red to black*/

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
        <telerik:RadScriptManager ID="LumenRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="LumenRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Lumen</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">
                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
<%--                        <asp:CheckBox ID="NoBloodCheckBox" runat="server" Text="<span class='siteDetailsHeadCheckBoxText'>Blood Free</span>" />
                    </div>--%>
                        <div class="rgview" id="rgAbnormalities" runat="server">


                            <table id="GastritisTable" class="rgview" cellpadding="0" cellspacing="0" width="780px">
                                <colgroup>
                                    <col><col><col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th width="260px" class="rgHeader" style="text-align: left;">
                                            <telerik:RadButton ID="NoneCheckBox" runat="server" Text="Blood Free" Skin="Web20" OnClientCheckedChanged="ToggleNoneCheckBox"></telerik:RadButton>
                                        </th>
                                        <th width="140px" class="rgHeader">Amount</th>
                                        <th width="140px" class="rgHeader">Origin</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr class="rgRow">
                                        <td><telerik:RadButton ID="FreshBlood_CheckBox" runat="server" Text="Fresh blood" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton></td>
                                        <td class="rgCell"><telerik:RadComboBox ID="FreshBlood_Amount_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox></td>
                                        <td class="rgCell"><telerik:RadComboBox ID="FreshBlood_Origin_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox></td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td><telerik:RadButton ID="AlteredBlood_CheckBox" runat="server" Text="Altered blood" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton></td>
                                        <td class="rgCell"><telerik:RadComboBox ID="AlteredBlood_Amount_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox></td>
                                        <td class="rgCell"><telerik:RadComboBox ID="AlteredBlood_Origin_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox></td>
                                    </tr>
                                    <tr class="rgRow">
                                        <td><telerik:RadButton ID="Food_CheckBox" runat="server" Text="Food residue" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton></td>
                                        <td class="rgCell"><telerik:RadComboBox ID="Food_Amount_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox></td>
                                        <td class="rgCell"></td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td><telerik:RadButton ID="Bile_CheckBox" runat="server" Text="Bile" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton></td>
                                        <td class="rgCell"><telerik:RadComboBox ID="Bile_Amount_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox></td>
                                        <td class="rgCell"></td>
                                    </tr>
                                </tbody>
                            </table>








                          <%--  <table class="ContentTable" id="LumenTable" runat="server">
                                <tr>
                                    <th></th>
                                    <th align="center"><b>Amount</b>
                                    </th>
                                    <th align="center"><b>Origin</b></th>
                                </tr>
                                <tr>
                                    <td width="200px">
                                        <asp:CheckBox ID="FreshBloodCheckBox1" runat="server" Text="Fresh Blood" />
                                    </td>
                                    <td class="abnor_lumen_td">
                                        <asp:RadioButtonList ID="FreshBloodAmountRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal">
                                            <asp:ListItem Value="1" Text="Small"></asp:ListItem>
                                            <asp:ListItem Value="2" Text="Moderate"></asp:ListItem>
                                            <asp:ListItem Value="3" Text="Large"></asp:ListItem>
                                        </asp:RadioButtonList>
                                    </td>
                                    <td style="display: none;">
                                        <asp:RadioButtonList ID="FreshBloodOriginRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal">
                                            <asp:ListItem Value="1" Text="Not Identified"></asp:ListItem>
                                            <asp:ListItem Value="2" Text="Transported"></asp:ListItem>
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:CheckBox ID="AlteredBloodCheckBox1" runat="server" Text="Altered Blood" />
                                    </td>
                                    <td>
                                        <asp:RadioButtonList ID="AlteredBloodAmountRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal">
                                            <asp:ListItem Value="1" Text="Small" class="abnor_rb1"></asp:ListItem>
                                            <asp:ListItem Value="2" Text="Moderate" class="abnor_rb2"></asp:ListItem>
                                            <asp:ListItem Value="3" Text="Large" class="abnor_rb3"></asp:ListItem>
                                        </asp:RadioButtonList>
                                    </td>
                                    <td style="display: none;">
                                        <asp:RadioButtonList ID="AlteredBloodOriginRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal">
                                            <asp:ListItem Value="1" Text="Not Identified"></asp:ListItem>
                                            <asp:ListItem Value="2" Text="Transported"></asp:ListItem>
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:CheckBox ID="FoodCheckBox1" runat="server" Text="Food" />
                                    </td>
                                    <td style="display: none;">
                                        <asp:RadioButtonList ID="FoodAmountRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal">
                                            <asp:ListItem Value="1" Text="Small"></asp:ListItem>
                                            <asp:ListItem Value="2" Text="Moderate"></asp:ListItem>
                                            <asp:ListItem Value="3" Text="Large"></asp:ListItem>
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:CheckBox ID="BileCheckBox1" runat="server" Text="Bile" />
                                    </td>
                                    <td style="display: none;">
                                        <asp:RadioButtonList ID="BileRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal">
                                            <asp:ListItem Value="1" Text="Small"></asp:ListItem>
                                            <asp:ListItem Value="2" Text="Moderate"></asp:ListItem>
                                            <asp:ListItem Value="3" Text="Large"></asp:ListItem>
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                            </table>--%>


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
