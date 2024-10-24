<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_PostSurgery" Codebehind="PostSurgery.aspx.vb" %>

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
        .rbl label
        {
            margin-right: 15px;
        }
    </style>
    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
    <script type="text/javascript">

        var AddNewItemRadTextBoxClientId = "<%= AddNewItemRadTextBox.ClientID %>";
        var AddNewItemRadWindowClientId = "<%= AddNewItemRadWindow.ClientID %>";
        var postSurgeryValueChanged = false;
        var noneChecked = false;
        $(window).on('load', function () {
            $('input[type="checkbox"]').each(function () {
                ToggleTRs($(this));
            });
            ToggleJejunum();
        });

        $(document).ready(function () {
            $("#PostSurgeryTable tr td:first-child input:checkbox, input:radio").change(function () {
                ToggleTRs($(this));
                postSurgeryValueChanged = true;
            });

            $("#NoneCheckBox").change(function () {
                ToggleNoneCheckBox($(this).is(':checked'));
                postSurgeryValueChanged = true;
            });
            //for this page issue 4166  by Mostafiz
            $(window).on('beforeunload', function () {
                if (postSurgeryValueChanged) {
                    valueChange();
                    $("#SaveButton").click();
                }
            });
            $(window).on('unload', function () {
                localStorage.clear();
            });
        });

        function valueChange() {
            
            var noneChecked = $("#FormDiv input:checkbox:checked").length;
            if (noneChecked) {
                localStorage.setItem('valueChanged', 'true');
            } else {
                localStorage.setItem('valueChanged', 'false');
            }
        }

        function CloseWindow() {
            window.parent.CloseWindow();
        }

        function SaveOnChange() {
            postSurgeryValueChanged = true;
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
                if (chkbox[0].id == "JejunumCheckBox") {
                    ToggleJejunum();
                }
            }
        }
        //changed by mostafiz issue 3647 
        function ToggleNoneCheckBox(checked) {
            if (checked) {
                noneCheck = checked;
                $("#PostSurgeryTable tr td:first-child").each(function () {
                    $(this).find("input:checkbox:checked").prop('checked',false);
                    $(this).find("input:checkbox").trigger("change");
                });
            }
        }

        function ToggleJejunum() {
            var selectedVal = $('#JejunumStateRadioButtonList input:checked').val();
            if (selectedVal == 2) {
                $("#AbnormalTextBox").show();
            }
            else {
                $("#AbnormalTextBox").hide();
                $("#AbnormalTextBox").val("");
            }
        }
        //changed by mostafiz issue 3647 
        function ClearControls(tableCell) {
            tableCell.find("input:radio:checked").prop('checked',false);
            tableCell.find("input:checkbox:checked").prop('checked', false);
            tableCell.find("input:text").val("");
            $(tableCell).find('textarea').val("");
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
        <telerik:RadScriptManager ID="PostSurgeryRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="PostSurgeryRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Post Surgery</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">



                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">


                            <table id="PostSurgeryTable" class="rgview" cellpadding="0" cellspacing="0" width="780px">
                                <colgroup>
                                    <col><col><col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th width="260px" class="rgHeader" style="text-align: left;">
                                            <asp:CheckBox ID="NoneCheckBox" runat="server" Text="No evidence of previous surgery" />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%; ">
                                                <tr headRow="1" hasChildRows="1">
                                                    <td colspan="2" style="border:none;" >
                                                        <asp:CheckBox ID="SurgicalProcedureCheckBox" runat="server" Text="Previous surgery" />
                                                    </td>
                                                </tr>
                                                <tr childRow="1">
                                                    <td style="border:none;text-align:right;">
                                                        <asp:label ID="SurgicalProcedureLabel" runat="server" style="margin-left: 30px;">Surgical procedure: </asp:label>
                                                    </td>
                                                    <td style="border:none;">
                                                        <span>
                                                            <telerik:RadComboBox ID="SurgicalProcedureComboBox" runat="server" Skin="Windows7" Width="350" onclientselectedindexchanged="SaveOnChange"/>
                                                        </span>
                                                    </td>
                                                </tr>
                                                <tr childRow="1" >
                                                    <td style="border:none;text-align:right;">
                                                        <asp:label ID="FindingsLabel" runat="server" style="margin-left: 30px;">Findings:</asp:label>
                                                    </td>
                                                    <td style="border:none;">
                                                        <span>
                                                            <telerik:RadTextBox ID="FindingsTextBox" runat="server" Width="350px"
                                                                TextMode="MultiLine" Resize="Both">
                                                                 <ClientEvents OnValueChanged="SaveOnChange" />
                                                            </telerik:RadTextBox>
                                                        </span>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <tr runat="server" id="trDuodenum">
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%;">
                                                <tr headRow="1">
                                                    <td style="border:none;" >
                                                        <asp:CheckBox ID="DuodenumCheckBox" runat="server" Text="Duodenum not present" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <tr runat="server" id="trJejunum">
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%; ">
                                                <tr headRow="1" hasChildRows="1">
                                                    <td style="border:none;width:120px;" >
                                                        <asp:CheckBox ID="JejunumCheckBox" runat="server" Text="Jejunum" />
                                                    </td>
                                                    <td style="border:none; text-align:left; ">
                                                        <asp:RadioButtonList ID="JejunumStateRadioButtonList" runat="server" CssClass="rbl"
                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow"
                                                            onchange="ToggleJejunum();">
                                                          
                                                            <asp:ListItem Value="1" Text="Normal"></asp:ListItem>
                                                            <asp:ListItem Value="2" Text="Abnormal"></asp:ListItem>
                                                        </asp:RadioButtonList>
                                                    </td>
                                                </tr>
                                                <tr childRow="1">
                                                    <td style="border:none;"></td>
                                                    <td style="border:none;">
                                                        <telerik:RadTextBox ID="AbnormalTextBox" runat="server" Width="350px"
                                                            TextMode="MultiLine" Resize="Both">
                                                            <ClientEvents OnValueChanged="SaveOnChange" />
                                                        </telerik:RadTextBox>
                                                    </td>
                                                </tr>
                               <%--                 <tr childRow="1" style="height:23px;">

                                                </tr>--%>
                                            </table>
                                        </td>
                                    </tr>

                                </tbody>
                            </table>

                        </div>
                    </div>
                </div>








<%--
                <div id="FormDiv">
                    <div class="siteDetailsHeadCheckBoxDiv">
                        <asp:CheckBox ID="NoneCheckBox" runat="server" Text="<span class='siteDetailsHeadCheckBoxText'>No evidence of previous surgery</span>" />
                    </div>

                    <div class="siteDetailsContentDiv">
                        <table id="PostSurgeryTable" runat="server" cellpadding="3" cellspacing="3" class="SiteDetailsForm" style="table-layout: fixed;">
                            <tr headrow="1" haschildrows="1">
                                <td colspan="2">
                                    <asp:CheckBox ID="SurgicalProcedureCheckBox" runat="server" Text="Previous Surgery" />
                                </td>
                            </tr>
                            <tr childrow="1">
                                <td>
                                    <span style="margin-left: 30px;">Surgical Procedure: </span>
                                </td>
                                <td>
                                    <span style="margin-left: 30px;">
                                        <telerik:RadComboBox ID="SurgicalProcedureComboBox" runat="server" Skin="Windows7" Width="200" />
                                    </span>
                                </td>
                            </tr>
                            <tr childrow="1">
                                <td>
                                    <span style="margin-left: 30px;">Findings:</span>
                                </td>
                                <td>
                                    <span style="margin-left: 30px;">
                                        <telerik:RadTextBox ID="FindingsTextBox" runat="server" Width="350px"
                                            TextMode="MultiLine" Resize="Both">
                                        </telerik:RadTextBox>
                                    </span>
                                </td>
                            </tr>
                            <tr headrow="1">
                                <td colspan="2">
                                    <asp:CheckBox ID="DuodenumCheckBox" runat="server" Text="Duodenum not present" />
                                </td>
                            </tr>
                            <tr headrow="1" haschildrows="1">
                                <td colspan="2">
                                    <asp:CheckBox ID="JejunumCheckBox" runat="server" Text="Jejunum" />
                                </td>
                            </tr>
                            <tr childrow="1">
                                <td colspan="2">
                                    <span style="margin-left: 30px;">
                                        <asp:RadioButtonList ID="JejunumStateRadioButtonList" runat="server"
                                            CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow"
                                            onchange="ToggleJejunum();">
                                            <asp:ListItem Value="1" Text="Normal"></asp:ListItem>
                                            <asp:ListItem Value="2" Text="Abnormal"></asp:ListItem>
                                        </asp:RadioButtonList>
                                    </span>
                                </td>
                            </tr>
                            <tr childrow="1">
                                <td colspan="2">
                                    <span style="margin-left: 50px;">
                                        <telerik:RadTextBox ID="AbnormalTextBox" runat="server" Width="350px"
                                            TextMode="MultiLine" Resize="Both">
                                        </telerik:RadTextBox>
                                    </span>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>--%>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; display:none; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>

        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move, Resize"
            Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="AddNewItemRadWindow" runat="server" ReloadOnShow="true" VisibleStatusbar="false" Title="Add new Item"
                    KeepInScreenBounds="true" Width="400px" Height="150px" OnClientClose="AddNewItemWindowClientClose">
                    <ContentTemplate>
                        <table cellspacing="3" cellpadding="3" style="width: 100%">
                            <tr>
                                <td>
                                    <br />
                                    <div class="left">
                                        <telerik:RadTextBox ID="AddNewItemRadTextBox" runat="Server" Width="250px" />
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div id="buttonsdiv" style="height: 10px; padding-top: 16px;">
                                        <telerik:RadButton ID="AddNewItemSaveRadButton" runat="server" Text="Add" Skin="WebBlue"  AutoPostBack="false" OnClientClicked="AddNewItem" ButtonType="SkinnedButton" />
                                        &nbsp;&nbsp;
                                        <telerik:RadButton ID="AddNewItemCancelRadButton" runat="server" Text="Cancel" Skin="WebBlue" AutoPostBack="false" OnClientClicked="CancelAddNewItem" ButtonType="SkinnedButton" />
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
    
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
