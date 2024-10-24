<%@ Page Title="" Language="VB" MasterPageFile="~/Templates/ProcedureMaster.Master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Common_PreMed" CodeBehind="PreMed.aspx.vb" %>

<%@ MasterType VirtualPath="~/Templates/ProcedureMaster.Master" %>

<asp:Content ID="PMHead" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="Server">
    <script type="text/javascript" src="../../Scripts/jquery-1.11.0.min.js"></script>
    <script type="text/javascript" src="../../Scripts/global.js"></script>
    <style type="text/css">
        .border_bottom {
            border-bottom: 1pt dashed #B8CBDE;
        }
    </style>
    <script type="text/javascript">
        window.onbeforeunload = function (event) {
            document.getElementById("<%= SaveOnly.ClientID %>").click();
        }

        $(window).load(function () {
            DrugsTab();
            BowelTab();
        });

        $(document).ready(function () {

           <%-- $('#<%=cmdAccept.ClientID%>').on('click', function () {
                if (!validatePage()) {

                }
            });--%>

            $("#multiPageDivTab").find("input[type=text],input:checkbox, select, textarea").change(function () {
                DrugsTab();
                ToggleNoneCheckBox($(this).attr("id"), $(this).val());
            });

            $("#multiPageDivTab1").find("input[type=text],input:checkbox, input:radio, select, textarea").change(function () {
                BowelTab();
            });
        });

        function validateBowelPrep() {
            //alert('clicked');
        }
        function showToolTip(value) {
            var radToolTip = $find('<%=BowlPrepRadToolTip.ClientID%>');
            var tooltip = '';

            if (value == '4') {
                tooltip = 'Excellent - >90 % of mucosa seen, mostly liquid stool, minimal suctioning needed for adequate visualization.';
            }
            else if (value == '3') {
                tooltip = 'Good - >90 % of mucosa seen, mostly liquid stool, significant suctioning needed for adequate visualization.';
            }
            else if (value == '2') {
                tooltip = 'Fair - >90 % of mucosa seen, mixture of liquid and semisolid stool, could be suctioned and / or washed.';
            }
            else if (value == '1') {
                tooltip = 'Inadequate - < 90 % of mucosa seen, mixture of semisolid and solid stool that could not be suctioned or washed.';
            }
            else {
                tooltip = '';
            }

            if (tooltip != '') {
                radToolTip.set_text(tooltip);
                radToolTip.show();
            }
            else {
                radToolTip.set_text('');
                radToolTip.hide();
            }
        }
        function DrugsTab() {
            var apply = false;
            //$("#multiPageDivTab").find("input[type=text], select, textarea").each(function () {
            //    if ($(this).vasl() != null && $(this).val() != '') { apply = true; return false; }
            //});
            if ($("#multiPageDivTab input:checkbox:checked").length > 0) { apply = true; }
            setImage("0", apply);
        }

        function ToggleNoneCheckBox(id, value) {
            if (id == 'NoSedationChkBox') {// || id == 'GeneralAnaestheticChkBox') {
                $("#multiPageDivTab").find("input:checkbox:checked").not("[name*='" + id + "']").prop("checked", false);
                $("#multiPageDivTab").find("input:text").val('');
            } else {
                $('#NoSedationChkBox').prop("checked", false);
                //$('#GeneralAnaestheticChkBox').prop("checked", false);
            }
        }

        function BowelTab() {
            var apply = false;
            $("#multiPageDivTab1").find("input[type=text], select, textarea").each(function () {
                if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(none selected)') { apply = true; return false; }
            });
            if ($("#multiPageDivTab1 input:checkbox:checked").length > 0) { apply = true; }
            if ($("#multiPageDivTab1 input:radio:checked").length > 0) { apply = true; }
            setImage("1", apply);
        }
        function setImage(ind, state) {
            var tabS = $find("<%= RadTabStrip1.ClientID%>");
            if (ind != undefined) {
                var tab = tabS.findTabByValue(ind);
                if (tab != null) {
                    if (state) {
                        //tab.set_imageUrl('../../Images/Ok.png');
                        tab.get_textElement().style.fontWeight = 'bold';

                    } else {

                        //tab.set_imageUrl('../../Images/none.png');
                        tab.get_textElement().style.fontWeight = 'normal';
                    }
                }
            }
        }
    </script>
</asp:Content>

<asp:Content ID="PMBody" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="Server">
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="cmdOtherData" Skin="Metro" />
    <telerik:RadAjaxManagerProxy ID="RadAjaxManager1" runat="server">
        <AjaxSettings>
            <telerik:AjaxSetting AjaxControlID="cmdSaveDefaults">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="MainPageRadSplitter" LoadingPanelID="RadAjaxLoadingPanel1" />
                </UpdatedControls>
            </telerik:AjaxSetting>
            <telerik:AjaxSetting AjaxControlID="cmdAccept">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="MainPageRadSplitter" LoadingPanelID="RadAjaxLoadingPanel1" />
                    <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                </UpdatedControls>
            </telerik:AjaxSetting>
            <telerik:AjaxSetting AjaxControlID="cmdCancel">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="MainPageRadSplitter" LoadingPanelID="RadAjaxLoadingPanel1" />
                </UpdatedControls>
            </telerik:AjaxSetting>
            <telerik:AjaxSetting AjaxControlID="ModifyDrugsListWindow">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="MainPageRadSplitter" LoadingPanelID="RadAjaxLoadingPanel1" />
                </UpdatedControls>
            </telerik:AjaxSetting>
        </AjaxSettings>
    </telerik:RadAjaxManagerProxy>

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true">
    </telerik:RadAjaxLoadingPanel>

    <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
        <telerik:RadPane ID="ControlsRadPane" runat="server" Height="505px" Scrolling="Y">
            <div>
                <telerik:RadNotification ID="CreateProcRadNotification" runat="server" Animation="None"
                    EnableRoundedCorners="true" EnableShadow="true" Title="Please correct the following"
                    LoadContentOn="PageLoad" TitleIcon="delete" Position="Center"
                    AutoCloseDelay="7000" Skin="Web20">
                    <ContentTemplate>
                        <div id="valDiv" class="aspxValidationSummary"></div>
                        <asp:ValidationSummary ID="ValidationSummary" runat="server" ValidationGroup="PreVal" DisplayMode="BulletList" Skin="Web20"
                            EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>

                    </ContentTemplate>
                </telerik:RadNotification>
            </div>
            <div id="cmdOtherData">
                <div class="otherDataHeading">
                    <b>Drugs</b>
                </div>

                <div style="margin-left: 20px;">
                    <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" SelectedIndex="0" ReorderTabsOnSelect="true" Skin="Metro"
                        Orientation="HorizontalTop" RenderMode="Lightweight">
                        <Tabs>
                            <telerik:RadTab Text="Drugs administered" Font-Bold="true" Value="0" ImageUrl="../../Images/NEDJAG/JAGNED.png" />
                            <telerik:RadTab Text="Bowel preparation" Font-Bold="true" Value="1" ImageUrl="../../Images/NEDJAG/JAGNED.png" />
                        </Tabs>
                    </telerik:RadTabStrip>

                    <telerik:RadMultiPage ID="RadMultiPage1" runat="server" SelectedIndex="0">

                        <telerik:RadPageView ID="RadPageView1" runat="server">
                            <div id="multiPageDivTab" class="multiPageDivTab">
                                <%--   <fieldset id ="Fieldset1" runat="server" class="otherDataFieldset" style="margin:15px 15px 15px 15px;width:700px;">--%>
                                <%--  <legend>Drugs administered</legend>--%>
                                <table>
                                    <tr>
                                        <td valign="top" style="padding-left: 7px;">
                                            <table id="tableNoSedation" runat="server" cellspacing="3" cellpadding="0" border="0" />
                                        </td>
                                        <td valign="top" style="padding-left: 47px">
                                            <table id="tableAnaesthetic" runat="server" cellspacing="3" cellpadding="0" border="0" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="border_bottom"></td>
                                        <td class="border_bottom"></td>
                                    </tr>
                                    <tr>
                                        <td valign="top">
                                            <table id="tablePreMed1" runat="server" cellspacing="10" cellpadding="0" border="0" />
                                        </td>
                                        <td valign="top" style="padding-left: 40px">
                                            <table id="tablePreMed2" runat="server" cellspacing="10" cellpadding="0" border="0" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="border_bottom"></td>
                                        <td class="border_bottom"></td>
                                    </tr>
                                    <tr>
                                        <td valign="top" style="padding-top: 10px">
                                            <telerik:RadButton ID="cmdModifyDrugs" runat="server" Text="Modify the list of drugs" OnClientClicked="openPopUp" Skin="Windows7" Icon-PrimaryIconCssClass="rbEdit" AutoPostBack="false" />
                                        </td>
                                        <td valign="top" style="padding-top: 10px; padding-left: 47px">
                                            <telerik:RadButton ID="cmdSaveDefaults" runat="server" Text="Save as my defaults" Skin="Windows7" Icon-PrimaryIconCssClass="telerikDefaultButton" />
                                        </td>
                                    </tr>
                                </table>
                                <%--<asp:RequiredFieldValidator runat="server" ID="PreMedRequiredFieldValidator" Display="None" ErrorMessage="Select premedication drug(s)" ValidationGroup="PreVal" />--%>

                                <%--  </fieldset>--%>
                            </div>
                        </telerik:RadPageView>

                        <telerik:RadPageView ID="RadPageView0" runat="server">
                            <div id="multiPageDivTab1" class="multiPageDivTab">
                                <fieldset id="BowelPrepLegendFieldsetOn" runat="server" class="otherDataFieldset" style="margin: 15px 15px 15px 15px; width: 700px;">
                                    <legend>Bowel preparation</legend>
                                    <table id="tableBowelPrepOn">
                                        <tr>
                                            <td colspan="2">
                                                <asp:CheckBox ID="NoBowelCheckBox" runat="server" Text="No bowel preparation" Skin="Windows7" onchange="ToggleBowelBoxes();" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="Label1" runat="server" Text="Oral Formulation:"></asp:Label>&nbsp;
                                            </td>
                                            <td>
                                                <telerik:RadComboBox ID="OnOralFormulationComboBox" Text="Formulation:" runat="server" Width="200" Skin="Metro" Style="margin-left: 5px;" OnClientSelectedIndexChanged="ResetNoBowelPreparationsBox" />
                                                &nbsp; &nbsp;
                                                <asp:Label ID="Label2" runat="server" Text="Quantity:"></asp:Label>&nbsp;
                                                <telerik:RadNumericTextBox ID="OnOralQuantityText" MinValue="0" MaxValue="100" runat="server" Width="50" Skin="Metro" Style="margin-left: 5px;" />

                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="Label3" runat="server" Text="Enema Formulation:"></asp:Label>&nbsp;
                                            </td>
                                            <td>
                                                <telerik:RadComboBox ID="OnEnemaFormulationComboBox" Text="Formulation:" runat="server" Width="200" Skin="Metro" Style="margin-left: 5px;" OnClientSelectedIndexChanged="ResetNoBowelPreparationsBox" />
                                                &nbsp; &nbsp;
                                                <asp:CheckBox ID="OnCO2InsufflationCheckBox" runat="server" Text="CO<sub>2</sub> insufflation" TextAlign="Left" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="left" colspan="2"><b>Boston Bowel Preparation Scale</b></td>
                                        </tr>

                                        <tr>
                                            <td colspan="2">
                                                <br />
                                                Right &nbsp;<telerik:RadNumericTextBox ID="RightRadNumericTextBox" EmptyMessage="Not examined" runat="server" ShowSpinButtons="true" Skin="Office2007" Width="120" MinValue="0" MaxValue="3" NumberFormat-DecimalDigits="0" ClientEvents-OnValueChanged="ScaleChanged" ToolTip="This is tool tip" />

                                                Transverse &nbsp;<telerik:RadNumericTextBox ID="TransverseRadNumericTextBox" EmptyMessage="Not examined" runat="server" ShowSpinButtons="true" Skin="Office2007" Width="120" MinValue="0" MaxValue="3" NumberFormat-DecimalDigits="0" ClientEvents-OnValueChanged="ScaleChanged" ToolTip="This is tool tip" />

                                                Left &nbsp;<telerik:RadNumericTextBox ID="LeftRadNumericTextBox" EmptyMessage="Not examined" runat="server" ShowSpinButtons="true" Skin="Office2007" Width="120" MinValue="0" MaxValue="3" NumberFormat-DecimalDigits="0" ClientEvents-OnValueChanged="ScaleChanged" ToolTip="This is tool tip" />
                                                &nbsp;&nbsp; Total Score:&nbsp;<asp:TextBox ID="TotalScoreLabel" runat="server" Width="60" />
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>

                                <fieldset id="BowelPrepLegendFieldsetOff" runat="server" class="otherDataFieldset" style="margin: 15px 15px 15px 15px; width: 700px;">
                                    <legend>Bowel preparation</legend>
                                    <table id="tableBowelPrepOff">

                                        <tr>
                                            <td>
                                                <asp:Label ID="OffOralFormulation" runat="server" Text="Oral Formulation:"></asp:Label>&nbsp;
                                            </td>
                                            <td>
                                                <telerik:RadComboBox ID="OffOralFormulationComboBox" Text="Formulation:" runat="server" Width="200" Skin="Metro" Style="margin-left: 5px;" OnClientSelectedIndexChanged="OnOralFormulationComboBox_changed" />
                                                &nbsp; &nbsp;
                                                <asp:Label ID="OffOralQuantity" runat="server" Text="Quantity:"></asp:Label>&nbsp;
                                                <telerik:RadNumericTextBox ID="OffOralQuantityText" MinValue="0" MaxValue="100" runat="server" Width="50" Skin="Metro" Style="margin-left: 5px;" />


                                                <%--  &nbsp;<asp:CheckBox ID="C02Checkbox" runat="server" Text="C0<sub>2</sub> insufflation" />--%>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="OffEnemaFormulation" runat="server" Text="Enema Formulation:"></asp:Label>&nbsp;
                                            </td>
                                            <td>
                                                <telerik:RadComboBox ID="OffEnemaFormulationComboBox" Text="Formation:" runat="server" Width="200" Skin="Metro" Style="margin-left: 5px;" OnClientSelectedIndexChanged="ResetNoBowelPreparationsBox" />
                                                &nbsp; &nbsp;
                                                <asp:CheckBox ID="OffCO2InsufflationCheckBox" runat="server" Text="CO<sub>2</sub> insufflation" TextAlign="Left" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div style="float: left; padding-top: 5px;">Quality: &nbsp;</div>
                                            </td>
                                            <td>
                                                <asp:RadioButtonList ID="BowelPreparationQualityRadioButtonList" runat="server" onchange="ToggleBowelBoxesOff();" RepeatDirection="Horizontal" Style="float: left;" />
                                                <div class="bowlpreptooltip"></div>
                                                <telerik:RadToolTip ID="BowlPrepRadToolTip" TargetControlID="BowelPreparationQualityRadioButtonList" runat="server" />
                                            </td>
                                        </tr>
                                    </table>

                                </fieldset>
                            </div>
                        </telerik:RadPageView>
                    </telerik:RadMultiPage>

                </div>
            </div>
        </telerik:RadPane>

        <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px">
            <div style="height: 10px; margin-left: 10px; padding-top: 2px; padding-bottom: 2px">
                <telerik:RadButton ID="cmdAccept" runat="server" Text="Save & Close" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" OnClientClicking="validateBowel" />
                <telerik:RadButton ID="cmdCancel" runat="server" Text="Cancel" Skin="Web20" OnClick="cancelRecord" Icon-PrimaryIconCssClass="telerikCancelButton" />
            </div>
            <div style="height: 0px; display: none">
                <telerik:RadButton ID="SaveOnly" runat="server" Text="Save" Skin="Web20" OnClick="SaveOnly_Click" Style="height: 1px; width: 1px" />
            </div>
        </telerik:RadPane>
    </telerik:RadSplitter>

    <telerik:RadWindowManager ID="PreMedWindowManager" runat="server"
        Style="z-index: 7001" Behaviors="Close, Move" AutoSize="false" Skin="Metro" EnableShadow="true" Modal="true">
        <Windows>
            <telerik:RadWindow ID="ModifyDrugsListWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true"
                Width="700px" Height="300px" Title="" VisibleStatusbar="false" />
        </Windows>
    </telerik:RadWindowManager>
    <telerik:RadScriptBlock ID="RadScriptBlock11" runat="server">
        <script type="text/javascript">

            function ShowInsertForm() {
                window.radopen("PreMedEditDrugs.aspx", "UserListDialog");
                return false;
            }
            function Validate(sender, args) {
                document.getElementById("valDiv").innerHTML = '';
                if ("<%= DrugAdminValidation%>" == 'True') {
                    ValidateDrugs(sender, args);
                }
                if ("<%= BowelPrepValidation%>" == 'True') {

                    if ("<%= BowelPrepValue%>" == 'True') {
                        ValidateBowelOn(sender, args);
                    } else {
                        ValidateBowel(sender, args);
                    }

                }
            }
            function ValidateDrugs(sender, args) {
                var validate = false;
                $("#BodyContentPlaceHolder_pBodyContentPlaceHolder_tablePreMed1 tr td:first-child input").each(function () {

                    if ($(this).is(":checked")) {
                        validate = true;
                        return false;
                    }
                });
                $("#BodyContentPlaceHolder_pBodyContentPlaceHolder_tablePreMed2 tr td:first-child input").each(function () {
                    if ($(this).is(":checked")) {
                        validate = true;
                        return false;
                    }
                });
                $("#BodyContentPlaceHolder_pBodyContentPlaceHolder_tableNoSedation tr td:first-child input").each(function () {
                    if ($(this).is(":checked")) {
                        validate = true;
                        return false;
                    }
                });
                $("#BodyContentPlaceHolder_pBodyContentPlaceHolder_tableAnaesthetic tr td:first-child input").each(function () {
                    if ($(this).is(":checked")) {
                        validate = true;
                        return false;
                    }
                });
                if (validate == true) { return; }
                else {
                    args.set_cancel(true);
                    var msg = document.getElementById("valDiv").innerHTML;
                    if (msg == null || msg == '') {
                        document.getElementById("valDiv").innerHTML = "* You must record any premedication for this procedure.";
                    } else {
                        document.getElementById("valDiv").innerHTML = msg + "<br/> * You must record any premedication for this procedure.";
                    }

                    $find("<%=CreateProcRadNotification.ClientID%>").show();
                }
            }
            function ValidateBowel(sender, args) {
                var validate = false;
                if ($("#<%=BowelPreparationQualityRadioButtonList.ClientID%>").find("input[value='0']").is(':checked')) {
                    validate = true
                }
                if ($("#<%=BowelPreparationQualityRadioButtonList.ClientID%> input:radio:checked").val() != undefined) {
                    validate = true
                }
                if (validate == true) { return; }
                else {
                    args.set_cancel(true);
                    var msg = document.getElementById("valDiv").innerHTML;
                    if (msg == null || msg == '') {
                        document.getElementById("valDiv").innerHTML = "* You must record bowel preparation details for this procedure - both the formulation used and the quality of the preparation.";
                    } else {
                        document.getElementById("valDiv").innerHTML = msg + "<br/> * You must record bowel preparation details for this procedure - both the formulation used and the quality of the preparation.";
                    }

                    $find("<%=CreateProcRadNotification.ClientID%>").show();
                }
            }
            function ValidateBowelOn(sender, args) {
                var validate = false;
                if ($("#<%=NoBowelCheckBox.ClientID%>").is(':checked')) {
                    validate = true
                }
                if (($find('<%=RightRadNumericTextBox.ClientID%>').get_value() != '' && $find('<%=TransverseRadNumericTextBox.ClientID%>').get_value() != '' && $find('<%=LeftRadNumericTextBox.ClientID%>').get_value() != '')) {
                    validate = true
                }
                if (validate == true) { return; }
                else {
                    args.set_cancel(true);
                    var msg = document.getElementById("valDiv").innerHTML;
                    if (msg == null || msg == '') {
                        document.getElementById("valDiv").innerHTML = "* Please input bowel preparation";
                    } else {
                        document.getElementById("valDiv").innerHTML = msg + "<br/> * Please input bowel preparation";
                    }

                    $find("<%=CreateProcRadNotification.ClientID%>").show();
                }
            }
            function ToggleBowelBoxes() {
                if ($('#<%= NoBowelCheckBox.ClientID%>').is(':checked')) {
                    $find('<%= OnOralFormulationComboBox.ClientID%>').clearSelection();
                    $find('<%= OnOralFormulationComboBox.ClientID%>').disable();
                    $find('<%= OnEnemaFormulationComboBox.ClientID%>').clearSelection();
                    $find('<%= OnEnemaFormulationComboBox.ClientID%>').disable();
                    $find('<%= OnOralQuantityText.ClientID%>').val("");
                    $find('<%= OnOralQuantityText.ClientID%>').disable();
                    $find('<%= RightRadNumericTextBox.ClientID%>').disable();
                    $('#<%= RightRadNumericTextBox.ClientID%>').val("");
                    $find('<%= TransverseRadNumericTextBox.ClientID%>').disable();
                    $('#<%= TransverseRadNumericTextBox.ClientID%>').val("");
                    $find('<%= LeftRadNumericTextBox.ClientID%>').disable();
                    $('#<%= LeftRadNumericTextBox.ClientID%>').val("");
                    $('#<%= TotalScoreLabel.ClientID%>').val(0);
                    $('#<%= TotalScoreLabel.ClientID%>').prop("disabled", true);
                } else {
                    $find('<%= OnOralFormulationComboBox.ClientID%>').enable();
                    $find('<%= OnEnemaFormulationComboBox.ClientID%>').enable();
                    $find('<%= OnOralQuantityText.ClientID%>').enable();
                    $find('<%= RightRadNumericTextBox.ClientID%>').enable();
                    $find('<%= TransverseRadNumericTextBox.ClientID%>').enable();
                    $find('<%= LeftRadNumericTextBox.ClientID%>').enable();
                }
            }

            function ToggleBowelBoxesOff() {
                if ($('#<%= BowelPreparationQualityRadioButtonList.ClientID%>').find("input[value='0']").is(':checked')) {
                    $find('<%= OffOralFormulationComboBox.ClientID%>').clearSelection();
                    $find('<%= OffEnemaFormulationComboBox.ClientID%>').clearSelection();
                    //$find('<%= OffOralQuantityText.ClientID%>').val("");
                }
            }

            function OnOralFormulationComboBox_changed(sender, args) {
                var qtyBox = $find('<%= OffOralQuantityText.ClientID%>');

                if (args.get_item().get_value() != '') {
                    //set quantity to 2
                    qtyBox.set_value(2);

                }
                else {
                    //clear quantity box
                    qtyBox.clear();
                }
                ResetNoBowelPreparationsBox();
            }
            function ResetNoBowelPreparationsBox() {
                $('#<%= BowelPreparationQualityRadioButtonList.ClientID%>').find("input[value='0']").prop("checked", false);

                //Mahfuz added on 27 July 2021
                if ($find('<%=OffOralFormulationComboBox.ClientID %>') != null) {
                    var oralcombo = $find('<%=OffOralFormulationComboBox.ClientID %>');
                    var qtyText = $find('<%=OffOralQuantityText.ClientID %>');
                    var enemaCombo = $find('<%=OffEnemaFormulationComboBox.ClientID %>');
                }
                else {
                    var oralcombo = $find('<%=OnOralFormulationComboBox.ClientID %>');
                    var qtyText = $find('<%=OnOralQuantityText.ClientID %>');
                    var enemaCombo = $find('<%=OnEnemaFormulationComboBox.ClientID %>');
                }


                //alert(qtyText);
                //17 Sept 2021 : MH fixed auto set Qty for Boston Bowel prep

                if (oralcombo.get_selectedItem().get_value() == '' && enemaCombo.get_selectedItem().get_value() != '' && qtyText.get_value() == '') {
                    qtyText.set_value(1.00);

                }
                else if (oralcombo.get_selectedItem().get_value() != '' && enemaCombo.get_selectedItem().get_value() == '' && qtyText.get_value() == '') {
                    qtyText.set_value(2.00);

                }
                else if (oralcombo.get_selectedItem().get_value() != '' && enemaCombo.get_selectedItem().get_value() != '' && (qtyText.get_value() == '' || qtyText.get_value() == '1.00')) {
                    qtyText.set_value(2.00);

                }
                else if (oralcombo.get_selectedItem().get_value() == '' && enemaCombo.get_selectedItem().get_value() == '' && qtyText.get_value() != '') {
                    qtyText.set_value('');
                }



            }

            function ScaleChanged() {
                count = 0;
                var box1 = parseInt($('#<%= RightRadNumericTextBox.ClientID%>').val());
                var box2 = parseInt($('#<%= TransverseRadNumericTextBox.ClientID%>').val());
                var box3 = parseInt($('#<%= LeftRadNumericTextBox.ClientID%>').val());

                if (box1 != null && box1 >= 0 && box1 <= 3) {
                    count += box1;
                }

                if (box2 != null && box2 >= 0 && box2 <= 3) {
                    count += box2;
                }

                if (box3 != null && box3 >= 0 && box3 <= 3) {
                    count += box3;
                }

                var txtbox = $('#<%= TotalScoreLabel.ClientID%>');
                txtbox.val(count);

            }
            function setDefaultValue(sender, defaultVal) {
                var elemId = sender.id;
                var hfDefDosage = elemId.replace('PreMedChkBox', 'hfDefDosage');
                var txtDosage = elemId.replace('PreMedChkBox', 'txtDosage');
                //alert(defaultVal);
                if (document.getElementById(elemId).checked) {
                    if (document.getElementById(txtDosage) != null) {
                        document.getElementById(txtDosage).value = defaultVal;
                    }
                } else {
                    if (document.getElementById(txtDosage) != null) {
                        document.getElementById(txtDosage).value = "";
                    }
                }
            }
            function openPopUp() {
                var oWnd = $find("<%= ModifyDrugsListWindow.ClientID %>");
                oWnd._navigateUrl = "<%= ResolveUrl("~/Products/Options/ModifyPremedicationDrugs.aspx?option=0")%>";
                oWnd.set_title("");
                oWnd.SetSize(1000, 700);

                //Add the name of the function to be executed when RadWindow is closed.
                oWnd.add_close(OnClientClose);
                oWnd.show();

                ////Add the name of the function to be executed when RadWindow is closed.
                //oWnd.add_close(OnClientClose);
                //oWnd.show();
                //var own = radopen("../Options/ModifyPremedicationDrugs.aspx?option=0", "Premedication Drugs", '1000px', '700px');
                //own.set_visibleStatusbar(false);
            }

            function OnClientClose(oWnd, eventArgs) {
                //Remove the OnClientClose function to avoid
                //adding it for a second time when the window is shown again.
                oWnd.remove_close(OnClientClose);

                __doPostBack('<%=ModifyDrugsListWindow.UniqueID %>', '');

            }

            function dosageChanged(sender, args) {
                var elemId = sender.get_element().id;
                var chkDosage = elemId.replace('txtDosage', 'PreMedChkBox');
                var v = sender.get_value();
                if (v > 0) {
                    $(document.getElementById(chkDosage)).prop("checked", true);
                } else {
                    $(document.getElementById(chkDosage)).prop("checked", false);
                }
            }


        </script>
    </telerik:RadScriptBlock>

</asp:Content>

