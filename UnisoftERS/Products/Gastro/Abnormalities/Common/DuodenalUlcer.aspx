<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Common_DuodenalUlcer" Codebehind="DuodenalUlcer.aspx.vb" %>

<!DOCTYPE html>



<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <script type="text/javascript">
        var duodenalUlcerValueChanged = false;
        $(window).on('load', function () {
            $('input[type="checkbox"]').each(function () {
                ToggleTRs($(this));
            });
            //ToggleSerialNoCombo();
        });

        $(document).ready(function () {
            //$('input[type="checkbox"]').change(function () {
            $("#DuodenalUlcerFormView_SpecimensTable tr td:first-child input:checkbox, input[type=text], input[type=radio]").change(function () {
                ToggleTRs($(this));
                duodenalUlcerValueChanged = true;
            });

            $("#DuodenalUlcerFormView_NoneCheckBox").change(function () {
                ToggleNoneCheckBox($(this).is(':checked'));
                duodenalUlcerValueChanged = true;
            });

            //for this page issue 4166  by Mostafiz
            $(window).on('beforeunload', function () {
                if (duodenalUlcerValueChanged) {
                    valueChange();
                    $("#SaveButton").click();
                }
            });

            $(window).on('unload', function () {
                localStorage.clear();
            });
        });

        function valueChange() {
            var ulcerChecked = $("#DuodenalUlcerFormView_UlcerCheckBox").is(':checked');

            var noneChecked = $("#DuodenalUlcerFormView_NoneCheckBox").is(':checked');
           if (ulcerChecked || noneChecked) {
                localStorage.setItem('valueChanged', 'true');
            } else {
                localStorage.setItem('valueChanged', 'false');
            }
        }

        function CloseWindow() {
            window.parent.CloseWindow();
        }
        //changed by mostafiz issue 3647
        function ToggleTRs(chkbox) {
            if (chkbox[0].id != "DuodenalUlcerFormView_NoneCheckBox") {
                var checked = chkbox.is(':checked');
                if (checked) {
                    $("#DuodenalUlcerFormView_NoneCheckBox").prop('checked', false);
                }
                chkbox.closest('td')
                    .nextUntil('tr').each(function () {
                        if (checked) {
                            $(this).show();
                            //$(this).fadeIn();
                        }
                        else {
                            $(this).hide();
                            //$(this).fadeOut();
                            ClearControls($(this));
                        }
                    });
                if (chkbox[0] != null) {
                    if (chkbox[0].id == "DuodenalUlcerFormView_UlcerCheckBox") {
                        if (checked) {
                            chkbox.closest('tr').next().show();
                            //chkbox.closest('tr').next().fadeIn();
                        }
                        else {
                            chkbox.closest('tr').next().hide();
                            //chkbox.closest('tr').next().fadeOut();
                            ClearControls(chkbox.closest('tr').next());
                        }
                    }
                    if (chkbox[0].id == "DuodenalUlcerFormView_VisibleVesselCheckBox") {
                        if (checked) {
                            $("#DuodenalUlcerFormView_VisibleVesselRadioButtonList").show();
                        } else {
                            $("#DuodenalUlcerFormView_VisibleVesselRadioButtonList").hide();
                        }
                    }
                    if (chkbox[0].id == "DuodenalUlcerFormView_ActiveBleedingCheckBox") {
                        if (checked) {
                            $("#DuodenalUlcerFormView_ActiveBleedingRadioButtonList").show();
                        } else {
                            $("#DuodenalUlcerFormView_ActiveBleedingRadioButtonList").hide();
                        }
                    }
                }
            }
        }
        //changed by mostafiz issue 3647
        function ToggleNoneCheckBox(checked) {
            if (checked) {
                $("#DuodenalUlcerFormView_SpecimensTable tr td:first-child").each(function () {
                    $(this).find("input:checkbox:checked").prop('checked', false);
                    $(this).find("input:checkbox").trigger("change");
                });
            }
        }

        //changed by mostafiz issue 3647
        function ClearControls(tableCell) {
            tableCell.find("input:radio:checked").prop('checked', false);
            tableCell.find("input:checkbox:checked").prop('checked', false);
            tableCell.find("input:text").val("");
        }
    </script>
    <style type="text/css">
        .SiteDetailsForm {
            /*font: 12px / 18px "segoe ui", arial, sans-serif;
            color: #000;*/
            font-size: 12px;
            font-family: "Segoe UI",Arial,Helvetica,sans-serif;
            color: black;
        }

            .SiteDetailsForm td {
                padding-bottom:10px;
            }

        .AutoHeight {
            height: auto !important;
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
        <telerik:RadScriptManager ID="DuodenalUlcerRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div id="HeaderDiv" runat="server" class="abnorHeader">Duodenal Ulcer</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">

                <asp:ObjectDataSource ID="DuodenalUlcerObjectDataSource" runat="server"
                    TypeName="UnisoftERS.Abnormalities" SelectMethod="GetDuodenalUlcerData" UpdateMethod="SaveDuodenalUlcerData" InsertMethod="SaveDuodenalUlcerData">
                    <SelectParameters>
                        <asp:Parameter Name="siteId" DbType="Int32" DefaultValue="0" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="siteId" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="none" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="Ulcer" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="UlcerType" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="Quantity" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="Largest" DbType="Decimal" DefaultValue="0" />
                        <asp:Parameter Name="VisibleVessel" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="VisibleVesselType" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="FreshClot" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="ActiveBleeding" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="ActiveBleedingType" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="OldClot" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="Perforation" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="RegionalIdentifier" DbType="String" DefaultValue="" />
                    </UpdateParameters>
                    <InsertParameters>
                        <asp:Parameter Name="siteId" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="none" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="Ulcer" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="UlcerType" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="Quantity" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="Largest" DbType="Decimal" DefaultValue="0" />
                        <asp:Parameter Name="VisibleVessel" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="VisibleVesselType" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="FreshClot" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="ActiveBleeding" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="ActiveBleedingType" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="OldClot" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="Perforation" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="RegionalIdentifier" DbType="String" DefaultValue="" />
                    </InsertParameters>
                </asp:ObjectDataSource>

                <asp:FormView ID="DuodenalUlcerFormView" runat="server" DefaultMode="Edit"
                    DataSourceID="DuodenalUlcerObjectDataSource" DataKeyNames="SiteId">
                    <EditItemTemplate>


                        <div id="ContentDiv">
                            <div class="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">
                                    <table id="SpecimensTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width:780px;">
                                   <%-- <table id="SpecimensTable" class="rgview" cellpadding="0" cellspacing="0">--%>
                                        <colgroup>
                                            <col>
                                            <col>
                                            <col>
                                        </colgroup>
                                        <thead>
                                            <tr>
                                                <th class="rgHeader" style="text-align: left;" colspan="2" >
                                                    <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" ForeColor="Black" Checked='<%# Bind("None")%>' />
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td style="padding:0px 0px 0px 6px;">
                                                    <table style="width:100%; ">
                                                        <tr>
                                                            <td style="border:none;vertical-align:top;width:120px;" >
                                                                <asp:CheckBox ID="UlcerCheckBox" runat="server" Checked='<%# Bind("Ulcer")%>' Text="Ulcer" />
                                                            </td>
                                                            <td style="border:none;width:20%;">
                                                                <fieldset id="UlcerTypeFieldset" runat="server" style="width:80px;" >
                                                                    <legend>Type</legend>
                                                                    <asp:RadioButtonList ID="UlcerTypeRadioButtonList" runat="server" 
                                                                        CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow">
                                                                        <asp:ListItem Value="1" Text="Acute"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="Chronic"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </fieldset>
                                                            </td>
                                                            <td style="border:none; text-align:right; padding-right:150px;">
                                                                 Number:
                                                                <span style="padding-right:16px;">
                                                                    <telerik:RadNumericTextBox ID="HistologyQtyNumericTextBox" runat="server" DbValue='<%# Bind("Quantity")%>'
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0"
                                                                        Style="margin-right: 3px;">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                </span>
                                                                <br /><br />
                                                                
                                                                Largest diameter:
                                                                <telerik:RadNumericTextBox ID="MicrobiologyQtyNumericTextBox" runat="server" DbValue='<%# Bind("Largest")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0"
                                                                    Style="margin-right: 3px;">
                                                                    <NumberFormat DecimalDigits="1" />
                                                                </telerik:RadNumericTextBox>cm&nbsp;
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="border:none;width:120px;">
                                                            </td>
                                                            <td colspan="2" style="border:none;">
                                                                <fieldset id="Fieldset1" runat="server">
                                                                <legend>Other features</legend>
                                                                    <div style="float:left;">  
                                                                        <asp:CheckBox ID="VisibleVesselCheckBox" runat="server" Checked='<%# Bind("VisibleVessel")%>' Text="visible vessel" />
                                                                        <div id="VisibleVesselDiv" style="padding-left:10px;">
                                                                            <asp:RadioButtonList ID="VisibleVesselRadioButtonList" runat="server" 
                                                                                CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow">
                                                                                <asp:ListItem Value="1" Text="adherent clot in base"></asp:ListItem>
                                                                                <asp:ListItem Value="2" Text="pigmented base"></asp:ListItem>
                                                                            </asp:RadioButtonList>
                                                                        </div>
                                                                    </div>
                                                                    <div style="float:left;padding-left:20px;">
                                                                        <asp:CheckBox ID="ActiveBleedingCheckBox" runat="server" Checked='<%# Bind("ActiveBleeding")%>' Text="active bleeding" />
                                                                        <div id="ActiveBleedingDiv" style="padding-left:10px;">
                                                                            <asp:RadioButtonList ID="ActiveBleedingRadioButtonList" runat="server" 
                                                                                CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" >
                                                                                <asp:ListItem Value="1" Text="spurting"></asp:ListItem>
                                                                                <asp:ListItem Value="2" Text="oozing"></asp:ListItem>
                                                                            </asp:RadioButtonList>
                                                                        </div>
                                                                    </div>
                                                                    <div style="float:left;padding-left:40px;">                                                                                
                                                                        <asp:CheckBox ID="CheckBox3" runat="server" Checked='<%# Bind("FreshClot")%>' Text="fresh clot" /><br />
                                                                        <asp:CheckBox ID="CheckBox4" runat="server" Checked='<%# Bind("OldClot")%>' Text="old clot" /><br />
                                                                        <asp:CheckBox ID="CheckBox5" runat="server" Checked='<%# Bind("Perforation")%>' Text="perforation" />
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
                        </div>





                        
                    </EditItemTemplate>
                </asp:FormView>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; display:none; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
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
