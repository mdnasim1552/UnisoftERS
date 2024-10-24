<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_EditDrugs" CodeBehind="EditDrugs.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Drug Details Form</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">

            var AddNewItemRadTextBoxClientId = "<%= AddNewItemRadTextBox.ClientID %>";
            var AddNewItemRadWindowClientId = "<%= AddNewItemRadWindow.ClientID %>";

            $(window).on('load', function () {
            });

            $(document).ready(function () {
            });

            function loadForm() {
                var ChkDose = $("#<%= DrugDetailsFormView.FindControl("ChkDoseNotApplicable").ClientID%>").is(':checked');
                NotApplicableChecked(ChkDose, true);
            }

            var oDoseVal = 0;
            var oIncrVal = 0;
            var oUnitsVal = 0;

            function NotApplicableChecked(checked, frmLoad) {
                var oDose = $find("<%= DrugDetailsFormView.FindControl("DeafaultDoseRadNumericTextBox").ClientID%>");
                var oIncr = $find("<%= DrugDetailsFormView.FindControl("DoseIncrementRadNumericTextBox").ClientID%>");
                var oUnits = $find("<%= DrugDetailsFormView.FindControl("UnitsDropDown").ClientID%>");

                //for validator toggle
                var reqElement = { control: "<%= DrugDetailsFormView.FindControl("UnitsDropDown").ClientID%>", fieldName: "Units" };

                if (checked) {
                    oDoseVal = oDose.get_value();
                    oIncrVal = oIncr.get_value();
                    oUnitsVal = oUnits.get_selectedItem().get_text();
                    oDose.clear();
                    oIncr.clear();
                    oUnits.findItemByText("").select();
                    oDose.disable();
                    oIncr.disable();
                    $("#SpanUnitsDropDown").css("pointer-events", "none"); <%'RadDropdownlist : disable doesn't work inside formview - used css instead%>

                    //disable required fields
                    var inx = -1;
                    reqFields.items.find(function (item, i) {
                        if (item.control === reqElement.control) {
                            inx = i;
                            return inx;
                        }
                    });

                    if (inx > -1) {
                        //remove Dose as a required field (if exists)
                        delete reqFields.items.splice(inx, 1);
                        $(oUnits).removeClass("validation-error-field");
                    }
                } else {
                    if (!frmLoad) {
                        oDose.set_value(oDoseVal);
                        oIncr.set_value(oIncrVal);
                        oUnits.findItemByText(oUnitsVal).select();
                    }
                    oDose.enable();
                    oIncr.enable();
                    $("#SpanUnitsDropDown").css("pointer-events", "all");


                    if (reqFields != undefined) {
                        var inx = -1;
                        reqFields.items.find(function (item, i) {
                            if (item.control === reqElement.control) {
                                inx = i;
                                return inx;
                            }
                        });

                        if (inx == -1) {
                            //make Dose a required field
                            reqFields.items.push(reqElement);
                        }
                    }
                }
            }

            function openAddTitleWindow() {
                //Get a reference to the window.
                var oWnd = $find("<%= AddNewTitleRadWindow.ClientID %>");

                ////Add the name of the function to be executed when RadWindow is closed.
                //oWnd.add_close(OnClientClose);

                oWnd.show();

                //window.radopen(null, "AddNewTitleRadWindow");

                return false;
            }

            function closeAddTitleWindow() {
                var oWnd = $find("<%= AddNewTitleRadWindow.ClientID %>");
                if (oWnd != null)
                    oWnd.close();
                return false;
            }

            function CloseAndRebind(args) {
                GetRadWindow().BrowserWindow.refreshGrid(args);
                GetRadWindow().close();
            }

            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow; //Will work in Moz in all cases, including clasic dialog
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow; //IE (and Moz as well)

                return oWindow;
            }
            function CancelEdit() {
                GetRadWindow().BrowserWindow.refreshGrid();
                GetRadWindow().close();
            }
        </script>
    </telerik:RadScriptBlock>
</head>

<body onload="loadForm();">
    <script type="text/javascript">
</script>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="DrugDetailsFormView">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="DrugDetailsFormView">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ServerErrorLabel" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <div class="optionsHeading">
            <asp:Label ID="HeadingLabel" runat="server" Text="Edit User"></asp:Label>
        </div>

        <telerik:RadFormDecorator ID="UserMaintenanceRadFormDecorator" runat="server" DecoratedControls="All"
            DecorationZoneID="FormDiv" Skin="Metro" />
        <asp:ObjectDataSource ID="DrugDetailsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetDrug" UpdateMethod="UpdateDrug" InsertMethod="InsertDrug">
            <SelectParameters>
                <asp:Parameter Name="DrugID" Type="Int32" />
            </SelectParameters>
            <InsertParameters>
                <asp:Parameter Name="DrugNo" Type="Int32" />
                <asp:Parameter Name="Drugname" Type="String" />
                <asp:Parameter Name="DrugType" Type="Int32" />
                <asp:Parameter Name="Isreversingagent" Type="Int32" />
                <asp:Parameter Name="Units" Type="String" />
                <asp:Parameter Name="DoseNotApplicable" Type="Boolean" />
                <asp:Parameter Name="Defaultdose" Type="Double" />
                <asp:Parameter Name="Doseincrement" Type="Double" />
                <asp:Parameter Name="Deliverymethod" Type="String" />
                <asp:Parameter Name="UsedinUpperGI" Type="Int32" />
                <asp:Parameter Name="UsedinEUSOGD" Type="Int32" />
                <asp:Parameter Name="UsedinERCP" Type="Int32" />
                <asp:Parameter Name="UsedinEUSHPB" Type="Int32" />
                <asp:Parameter Name="UsedinColonSig" Type="Int32" />
                <asp:Parameter Name="UsedinBroncho" Type="Int32" />
                <asp:Parameter Name="UsedinEBUS" Type="Int32" />
                <asp:Parameter Name="UsedInAntegrade" Type="Int32" />
                <asp:Parameter Name="UsedInRetrograde" Type="Int32" />
                <asp:Parameter Name="UsedInFlexiCystoscopy" Type="Int32" />
                <asp:Parameter Name="MaximumDose" Type="Double" />
            </InsertParameters>
            <UpdateParameters>
                <asp:Parameter Name="DrugNo" Type="Int32" />
                <asp:Parameter Name="Drugname" Type="String" />
                <asp:Parameter Name="DrugType" Type="Int32" />
                <asp:Parameter Name="Isreversingagent" Type="Int32" />
                <asp:Parameter Name="Units" Type="String" />
                <asp:Parameter Name="DoseNotApplicable" Type="Boolean" />
                <asp:Parameter Name="Defaultdose" Type="Double" />
                <asp:Parameter Name="Doseincrement" Type="Double" />
                <asp:Parameter Name="Deliverymethod" Type="String" />
                <asp:Parameter Name="UsedinUpperGI" Type="Int32" />
                <asp:Parameter Name="UsedinEUSOGD" Type="Int32" />
                <asp:Parameter Name="UsedinERCP" Type="Int32" />
                <asp:Parameter Name="UsedinEUSHPB" Type="Int32" />
                <asp:Parameter Name="UsedinColonSig" Type="Int32" />
                <asp:Parameter Name="UsedInBroncho" Type="Int32" />
                <asp:Parameter Name="UsedinEBUS" Type="Int32" />
                <asp:Parameter Name="UsedInAntegrade" Type="Int32" />
                <asp:Parameter Name="UsedInRetrograde" Type="Int32" />
                <asp:Parameter Name="UsedInFlexiCystoscopy" Type="Int32" />
                <asp:Parameter Name="MaximumDose" Type="Double" />
            </UpdateParameters>
        </asp:ObjectDataSource>
        <asp:ObjectDataSource ID="unitsDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetListDetails">
            <SelectParameters>
                <asp:Parameter DefaultValue="Premedication Drug Units" Name="ListDescription" Type="String" />
                <asp:Parameter DefaultValue="false" Name="Suppressed" Type="Boolean" />
                <asp:Parameter DefaultValue="" Name="OrderBy" Type="String" />
            </SelectParameters>
        </asp:ObjectDataSource>
        <asp:ObjectDataSource ID="DeliveryDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetListDetails">
            <SelectParameters>
                <asp:Parameter DefaultValue="Premedication Delivery Method" Name="ListDescription" Type="String" />
                <asp:Parameter DefaultValue="false" Name="Suppressed" Type="Boolean" />
                <asp:Parameter DefaultValue="" Name="OrderBy" Type="String" />
            </SelectParameters>
        </asp:ObjectDataSource>
        <%--<asp:SqlDataSource runat="server" ID="unitsDataSource" ConnectionString="<%$ ConnectionStrings:Gastro_DB %>"
            SelectCommand="SELECT [ListItemText] FROM [ERS_Lists] WHERE (([ListDescription] = @ListDescription) AND ([Suppressed] = @Suppressed))">
            <SelectParameters>
                <asp:Parameter DefaultValue="Premedication Drug Units" Name="ListDescription" Type="String" />
                <asp:Parameter DefaultValue="false" Name="Suppressed" Type="Boolean" />
            </SelectParameters>
        </asp:SqlDataSource>--%>
        <%-- <asp:SqlDataSource runat="server" ID="DeliveryDataSource" ConnectionString="<%$ ConnectionStrings:Gastro_DB %>"
            SelectCommand="SELECT [ListItemText] FROM [ERS_Lists] WHERE (([ListDescription] = @ListDescription) AND ([Suppressed] = @Suppressed))">
            <SelectParameters>
                <asp:Parameter DefaultValue="Premedication Delivery Method" Name="ListDescription" Type="String" />
                <asp:Parameter DefaultValue="false" Name="Suppressed" Type="Boolean" />
            </SelectParameters>
        </asp:SqlDataSource>--%>
        <div id="FormDiv" runat="server">
            <div style="margin-left: 10px;" class="rptText">
                <asp:FormView ID="DrugDetailsFormView" runat="server" DataSourceID="DrugDetailsObjectDataSource" BorderStyle="None">
                    <EditItemTemplate>
                        <table id="HaemorrhoidsTable" class="rgview" cellpadding="0" cellspacing="0" style="width: 590px;">
                            <tbody>
                                <asp:Label ID="lblno" runat="server" Text='<%# Bind("DrugNo")%>' Visible="False"></asp:Label>
                                <asp:HiddenField ID="DrugTypeHidden" runat="server" Value='<%# Bind("DrugType")%>' />
                                <tr class="rgRow">
                                    <td colspan="1" class="auto-style1" style="border: none;">
                                        <fieldset>
                                            <legend>Please Note:</legend>
                                            <label>
                                                Once a drug has been added it cannot be deleted. If you want to stop a drug from appearing in any of the lists, uncheck all of the 'Used in these procedure' boxes.
                                            </label>
                                        </fieldset>
                                    </td>
                                </tr>
                                <tr class="rgRow">
                                    <td style="border: none;">
                                        <fieldset>
                                            <legend>Modify drug details</legend>
                                            <div>
                                                <table>
                                                    <tr>
                                                        <td style="border: none;">Name of drug: &nbsp;<telerik:RadTextBox ID="DrugNameTextBox" Text='<%# Bind("Drugname")%>' runat="server"></telerik:RadTextBox>
                                                            <span style="margin-right: 40px;"></span>
                                                            <asp:CheckBox runat="server" ID="ReversingAgentCheckBox" Checked='<%# Bind("Isreversingagent")%>' Text="Is a reversing agent" />
                                                        </td>

                                                    </tr>
                                                </table>
                                            </div>
                                            <div>
                                                <table>
                                                    <tr>
                                                        <td style="border: none; padding-top: 15px; padding-bottom: 15px;">Delivery method: &nbsp;
                                                            <telerik:RadComboBox runat="server" ID="DeliveryDropDownList" Skin="Metro"></telerik:RadComboBox>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </div>
                                            <div id="divDose">
                                                <fieldset>
                                                    <legend>Dose (not applicable<asp:CheckBox runat="server" onclick="javascript:NotApplicableChecked(this.checked, false);" Checked='<%# Bind("DoseNotApplicable")%>' ID="ChkDoseNotApplicable" />)</legend>
                                                    <label>Default dose:</label>
                                                    <telerik:RadNumericTextBox ID="DeafaultDoseRadNumericTextBox" runat="server"
                                                        Text='<%# Bind("Defaultdose")%>'
                                                        IncrementSettings-InterceptMouseWheel="false"
                                                        IncrementSettings-Step="1"
                                                        Width="45px"
                                                        MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="10px" Value="0.00">
                                                        <NumberFormat DecimalDigits="2" />
                                                    </telerik:RadNumericTextBox><span style="margin-right: 40px;"></span>
                                                    <div style="display:none">
                                                    <label>Dose increment:</label>
                                                        <telerik:RadNumericTextBox ID="DoseIncrementRadNumericTextBox" runat="server" 
                                                            ShowSpinButtons="True" Text='<%# Bind("Doseincrement")%>'
                                                            IncrementSettings-InterceptMouseWheel="true"
                                                            IncrementSettings-Step="1"
                                                            Width="60px"
                                                            MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="10px" Value="0.00">
                                                            <NumberFormat DecimalDigits="2" />
                                                        </telerik:RadNumericTextBox>
                                                    </div>
                                                    <label>Maximum Dose:</label>
                                                    <telerik:RadNumericTextBox ID="MaximumDoseRadNumericTextBox" runat="server"
                                                        Text='<%# Bind("MaximumDose")%>'
                                                        IncrementSettings-InterceptMouseWheel="false"
                                                        IncrementSettings-Step="1"
                                                        Width="35px"
                                                        MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="10px" Value="0.00">
                                                        <NumberFormat DecimalDigits="2" />
                                                    </telerik:RadNumericTextBox>
                                                    <span style="margin-right: 40px;"></span>
                                                    <label>Units:</label>
                                                    <span id="SpanUnitsDropDown">
                                                        <telerik:RadComboBox runat="server" ID="UnitsDropDown" DataSourceID="unitsDataSource" DataValueField="ListItemText" Skin="Metro" DataTextField="ListItemText" OnDataBound="DropDown_DataBound" Width="85"></telerik:RadComboBox>
                                                    </span>
                                                </fieldset>
                                            </div>
                                            <div>
                                            </div>
                                            <div style="padding-top: 15px;">
                                                <fieldset>
                                                    <legend>Used in the procedures:</legend>
                                                    <asp:CheckBox ID="GastroscopyCheckBox" runat="server" Text="Gastroscopy" Checked='<%# Bind("UsedinUpperGI")%>' />
                                                    <span style="margin-right: 15px;"></span>
                                                    <asp:CheckBox ID="EUSCheckBox" runat="server" Text="EUS" Checked='<%# Bind("UsedinEUSOGD")%>' />
                                                    <span style="margin-right: 15px;"></span>
                                                    <asp:CheckBox ID="ERCPCheckBox" runat="server" Text="ERCP" Checked='<%# Bind("UsedinERCP")%>' />
                                                    <span style="margin-right: 15px;"></span>
                                                    <asp:CheckBox ID="HPBCheckBox" runat="server" Text="HPB" Checked='<%# Bind("UsedinEUSHPB")%>' />
                                                    <span style="margin-right: 15px;"></span>
                                                    <asp:CheckBox ID="ColonoscopyCheckBox" runat="server" Text="Colonoscopy/sigmoidoscopy" Checked='<%# Bind("UsedinColonSig")%>' />
                                                    <br />
                                                    <asp:CheckBox ID="EnteroscopyAntegradeCheckBox" runat="server" Text="Enteroscopy antegrade"  Checked='<%# Bind("UsedInAntegrade")%>' />
                                                    <span style="margin-right: 15px;"></span>
                                                    <asp:CheckBox ID="EnteroscopyRetrograde" runat="server" Text="Enteroscopy retrograde"   Checked='<%# Bind("UsedInRetrograde")%>' />
                                                    <span style="margin-right: 15px;"></span>
                                                    <asp:CheckBox ID="BronchoscopyCheckBox" runat="server" Text="Bronchoscopy" Checked='<%# Bind("UsedInBroncho")%>' />
                                                    <span style="margin-right: 15px;"></span>
                                                    <asp:CheckBox ID="EBUSCheckBox" runat="server" Text="EBUS" Checked='<%# Bind("UsedInEBUS")%>' />
                                                    <br />
                                                    <asp:CheckBox ID="FlexiCheckBox" runat="server" Text="Cystoscopy" Checked='<%# Bind("UsedInFlexiCystoscopy")%>' />
                                                    <span style="margin-right: 15px;"></span>
                                                </fieldset>
                                            </div>
                                        </fieldset>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        <br />
                        <div id="buttonsdiv" style="height: 10px; margin-left: 5px; vertical-align: central;">
                            <%--<telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" AutoPostBack="true" />--%>
                            <telerik:RadButton ID="SaveAndCloseButton" runat="server" Text="Save & Close" Skin="Metro" OnClientClicked="validatePage" AutoPostBack="true" Icon-PrimaryIconCssClass="telerikSaveButton" />
                            <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Metro" AutoPostBack="false" OnClientClicked="CancelEdit" Icon-PrimaryIconCssClass="telerikCancelButton"
                                CausesValidation="false" />
                        </div>
                    </EditItemTemplate>
                </asp:FormView>
            </div>
            <telerik:RadWindowManager ID="AddNewTitleRadWindowManager" runat="server" ShowContentDuringLoad="false"
                Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
                <Windows>
                    <telerik:RadWindow ID="AddNewTitleRadWindow" runat="server" ReloadOnShow="true"
                        KeepInScreenBounds="true" Width="400px" Height="160px" VisibleStatusbar="false">
                        <ContentTemplate>
                            <table cellspacing="3" cellpadding="3">
                                <tr>
                                    <td>
                                        <b>Add new title</b>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <telerik:RadTextBox ID="AddNewTitleRadTextBox" runat="Server" Width="300px" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div id="buttonsdiv" style="height: 10px; padding-top: 6px; vertical-align: central;">
                                            <telerik:RadButton ID="AddNewTitleSaveRadButton" runat="server" Text="Save" Skin="Metro" />
                                            <telerik:RadButton ID="AddNewTitleCancelRadButton" runat="server" Text="Cancel" Skin="Metro"
                                                OnClientClicked="closeAddTitleWindow" AutoPostBack="true" />
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </telerik:RadWindow>

                    <telerik:RadWindow ID="AddNewItemRadWindow" runat="server" ReloadOnShow="true" VisibleStatusbar="false" Title="Add new entry"
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
                                            <telerik:RadButton ID="AddNewItemSaveRadButton" runat="server" Text="Add" Skin="Metro" AutoPostBack="false" OnClientClicked="AddNewItem" ButtonType="SkinnedButton" />
                                            &nbsp;&nbsp;
                                        <telerik:RadButton ID="AddNewItemCancelRadButton" runat="server" Text="Cancel" Skin="Metro" AutoPostBack="false" OnClientClicked="CancelAddNewItem" ButtonType="SkinnedButton" />
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </telerik:RadWindow>
                </Windows>
            </telerik:RadWindowManager>
        </div>
    </form>
</body>

</html>
