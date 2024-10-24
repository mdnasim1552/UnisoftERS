<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_OtherData_OGD_PatientMedication" Codebehind="PatientMedication.aspx.vb" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link href="../../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .checkboxesTable td {
            padding-right: 10px;
            padding-bottom: 3px;
        }
        #MaximumDoseLimitCrossRadWindow_C{
            width: 417px !important;
            height: 185px !important;
        }
        #RadWindowWrapper_MaximumDoseLimitCrossRadWindow{
                width: 426px !important;
        }
    </style>
    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">

            var AddNewItemRadTextBoxClientId = "<%= AddNewItemRadTextBox.ClientID %>";
            var AddNewItemRadWindowClientId = "<%= AddNewItemRadWindow.ClientID %>";

            function RemoveItem() {
                var lb = $telerik.findButton("<%= PrescriptionList.ClientID%>");
                var item = lb.get_selectedItem();
                lb.trackChanges();
                lb.get_items().remove(item);
                lb.commitChanges();
                $telerik.findButton("<%= RemoveRadButton.ClientID%>").set_enabled(false);
            }

            function ClearAllItems() {
                var lbl = $telerik.findButton("<%= PrescriptionList.ClientID%>");
                lbl.trackChanges();
                var items = lbl.get_items();
                items.clear();
                lbl.commitChanges();
                var buttonadd = $telerik.findButton("<%= RemoveRadButton.ClientID%>");
                buttonadd.set_enabled(false);
                var buttonaddall = $telerik.findButton("<%= RemoveAllRadButton.ClientID%>");
                buttonaddall.set_enabled(false);
                var buttondose = $telerik.findButton("<%= ChangeDoseRadButton.ClientID%>");
                buttondose.set_enabled(false);

            }

            function EnableRemove() {
                var buttonadd = $telerik.findButton("<%= RemoveRadButton.ClientID%>");
                buttonadd.set_enabled(true);
                var buttonaddall = $telerik.findButton("<%= RemoveAllRadButton.ClientID%>");
                buttonaddall.set_enabled(true);
                var buttondose = $telerik.findButton("<%= ChangeDoseRadButton.ClientID%>");
                buttondose.set_enabled(true);
            }
            function EnableOkButton() {
                var buttonok = $telerik.findButton("<%= OkRadButton.ClientID%>");
                buttonok.set_enabled(true);
            }
            function CloseMedicationPrescribedWindow() {
                var oWnd = $find("<%=MedicationPrescribedWindow.ClientID%>");
                if (oWnd != null)
                    oWnd.close();
                return false;
            }
            function closeWin1() {
                var window = $find('<%=RadWindow1.ClientID%>');
                window.close();
            }
            function closeWin2() {
                var window = $find('<%=RadWindow2.ClientID%>');
                window.close();
            }
            function closeMaximumDoseLimitCrossRadWindow() {
                var window = $find('<%=MaximumDoseLimitCrossRadWindow.ClientID%>');
                window.close();
                var oWnd = $find("<%=MedicationPrescribedWindow.ClientID%>");
                if (oWnd != null)
                    oWnd.show();
            }
            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow;
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow;
                return oWindow;
            }
            function CloseDialog() {
                GetRadWindow().close();
                return false;
            }
            function PasslistToParent(vale) {
                //GetRadWindow().BrowserWindow.CalledFn(vale);
                GetRadWindow().close();
                return false;
            }
            function OpenAddorModify() {
                var oWindow = radopen("../../../Options/ModifyPremedicationDrugs.aspx?option=1", "Premedication Drugs", '780px', '600px');
                oWindow.set_title("Medication Drug");
            }

            function OnClientClose(oWnd, args) {
                $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("Rebind");
            }
        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <script type="text/javascript">
    </script>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" EnablePageMethods="true" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Position="Center" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />

        <telerik:RadAjaxPanel ID="RadAjaxPanel1" runat="server">
            <asp:ObjectDataSource ID="PrescriptionSqlDataSource" runat="server" SelectMethod="GetDrugInfo" TypeName="UnisoftERS.DataAccess">
                <SelectParameters>
                    <asp:Parameter Name="DrugNo" Type="Int32" />
                </SelectParameters>
            </asp:ObjectDataSource>
            <%--<asp:SqlDataSource ID="PrescriptionSqlDataSource" runat="server" ConnectionString="<%= UnisoftERS.DataAccess.ConnectionStr %>" SelectCommand="SELECT DrugNo, [DrugName] as Name,[DeliveryMethod] as Method, Units,[DefaultDose] as Dosage, [DoseIncrement] as Increment FROM [ERS_DrugList] WHERE ( [DrugNo] =@DrugNo)">
                <SelectParameters>
                    <asp:Parameter Name="DrugNo" Type="Int32" />
                    <%--asp:controlparameter name="DrugNo" controlid="DrugListBox" propertyname="SelectedValue"/>
                </SelectParameters>
            </asp:SqlDataSource>--%>
            <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="800px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
                <telerik:RadPane ID="ControlsRadPane" runat="server" Height="565px" Scrolling="Y">

                    <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
                        <AjaxSettings>
                            <%--<telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="DrugListBox" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                                    <telerik:AjaxUpdatedControl ControlID="AddRadButton" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                            <telerik:AjaxSetting AjaxControlID="DrugListBox">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="AddRadButton" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                            <telerik:AjaxSetting AjaxControlID="AddRadButton">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="MedicationPrescribedWindow" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>--%>
                            <telerik:AjaxSetting AjaxControlID="SaveButton">
                                <UpdatedControls>
                                    <telerik:AjaxUpdatedControl ControlID="RadNotification1"></telerik:AjaxUpdatedControl>
                                </UpdatedControls>
                            </telerik:AjaxSetting>
                        </AjaxSettings>
                    </telerik:RadAjaxManager>


                    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
                    </telerik:RadAjaxLoadingPanel>

                    <div id="ContentDiv">
                        <div class="otherDataHeading">
                            <b>
                                <asp:Label ID="HeadingLabel" runat="server">Patient Medication</asp:Label></b>
                        </div>
                        <div style="margin: 20px 0px 0px 0px; padding: 0px 10px 0px 10px;">
                            <fieldset id="Fieldset1" runat="server" class="otherDataFieldset" style="width:750px;">
                                <legend>Hints:</legend>
                                <table id="table1" runat="server" cellspacing="0" cellpadding="0" border="0" style="margin: 5px; padding-bottom: 5px;">
                                    <tr>
                                        <td style="padding-right:30px;border-right-style:dashed;border-width:1px;border-color:#B0E0E6;">
                                            To add drug(s) to the list of medication, choose a regimen in the right-hand list of drugs and click on the Add button. 
                                        </td>
                                        <td style="padding-left:30px;">
                                            To remove a medication or change the dose details, click in the LEFT hand window then click appropriate button. 
                                        </td>
                                    </tr>
                                </table>
                            </fieldset>
                            <fieldset>
                                <table id="table2" runat="server" cellspacing="0" cellpadding="0" border="0" style="margin: 5px; padding-bottom: 5px;">
                                    <tr>
                                        <td>
                                            <label style="color:#4888a2; font-weight:bold;">Choose regimen?(then click OK)</label><br />
                                            <telerik:RadDropDownList ID="RegimeDropDown" runat="server" Height="97px" DataSourceID="SqlDataSource2" DataTextField="Description" DataValueField="Regimen_No" OnClientSelectedIndexChanged="EnableOkButton" Skin="Windows7" Width="310px" DefaultMessage=" "></telerik:RadDropDownList>
                                            <telerik:RadButton ID="OkRadButton" Text="Ok" Enabled="false" runat="server" Skin="Web20" OnClick="loadRegime" AutoPostBack="true"></telerik:RadButton>
                                            <br />
                                            <%--<asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%= UnisoftERS.DataAccess.ConnectionStr %>" SelectCommand="SELECT DISTINCT [RegimenNo] AS Regimen_No, [Description] FROM [ERS_DrugRegime]"></asp:SqlDataSource>--%>
                                            <asp:ObjectDataSource ID="SqlDataSource2" runat="server" SelectMethod="GetDrugRegime" TypeName="UnisoftERS.DataAccess"/>
                                        </td>
                                        <td></td>
                                        <td></td>
                                        <td></td>
                                        <td valign="bottom" style="padding-top:20px;">
                                            <label style="color:#4888a2; font-weight:bold;">Add one of these</label><br />
                                        </td>

                                    </tr>
                                    <tr>
                                        <td valign="top">
                                            <div style="padding-top:20px;">
                                                <label style="color:#4888a2; font-weight:bold;">Medication prescribed for this patient:</label><br />
                                                <telerik:RadListBox ID="PrescriptionList" runat="server" Height="280px" Width="354px" OnClientSelectedIndexChanged="EnableRemove" Skin="Windows7"></telerik:RadListBox>
                                            </div>
                                            <div>
                                                <br />
                                                <telerik:RadButton ID="SaveRegimeButton" runat="server" Text="Save this medication as a regimen..." Skin="Windows7" OnClick="openRegime" AutoPostBack="true" />
                                            </div>
                                        </td>
                                        <td>&nbsp;&nbsp;</td>
                                        <td valign="top" align="center">
                                            <div style="padding-top:20px; ">
                                                <div>
                                                    <br />
                                                    <telerik:RadButton ID="AddRadButton" runat="server" Text="<--Add--" Width="144px" Enabled="false" AutoPostBack="true" OnClick="ShowDrugBox" Skin="Windows7"></telerik:RadButton>

                                                </div>
                                                <br />
                                                <div>
                                                    <telerik:RadButton ID="RemoveRadButton" runat="server" Text="--Remove-->" Width="144px" Enabled="false" AutoPostBack="false" OnClientClicked="RemoveItem" Skin="Windows7"></telerik:RadButton>
                                                </div>
                                                <br />
                                                <div>
                                                    <telerik:RadButton ID="RemoveAllRadButton" runat="server" Text="--Remove ALL-->" Width="144px" Enabled="false" AutoPostBack="false" OnClientClicked="ClearAllItems" Skin="Windows7"></telerik:RadButton>

                                                </div>
                                                <br />
                                                <br />
                                                <br />
                                                <div>
                                                    <telerik:RadButton ID="ChangeDoseRadButton" runat="server" Text="Change dose" Enabled="false" Width="144px" AutoPostBack="true" Skin="Windows7" OnClick="ChangeDose"></telerik:RadButton>

                                                </div>
                                            </div>
                                        </td>
                                        <td>&nbsp;&nbsp;</td>
                                        <td>
                                            <div>
                                                <telerik:RadListBox ID="DrugListBox" runat="server" Height="320px" Width="220px" DataKeyField="Drug_no" DataSortField="Drug_no" AllowAutomaticUpdates="true" 
                                                    DataSourceID="SqlDataSource1" DataTextField="Drug_Alias" DataValueField="Drug_no" Skin="Windows7" AutoPostBack="true" OnSelectedIndexChanged="DrugListBox_SelectedIndexChanged" />
                                                <asp:ObjectDataSource ID="SqlDataSource1" runat="server" SelectMethod="GetDrugType" TypeName="UnisoftERS.DataAccess">
                                                    <SelectParameters>
                                                        <asp:Parameter DefaultValue="1" Name="Drug_type" Type="Int16" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                
                                             <%--   <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%= UnisoftERS.DataAccess.ConnectionStr %>" SelectCommand="SELECT [Drugno] as Drug_no , [Drugname]+'('+[Deliverymethod] + ' in ' + [Units] + ')' AS Drug_Alias FROM [ERS_Druglist] WHERE ([Drugtype] = @Drug_type)">
                                                    <SelectParameters>
                                                        <asp:Parameter DefaultValue="1" Name="Drug_type" Type="Int16" />
                                                    </SelectParameters>
                                                </asp:SqlDataSource>--%>
                                            </div><br />
                                            <telerik:RadButton ID="ModifyorAddDrugRadButton" runat="server" Text="Modify/add drugs in the drug list..." OnClientClicked="OpenAddorModify" Skin="Web20" AutoPostBack="false" />
                                        </td>
                                    </tr>
                                </table>
                            </fieldset>
                        </div>
                    </div>
                </telerik:RadPane>

                <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px">
                    <div style="height: 10px; margin-left: 20px; padding-top: 6px;">
                        <telerik:RadButton ID="SaveButton" runat="server" Text="Save" OnClick="SavePrescription" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" />
                        <telerik:RadButton ID="CancelButton" runat="server" Text="Close" OnClientClicked="CloseDialog" Skin="Web20" Icon-PrimaryIconCssClass="telerikCancelButton"/>
                    </div>
                </telerik:RadPane>
            </telerik:RadSplitter>
            <telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="False" OnClientClose="OnClientClose"
                Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro"  Modal="True" Behavior="Close, Move" ReloadOnShow="True" VisibleStatusbar="false">
                <Windows>
                    <telerik:RadWindow ID="MedicationPrescribedWindow" runat="server" ReloadOnShow="true"
                        KeepInScreenBounds="true" Width="700px" Height="250px" Title="Medication Prescribed" VisibleStatusbar="false">
                        <ContentTemplate>
                            <asp:FormView ID="DrugDetailsFormView" runat="server" DataSourceID="PrescriptionSqlDataSource" BorderStyle="None">
                                <ItemTemplate>
                                    <div class="rptSummaryText10" style="margin-left: 5px; margin-top: 10px; padding-bottom: 10px;">
                                        <table>
                                            <tr>
                                                <td>Drug Name:</td>
                                                <td>
                                                    <%--<asp:HiddenField ID="DrugNoHidden" runat="server" Value='<%# Bind("DrugNo")%>' />--%>
                                                    <asp:CheckBox runat="server" Checked='<%# Bind("DoseNotApplicable")%>' ID="ChkDoseNotApplicable" Visible="false" />
                                                    <asp:Label ID="DrugNoHidden" runat="server" Text='<%# Bind("DrugNo")%>' Skin="Web20" Visible="false"></asp:Label>
                                                    <asp:Label ID="druglbl" runat="server" Text='<%# Bind("Name")%>' Skin="Web20"></asp:Label>

                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Dosage:</td>
                                                <asp:Label ID="incrementLabel" runat="server" Text='<%# Bind("Increment")%>' Skin="Web20" Visible="false"></asp:Label>
                                                <asp:Label ID="maximumDoseLabel" runat="server" Text='<%# Bind("MaximumDose")%>' Skin="Web20" style="display:none"></asp:Label>
                                                <%--<asp:HiddenField runat="server" ID="incrementLabel" Value='<%# Bind("Increment")%>' />--%>
                                                <td>
                                                    <asp:Label ID="lblDoseNotApplicable" runat="server" Text="Not applicable" Skin="Web20" Visible="false"></asp:Label>
                                                    <telerik:RadNumericTextBox ID="DosageNumericBox" runat="server"
                                                        Text='<%# Bind("Dosage")%>'
                                                        IncrementSettings-InterceptMouseWheel="false"
                                                        IncrementSettings-Step='<%# Bind("Increment")%>'
                                                        Width="85px"
                                                        MinValue="1" Culture="en-GB" DbValueFactor="1" LabelWidth="20px" Skin="Web20">
                                                        <NumberFormat DecimalDigits="1" />
                                                    </telerik:RadNumericTextBox><asp:Label runat="server" ID="UnitLabel" Text='<%# Bind("Units")%>'></asp:Label></td>

                                            </tr>
                                            <tr>
                                                <td>Delivery method:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="DeliveryMethodLabel" Text='<%# Bind("Method")%>' Skin="Web20"></asp:Label></td>
                                            </tr>
                                            <tr>
                                                <td>Frequency:</td>
                                                <td>
                                                    <telerik:RadComboBox ID="FrequencyDropDown" runat="server" Skin="Windows7" style="z-index:9999" /></td>
                                                <%--<asp:ObjectDataSource ID="FrequencySqlDataSource" runat="server" SelectMethod="GetListDetails" TypeName="UnisoftERS.DataAccess">
                                                    <SelectParameters>
                                                        <asp:Parameter DefaultValue="Medication_Frequency" Name="ListDescription" DbType="String" />
                                                        <asp:Parameter DefaultValue="false" Name="Suppressed" Type="Boolean" />
                                                        <asp:Parameter DefaultValue="" Name="OrderBy" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>--%>
                                             <%--   <asp:SqlDataSource ID="FrequencySqlDataSource" runat="server" ConnectionString="<%= UnisoftERS.DataAccess.ConnectionStr%>" SelectCommand="SELECT [ListItemText]  FROM [ERS_Lists] WHERE ( [ListDescription] ='Medication_Frequency') ORDER BY ListItemNo" />--%>
                                            </tr>
                                            <tr>
                                                <td>Duration:</td>
                                                <td>
                                                    <asp:DropDownList ID="DurationDropDownList" runat="server" DataValueField="ListItemText" DataTextField="ListItemText" DataSourceID="DurationSqlDataSource" Skin="Web20" />
                                                     <asp:ObjectDataSource ID="DurationSqlDataSource" runat="server" SelectMethod="GetListDetails" TypeName="UnisoftERS.DataAccess">
                                                    <SelectParameters>
                                                        <asp:Parameter DefaultValue="Medication_Duration" Name="ListDescription" DbType="String" />
                                                        <asp:Parameter DefaultValue="false" Name="Suppressed" Type="Boolean" />
                                                        <asp:Parameter DefaultValue="ListItemNo" Name="OrderBy" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                    <%--<asp:SqlDataSource ID="DurationSqlDataSource" runat="server" ConnectionString="<%= UnisoftERS.DataAccess.ConnectionStr %>" SelectCommand="SELECT [ListItemText]  FROM [ERS_Lists] WHERE ( [ListDescription] ='Medication_Duration') ORDER BY ListItemNo" />--%>
                                            </tr>
                                        </table>

                                    </div>

                                </ItemTemplate>

                            </asp:FormView>
                            <div id="buttonsdiv" style="margin-left: 5px; height: 10px; padding-top: 6px; vertical-align: central;">
                                <telerik:RadButton ID="AddDrugButton" runat="server" Text="Add this drug" OnClick="AddtoLeft" AutoPostBack="true" Skin="Web20" Icon-PrimaryIconCssClass="rbAdd" ButtonType="StandardButton" />
                                <telerik:RadButton ID="CancelDrugButton" runat="server" Text="Cancel" Skin="Web20"
                                    OnClientClicked="CloseMedicationPrescribedWindow" AutoPostBack="false" Icon-PrimaryIconCssClass="telerikCancelButton"/>
                            </div>

                        </ContentTemplate>
                    </telerik:RadWindow>
                </Windows>
            </telerik:RadWindowManager>
        </telerik:RadAjaxPanel>
        <telerik:RadWindowManager ID="RadWindowManager2" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro"  Modal="True" Behavior="Close, Move" ReloadOnShow="True" VisibleStatusbar="false">
            <Windows>
                <telerik:RadWindow ID="RadWindow1" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="500px" Height="120px" Title="Save Drug Regimen As" VisibleStatusbar="false" Modal="True">
                    <ContentTemplate>
                        <div align="center">
                            <table id="table3" runat="server" cellspacing="0" cellpadding="0" border="0" style="margin: 5px; padding-bottom: 5px;" align="center">
                                <tr>
                                    <td>Regimen description:&nbsp;&nbsp;</td>
                                    <td>
                                        <asp:TextBox ID="txt1" runat="server"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td></td>
                                    <td>
                                        <div id="buttonsdiv1" style="margin-left: 5px; height: 10px; padding-top: 16px; vertical-align: central;">
                                            <telerik:RadButton ID="btn1" runat="server" Text="Ok" Skin="Web20" OnClick="mee" AutoPostBack="true" Icon-PrimaryIconCssClass="telerikOkButton"/>
                                            <telerik:RadButton ID="btn2" runat="server" Text="Cancel" AutoPostBack="false" OnClientClicked="closeWin1" Skin="Web20"  Icon-PrimaryIconCssClass="telerikCancelButton"/>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="RadWindow2" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="700px" Height="200px" Title="Save As" VisibleStatusbar="false" Modal="true">
                    <ContentTemplate>
                        <div align="center">
                            <table id="table4" runat="server" cellspacing="0" cellpadding="0" border="0" style="margin: 5px; padding-bottom: 5px;" align="center">
                                <tr>
                                    <td>Replace existing one?<br />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div id="buttonsdiv2" style="margin-left: 5px; height: 10px; padding-top: 6px; vertical-align: central;">
                                            <telerik:RadButton ID="RadButton1" runat="server" Text="Confirm" Skin="Web20" OnClick="meee" AutoPostBack="true" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                                            <telerik:RadButton ID="RadButton2" runat="server" Text="Cancel" AutoPostBack="false" OnClientClicked="closeWin2" Skin="Web20"  Icon-PrimaryIconCssClass="telerikCancelButton"/>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
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
                                    <div id="buttonsdiv3" style="height: 10px; padding-top: 16px;">
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
        <telerik:RadWindowManager ID="RadWindowManager3" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move, Resize" Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="MaximumDoseLimitCrossRadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Height="200px" VisibleStatusbar="false" VisibleOnPageLoad="false" Title="Limit Cross" BackColor="#ffffcc" Left="100px">
                    <ContentTemplate>
                        <table width="100%">
                            <tr>
                                <td style="vertical-align: top; padding-left: 20px; padding-top: 40px">
                                    <img id="Img1" runat="server" src="~/Images/info-24x24.png" alt="icon" />
                                </td>
                                <td style="text-align: center; padding: 20px; height: 75px; overflow-y: auto">
                                    <asp:Label ID="lblMessage" runat="server" Font-Size="medium" Text="Do you wish to continue?" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td style="padding: 10px; text-align: center;">
                                    <telerik:RadButton ID="ContinueRadButton" runat="server" Text="Continue" Skin="Windows7" ButtonType="SkinnedButton" Font-Size="Large" AutoPostBack="true" Style="margin-right: 20px;" OnClick="ContinueRadButton_Click" />
                                    <telerik:RadButton ID="CancelRadButton" runat="server" Text="Cancel" Skin="Windows7" ButtonType="SkinnedButton" AutoPostBack="false" OnClientClicked="closeMaximumDoseLimitCrossRadWindow" Font-Size="Large" />
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
    </form>
</body>
</html>

